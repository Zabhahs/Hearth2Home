/**
 * Audit log writer (ARC-08 §8.3 / ADR-0012 — DR-4, the spine).
 *
 * Records state-changing actions and AI decisions to the append-only,
 * hash-chained `audit.audit_record` table. The ONLY write path is the
 * security-definer DB function `audit.append_audit_event` (see
 * supabase/migrations/0008_audit_log.sql); this module computes the
 * `payloadHash` + resolved `prevHash` and calls that function.
 *
 * Design notes:
 *   - The Supabase RPC is hidden behind {@link AuditStore}, a tiny injectable
 *     interface, so the writer is unit-testable with a fake — no live DB and
 *     no real service-role key required.
 *   - No PII in payloads. Callers pass already-tokenized summaries + hashes;
 *     this module reduces the full payload to a SHA-256 commitment and only
 *     forwards a (caller-provided) non-PII `payloadSummary` for quick
 *     inspection. Raw subject data never leaves the caller.
 *   - The DB owns `seq` and `recorded_at`. The chain's `prevHash` is resolved
 *     by reading the current stream head before writing.
 */
import {
  computeLinkHash,
  genesisPrevHash,
  hashPayload,
  type ChainEvent,
} from "@/modules/audit/hash-chain";
import type { Json } from "@/lib/supabase/database.types";

/**
 * Arguments accepted by the `audit.append_audit_event` SQL function.
 *
 * These mirror the function signature in 0008_audit_log.sql exactly (snake_case
 * RPC parameter names). UUIDs are `string`, JSONB is {@link Json} — aligned to
 * the conventions in src/lib/supabase/database.types.ts. The `audit` schema is
 * not part of the generated public types, so this is the authoritative typing
 * for the call.
 */
export interface AppendAuditEventArgs {
  p_stream_id: string;
  p_prev_hash: string;
  p_payload_hash: string;
  p_actor_party_id?: string | null;
  p_principal_party_id?: string | null;
  p_action?: string | null;
  p_entity_type?: string | null;
  p_entity_id?: string | null;
  p_payload_summary?: Json | null;
  p_worm_payload_uri?: string | null;
  p_ai_model_id?: string | null;
  p_ai_prompt_version?: string | null;
  p_ai_input_hash?: string | null;
  p_ai_output_hash?: string | null;
  p_ai_guardrail_verdict?: Json | null;
}

/** The current head of a stream's chain (latest seq + its link hash). */
export interface StreamHead {
  /** Highest seq present in the stream. */
  readonly seq: number;
  /**
   * The link hash of that head event — i.e. the value the next appended event
   * must carry as its `prevHash`.
   */
  readonly linkHash: string;
}

/**
 * Injectable persistence boundary for the audit writer.
 *
 * Production implementation wraps the Supabase service client; tests inject a
 * fake. Keeping this minimal (two methods) is deliberate — it is the entire
 * surface that touches the DB.
 */
export interface AuditStore {
  /**
   * Return the current chain head for `streamId`, or `null` if the stream has
   * no events yet (so the writer uses the genesis prevHash).
   */
  getStreamHead(streamId: string): Promise<StreamHead | null>;

  /**
   * Invoke `audit.append_audit_event` with the given args. Returns the seq the
   * DB assigned to the new row. Implementations MUST surface DB errors by
   * throwing (the writer treats a throw as a failed append).
   */
  appendAuditEvent(args: AppendAuditEventArgs): Promise<number>;
}

/**
 * A logical audit event as supplied by a caller — the business-meaningful
 * fields. The chain bookkeeping (prevHash, seq, payloadHash) is computed by the
 * writer; the caller never sets those.
 *
 * `payload` is the full (PII-free) event body that gets hashed. `payloadSummary`
 * is an optional, separately-provided abbreviated/tokenized view persisted for
 * quick inspection — keep it free of raw PII per ARC-08 §8.5.
 */
