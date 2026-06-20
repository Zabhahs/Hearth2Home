/**
 * Audit hash-chain core (ARC-08 §8.3 / ADR-0012).
 *
 * PURE module — no DB, no I/O, no environment access. Everything here is a
 * deterministic function of its inputs so it can be exhaustively unit-tested
 * and reused by both the writer (server-side) and the Verification API.
 *
 * The chain is per-stream. Each event commits to:
 *   - the SHA-256 of its canonical-JSON payload (`payloadHash`), and
 *   - the hash of the previous event in the same stream (`prevHash`).
 *
 * Bootstrap rule (matches supabase/migrations/0008_audit_log.sql): the
 * `prevHash` of the FIRST event in a stream is SHA-256(stream_id).
 *
 * Sequence numbers are gapless and start at 1 within a stream (the DB function
 * `audit.append_audit_event` assigns `seq = MAX(seq)+1`, first row = 1).
 *
 * INVARIANTS enforced/verified here:
 *   - append-only / tamper-evident: any mutation to a recorded payload, seq, or
 *     link is detectable by {@link verifyChain}.
 *   - no PII: payloads carry hashes + references only; this module never
 *     inspects or stores raw subject data — it only hashes whatever caller
 *     passes, and callers are responsible for passing tokenized/hashed values.
 */
import { createHash } from "node:crypto";

import type { Json } from "@/lib/supabase/database.types";

/** SHA-256 hex digest of a UTF-8 string. */
function sha256Hex(input: string): string {
  return createHash("sha256").update(input, "utf8").digest("hex");
}

/**
 * Canonical JSON serialization (RFC-8785-style key ordering).
 *
 * Two payloads that are deeply equal MUST serialize to the identical string,
 * regardless of key insertion order, so their hashes match. Object keys are
 * sorted lexicographically at every level; arrays preserve order (order is
 * semantically meaningful). `undefined` object properties are omitted, matching
 * `JSON.stringify` semantics and our {@link Json} type (which models that).
 *
 * Throws on values JSON cannot represent (e.g. NaN, Infinity, BigInt, cycles)
 * rather than silently producing a non-reversible/ambiguous string.
 */
export function canonicalize(value: Json): string {
  return serialize(value);
}

function serialize(value: Json | undefined): string {
  if (value === undefined) {
    // Only reachable for object property values; arrays are handled separately.
    return "null";
  }
  if (value === null) {
    return "null";
  }
  const t = typeof value;
  if (t === "string") {
    return JSON.stringify(value);
  }
  if (t === "boolean") {
    return value ? "true" : "false";
  }
  if (t === "number") {
    if (!Number.isFinite(value as number)) {
      throw new TypeError("canonicalize: non-finite number is not serializable");
    }
    // JSON.stringify gives the canonical shortest round-trippable form.
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    return `[${value.map((v) => serialize(v as Json)).join(",")}]`;
  }
  if (t === "object") {
    const obj = value as { [key: string]: Json | undefined };
    const keys = Object.keys(obj)
      .filter((k) => obj[k] !== undefined)
      .sort();
    const body = keys.map((k) => `${JSON.stringify(k)}:${serialize(obj[k])}`).join(",");
    return `{${body}}`;
  }
  // bigint, function, symbol — not part of Json, but guard defensively.
  throw new TypeError(`canonicalize: unsupported value type "${t}"`);
}

/** SHA-256 hex of the canonical JSON form of a payload. */
export function hashPayload(payload: Json): string {
  return sha256Hex(canonicalize(payload));
}

/** Bootstrap prevHash for the first event in a stream: SHA-256(stream_id). */
export function genesisPrevHash(streamId: string): string {
  return sha256Hex(streamId);
}

/**
 * The logical content of an audit event that participates in the chain.
 *
 * `seq` and `recordedAt` are assigned authoritatively by the DB
 * (`audit.append_audit_event`); the rest are supplied by the caller. This is a
 * data-only record used for hashing and verification — it intentionally holds
 * no raw PII (payload is reduced to {@link ChainEvent.payloadHash}).
 */
export interface ChainEvent {
  /** Logical stream identifier (e.g. "lease:{id}", "platform"). */
  readonly streamId: string;
  /** Gapless sequence number within the stream; first event = 1. */
  readonly seq: number;
  /** Hash of the previous event in this stream (genesis for seq 1). */
  readonly prevHash: string;
  /** SHA-256 of the canonical-JSON payload (the integrity commitment). */
  readonly payloadHash: string;
}

/**
 * Deterministically compute the link hash of an event — the value the NEXT
 * event in the stream will carry as its `prevHash`.
 *
 * The link binds the event's position (streamId, seq), its payload commitment,
 * and the prior link, so reordering, dropping, or editing any event breaks the
 * downstream chain. We hash the canonical form of a fixed-shape header so the
 * computation is stable and independent of property order.
 */
