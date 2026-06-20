/**
 * Unit tests for the AuditLog writer (ARC-08 §8.3 / ADR-0012).
 *
 * Runs entirely against an in-memory fake {@link AuditStore} — NO live DB and
 * NO real service-role key required (the key is a placeholder in CI). The fake
 * mimics the security-definer `audit.append_audit_event` contract: it assigns a
 * gapless seq per stream and records exactly what the writer passed, so we can
 * assert the resulting events form a valid hash chain via the real verifier.
 */
import { describe, it, expect } from "vitest";

import {
  AuditLog,
  type AppendAuditEventArgs,
  type AuditStore,
  type StreamHead,
} from "@/modules/audit/audit-log";
import {
  computeLinkHash,
  genesisPrevHash,
  hashPayload,
  verifyChain,
  type RecordedEvent,
} from "@/modules/audit/hash-chain";
import type { Json } from "@/lib/supabase/database.types";

/**
 * In-memory fake of the audit DB. Models the `audit.append_audit_event`
 * contract: per-stream gapless seq assignment starting at 1, append-only.
 * Records the full args so tests can reconstruct the chain and verify it.
 */
class FakeAuditStore implements AuditStore {
  readonly rows = new Map<string, AppendAuditEventArgs[]>();
  /** Optional payloads keyed by streamId, captured to reconstruct the chain. */
  readonly payloads = new Map<string, Json[]>();

  async getStreamHead(streamId: string): Promise<StreamHead | null> {
    const stream = this.rows.get(streamId);
    if (!stream || stream.length === 0) {
      return null;
    }
    const last = stream[stream.length - 1];
    const seq = stream.length; // gapless, starts at 1
    const linkHash = computeLinkHash({
      streamId,
      seq,
      prevHash: last.p_prev_hash,
      payloadHash: last.p_payload_hash,
    });
    return { seq, linkHash };
  }

  async appendAuditEvent(args: AppendAuditEventArgs): Promise<number> {
    const stream = this.rows.get(args.p_stream_id) ?? [];
    stream.push(args);
    this.rows.set(args.p_stream_id, stream);
    return stream.length; // assigned seq (gapless, 1-based)
  }

  /** Reconstruct the recorded chain for a stream from captured payloads. */
  toRecordedChain(streamId: string, payloads: readonly Json[]): RecordedEvent[] {
    const stream = this.rows.get(streamId) ?? [];
    return stream.map((args, i) => ({
      streamId,
      seq: i + 1,
      prevHash: args.p_prev_hash,
      payloadHash: args.p_payload_hash,
      payload: payloads[i],
    }));
  }
}