export interface AuditEventInput {
  /** Stream this event belongs to, e.g. `lease:{id}` or `platform`. */
  readonly streamId: string;
  /** Action verb, e.g. `lease.executed`, `payment.initiated`. */
  readonly action: string;
  /** Entity type affected, e.g. `lease`, `payment_obligation`. */
  readonly entityType: string;
  /** The full PII-free payload to commit to (hashed; never stored raw here). */
  readonly payload: Json;
  /** Authenticated actor party id (UUID), if any. */
  readonly actorPartyId?: string | null;
  /** Principal party/org id the actor acted for (agency model), if any. */
  readonly principalPartyId?: string | null;
  /** Entity id affected (UUID), if applicable. */
  readonly entityId?: string | null;
  /** Optional non-PII tokenized summary persisted for quick inspection. */
  readonly payloadSummary?: Json | null;
  /** WORM storage pointer to the full payload blob, if persisted externally. */
  readonly wormPayloadUri?: string | null;
  /** AI-event metadata (ARC-08 §8.3). Omit for human-initiated events. */
  readonly ai?: AuditAiContext;
}

/** AI-decision provenance recorded alongside an audit event (ARC-08 §8.3). */
export interface AuditAiContext {
  readonly modelId: string;
  readonly promptVersion: string;
  /** SHA-256 of the full model input (blob lives at the WORM uri). */
  readonly inputHash: string;
  /** SHA-256 of the full model output. */
  readonly outputHash: string;
  /** Structured guardrail verdict (ADR-0009), already PII-free. */
  readonly guardrailVerdict?: Json | null;
}

/** Outcome of a successful append: the resolved chain fields. */
export interface AppendResult {
  readonly streamId: string;
  /** Sequence number the DB assigned. */
  readonly seq: number;
  /** prevHash used for this event. */
  readonly prevHash: string;
  /** payloadHash committed for this event. */
  readonly payloadHash: string;
  /** Link hash of this new event (the next event's prevHash). */
  readonly linkHash: string;
}

/**
 * The audit writer. Stateless aside from its injected {@link AuditStore}.
 *
 * Usage (production):
 *   const audit = new AuditLog(createSupabaseAuditStore(serviceClient));
 *   await audit.record({ streamId, action, entityType, payload });
 */
export class AuditLog {
  constructor(private readonly store: AuditStore) {}

  /**
   * Record one audit event: resolve the stream head, compute the chain fields,
   * and append via the security-definer DB function.
   *
   * @throws if the underlying store throws (failed/contended append). Audit
   *   writes are not best-effort — a caller that needs the event durable should
   *   let the error propagate (transactional-outbox handling lives upstream).
   */
  async record(input: AuditEventInput): Promise<AppendResult> {
    const head = await this.store.getStreamHead(input.streamId);
    const prevHash = head ? head.linkHash : genesisPrevHash(input.streamId);
    const payloadHash = hashPayload(input.payload);

    const args: AppendAuditEventArgs = {
      p_stream_id: input.streamId,
      p_prev_hash: prevHash,
      p_payload_hash: payloadHash,
      p_actor_party_id: input.actorPartyId ?? null,
      p_principal_party_id: input.principalPartyId ?? null,
      p_action: input.action,
      p_entity_type: input.entityType,
      p_entity_id: input.entityId ?? null,
      p_payload_summary: input.payloadSummary ?? null,
      p_worm_payload_uri: input.wormPayloadUri ?? null,
      p_ai_model_id: input.ai?.modelId ?? null,
      p_ai_prompt_version: input.ai?.promptVersion ?? null,
      p_ai_input_hash: input.ai?.inputHash ?? null,
      p_ai_output_hash: input.ai?.outputHash ?? null,
      p_ai_guardrail_verdict: input.ai?.guardrailVerdict ?? null,
    };

    const assignedSeq = await this.store.appendAuditEvent(args);

    // The DB serializes inserts per stream (advisory lock) and assigns the seq;
    // that value is authoritative. We recompute the link hash from the DB seq so
    // the returned head is correct for the next caller even if a concurrent
    // writer changed the head between our read and our write.
    const event: ChainEvent = {
      streamId: input.streamId,
      seq: assignedSeq,
      prevHash,
      payloadHash,
    };
    const linkHash = computeLinkHash(event);

    return {
      streamId: input.streamId,
      seq: assignedSeq,
      prevHash,
      payloadHash,
      linkHash,
    };
  }
}