export function computeLinkHash(event: ChainEvent): string {
  const header: Json = {
    streamId: event.streamId,
    seq: event.seq,
    prevHash: event.prevHash,
    payloadHash: event.payloadHash,
  };
  return hashPayload(header);
}

/**
 * Build the next event in a stream from the previous link and a fresh payload.
 *
 * @param streamId   the stream this event belongs to
 * @param payload    the (already PII-free) event payload to commit to
 * @param prev       the previous event's link info, or `null` to start a stream
 * @returns the new {@link ChainEvent} (seq, prevHash, payloadHash resolved)
 */
export function linkEvent(
  streamId: string,
  payload: Json,
  prev: { seq: number; linkHash: string } | null,
): ChainEvent {
  const prevHash = prev ? prev.linkHash : genesisPrevHash(streamId);
  const seq = prev ? prev.seq + 1 : 1;
  return {
    streamId,
    seq,
    prevHash,
    payloadHash: hashPayload(payload),
  };
}

/** A single, specific reason a chain failed verification. */
export type ChainViolation =
  | { kind: "wrong_stream"; seq: number; expectedStreamId: string; actualStreamId: string }
  | { kind: "seq_gap"; expectedSeq: number; actualSeq: number }
  | { kind: "broken_link"; seq: number; expectedPrevHash: string; actualPrevHash: string }
  | {
      kind: "tampered_payload";
      seq: number;
      expectedPayloadHash: string;
      actualPayloadHash: string;
    };

/** Result of verifying a chain segment. */
export interface VerifyResult {
  readonly ok: boolean;
  readonly violations: ChainViolation[];
  /** Link hash of the last verified event (chain head), or null if empty. */
  readonly headHash: string | null;
}

/**
 * An event as recorded, paired with the canonical payload it claims to commit
 * to. Verification re-hashes `payload` and checks it equals `payloadHash`,
 * which is what makes payload tampering detectable.
 */
export interface RecordedEvent extends ChainEvent {
  /** The canonical-JSON-able payload whose hash must equal `payloadHash`. */
  readonly payload: Json;
}

/**
 * Verify the integrity of a single stream's chain.
 *
 * Detects, independently and with a precise reason:
 *   - events attributed to the wrong stream,
 *   - sequence gaps / non-gapless seq (must be 1,2,3,… contiguous),
 *   - broken prevHash links (including a bad genesis link),
 *   - tampered payloads (payload no longer hashes to payloadHash).
 *
 * @param streamId  the stream all events must belong to
 * @param events    events in ascending seq order (verified to be so)
 */
export function verifyChain(streamId: string, events: readonly RecordedEvent[]): VerifyResult {
  const violations: ChainViolation[] = [];
  let expectedPrevHash = genesisPrevHash(streamId);
  let expectedSeq = 1;
  let headHash: string | null = null;

  for (const event of events) {
    if (event.streamId !== streamId) {
      violations.push({
        kind: "wrong_stream",
        seq: event.seq,
        expectedStreamId: streamId,
        actualStreamId: event.streamId,
      });
    }

    if (event.seq !== expectedSeq) {
      violations.push({ kind: "seq_gap", expectedSeq, actualSeq: event.seq });
    }

    if (event.prevHash !== expectedPrevHash) {
      violations.push({
        kind: "broken_link",
        seq: event.seq,
        expectedPrevHash,
        actualPrevHash: event.prevHash,
      });
    }

    const recomputed = hashPayload(event.payload);
    if (recomputed !== event.payloadHash) {
      violations.push({
        kind: "tampered_payload",
        seq: event.seq,
        expectedPayloadHash: recomputed,
        actualPayloadHash: event.payloadHash,
      });
    }

    // Advance expectations using the event's OWN recorded fields so that a
    // single defect surfaces as one precise violation rather than cascading
    // into spurious downstream errors. The link hash is computed from the
    // event as recorded (its stored seq/prevHash/payloadHash).
    headHash = computeLinkHash(event);
    expectedPrevHash = headHash;
    expectedSeq = event.seq + 1;
  }

  return { ok: violations.length === 0, violations, headHash };
}

/**
 * Compute a single Merkle root over an ordered list of leaf hashes (hex).
 *
 * Used by the daily anchor job (ARC-08 §8.3) to fold all per-stream head
 * hashes into one root for on-chain anchoring. Duplicates the last node on odd
 * levels (Bitcoin-style). Empty input is invalid (nothing to anchor).
 */
export function merkleRoot(leafHashes: readonly string[]): string {
  if (leafHashes.length === 0) {
    throw new RangeError("merkleRoot: cannot compute a root over zero leaves");
  }
  let level = [...leafHashes];
  while (level.length > 1) {
    const next: string[] = [];
    for (let i = 0; i < level.length; i += 2) {
      const left = level[i];
      const right = i + 1 < level.length ? level[i + 1] : left;
      next.push(sha256Hex(`${left}${right}`));
    }
    level = next;
  }
  return level[0];
}