describe("AuditLog.record", () => {
  it("records a genesis event with the genesis prevHash and seq 1", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);
    const payload: Json = { detail: "first" };

    const result = await audit.record({
      streamId: "lease:abc",
      action: "lease.created",
      entityType: "lease",
      payload,
    });

    expect(result.seq).toBe(1);
    expect(result.prevHash).toBe(genesisPrevHash("lease:abc"));
    expect(result.payloadHash).toBe(hashPayload(payload));
    expect(result.linkHash).toBe(
      computeLinkHash({
        streamId: "lease:abc",
        seq: 1,
        prevHash: result.prevHash,
        payloadHash: result.payloadHash,
      }),
    );
  });

  it("chains subsequent events: prevHash of N+1 equals linkHash of N", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);

    const r1 = await audit.record({
      streamId: "lease:abc",
      action: "a",
      entityType: "lease",
      payload: { n: 1 },
    });
    const r2 = await audit.record({
      streamId: "lease:abc",
      action: "b",
      entityType: "lease",
      payload: { n: 2 },
    });

    expect(r2.seq).toBe(2);
    expect(r2.prevHash).toBe(r1.linkHash);
  });

  it("produces a chain that the independent verifier accepts as valid", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);
    const payloads: Json[] = [{ a: 1 }, { b: 2 }, { c: 3 }];

    for (const payload of payloads) {
      await audit.record({
        streamId: "platform",
        action: "evt",
        entityType: "system",
        payload,
      });
    }

    const chain = store.toRecordedChain("platform", payloads);
    const result = verifyChain("platform", chain);
    expect(result.ok).toBe(true);
    expect(result.violations).toHaveLength(0);
  });

  it("keeps independent streams independent (each starts at seq 1)", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);

    const a1 = await audit.record({
      streamId: "lease:A",
      action: "x",
      entityType: "lease",
      payload: { s: "A" },
    });
    const b1 = await audit.record({
      streamId: "lease:B",
      action: "x",
      entityType: "lease",
      payload: { s: "B" },
    });

    expect(a1.seq).toBe(1);
    expect(b1.seq).toBe(1);
    expect(a1.prevHash).toBe(genesisPrevHash("lease:A"));
    expect(b1.prevHash).toBe(genesisPrevHash("lease:B"));
    expect(a1.linkHash).not.toBe(b1.linkHash);
  });

  it("forwards actor/principal/entity and tokenized summary to the DB args", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);
    const actor = "11111111-1111-1111-1111-111111111111";
    const principal = "22222222-2222-2222-2222-222222222222";
    const entityId = "33333333-3333-3333-3333-333333333333";

    await audit.record({
      streamId: "lease:abc",
      action: "lease.executed",
      entityType: "lease",
      entityId,
      actorPartyId: actor,
      principalPartyId: principal,
      payload: { full: "body", contentRef: "worm://x" },
      payloadSummary: { tokenizedRef: "tok_123" },
      wormPayloadUri: "s3://worm/abc",
    });

    const args = store.rows.get("lease:abc")![0];
    expect(args.p_actor_party_id).toBe(actor);
    expect(args.p_principal_party_id).toBe(principal);
    expect(args.p_entity_id).toBe(entityId);
    expect(args.p_action).toBe("lease.executed");
    expect(args.p_entity_type).toBe("lease");
    expect(args.p_payload_summary).toEqual({ tokenizedRef: "tok_123" });
    expect(args.p_worm_payload_uri).toBe("s3://worm/abc");
    // Only the hash of the payload is sent — the raw payload body is NOT in args.
    expect(args.p_payload_hash).toBe(
      hashPayload({ full: "body", contentRef: "worm://x" }),
    );
    expect(JSON.stringify(args)).not.toContain('"body"');
  });

  it("maps AI context into the ai_* DB args", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);

    await audit.record({
      streamId: "negotiation:1",
      action: "agent.counter_offer",
      entityType: "negotiation",
      payload: { proposalRef: "p1" },
      ai: {
        modelId: "claude-3-5-sonnet-20241022",
        promptVersion: "neg-v3",
        inputHash: "a".repeat(64),
        outputHash: "b".repeat(64),
        guardrailVerdict: { allowed: true, ruleset: "fair-housing-v2" },
      },
    });

    const args = store.rows.get("negotiation:1")![0];
    expect(args.p_ai_model_id).toBe("claude-3-5-sonnet-20241022");
    expect(args.p_ai_prompt_version).toBe("neg-v3");
    expect(args.p_ai_input_hash).toBe("a".repeat(64));
    expect(args.p_ai_output_hash).toBe("b".repeat(64));
    expect(args.p_ai_guardrail_verdict).toEqual({
      allowed: true,
      ruleset: "fair-housing-v2",
    });
  });

  it("defaults optional fields to null (not undefined) for the RPC", async () => {
    const store = new FakeAuditStore();
    const audit = new AuditLog(store);

    await audit.record({
      streamId: "platform",
      action: "system.boot",
      entityType: "system",
      payload: { ok: true },
    });

    const args = store.rows.get("platform")![0];
    expect(args.p_actor_party_id).toBeNull();
    expect(args.p_principal_party_id).toBeNull();
    expect(args.p_entity_id).toBeNull();
    expect(args.p_payload_summary).toBeNull();
    expect(args.p_worm_payload_uri).toBeNull();
    expect(args.p_ai_model_id).toBeNull();
    expect(args.p_ai_guardrail_verdict).toBeNull();
  });

  it("propagates store errors (audit writes are not best-effort)", async () => {
    const failing: AuditStore = {
      async getStreamHead() {
        return null;
      },
      async appendAuditEvent() {
        throw new Error("db unavailable");
      },
    };
    const audit = new AuditLog(failing);

    await expect(
      audit.record({
        streamId: "platform",
        action: "x",
        entityType: "system",
        payload: { a: 1 },
      }),
    ).rejects.toThrow("db unavailable");
  });

  it("uses the DB-assigned seq as authoritative for the returned link hash", async () => {
    // Simulate a concurrent writer: getStreamHead reports head seq 4, but the
    // DB assigns seq 6 (two events slipped in). The returned linkHash must be
    // computed from the DB seq (6), not the stale hint.
    const concurrent: AuditStore = {
      async getStreamHead(): Promise<StreamHead> {
        return { seq: 4, linkHash: "f".repeat(64) };
      },
      async appendAuditEvent(): Promise<number> {
        return 6;
      },
    };
    const audit = new AuditLog(concurrent);
    const payload: Json = { x: 1 };

    const result = await audit.record({
      streamId: "lease:abc",
      action: "x",
      entityType: "lease",
      payload,
    });

    expect(result.seq).toBe(6);
    expect(result.prevHash).toBe("f".repeat(64));
    expect(result.linkHash).toBe(
      computeLinkHash({
        streamId: "lease:abc",
        seq: 6,
        prevHash: "f".repeat(64),
        payloadHash: hashPayload(payload),
      }),
    );
  });
});
