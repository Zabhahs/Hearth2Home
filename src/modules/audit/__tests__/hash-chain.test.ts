/**
 * Unit tests for the pure audit hash-chain core (ARC-08 §8.3 / ADR-0012).
 *
 * No DB, no env. These assert the tamper-evidence guarantees directly:
 * a valid chain verifies; a tampered payload, a sequence gap, and a broken
 * prevHash link are each detected with a precise, independent reason.
 */
import { createHash } from "node:crypto";

import { describe, it, expect } from "vitest";

import {
  canonicalize,
  hashPayload,
  genesisPrevHash,
  computeLinkHash,
  linkEvent,
  verifyChain,
  merkleRoot,
  type RecordedEvent,
} from "@/modules/audit/hash-chain";
import type { Json } from "@/lib/supabase/database.types";

const sha256 = (s: string) => createHash("sha256").update(s, "utf8").digest("hex");

/**
 * Build a valid recorded chain for a stream from a list of payloads, using the
 * production link logic so the fixtures are correct by construction.
 */
function buildValidChain(streamId: string, payloads: readonly Json[]): RecordedEvent[] {
  const events: RecordedEvent[] = [];
  let prev: { seq: number; linkHash: string } | null = null;
  for (const payload of payloads) {
    const linked = linkEvent(streamId, payload, prev);
    events.push({ ...linked, payload });
    prev = { seq: linked.seq, linkHash: computeLinkHash(linked) };
  }
  return events;
}

describe("canonicalize", () => {
  it("is independent of object key insertion order", () => {
    const a: Json = { b: 1, a: 2, c: { y: true, x: null } };
    const b: Json = { c: { x: null, y: true }, a: 2, b: 1 };
    expect(canonicalize(a)).toBe(canonicalize(b));
    expect(hashPayload(a)).toBe(hashPayload(b));
  });

  it("preserves array order (order is semantic)", () => {
    expect(canonicalize([1, 2, 3] as Json)).not.toBe(canonicalize([3, 2, 1] as Json));
  });

  it("omits undefined object properties (matches Json/JSON.stringify semantics)", () => {
    const withUndef = { a: 1, b: undefined } as unknown as Json;
    expect(canonicalize(withUndef)).toBe('{"a":1}');
  });

  it("serializes primitives and null deterministically", () => {
    expect(canonicalize(null)).toBe("null");
    expect(canonicalize(true as Json)).toBe("true");
    expect(canonicalize("x" as Json)).toBe('"x"');
    expect(canonicalize(42 as Json)).toBe("42");
  });

  it("throws on non-finite numbers (not representable / not reversible)", () => {
    expect(() => canonicalize(Number.NaN as Json)).toThrow();
    expect(() => canonicalize(Number.POSITIVE_INFINITY as Json)).toThrow();
  });

  it("hashPayload equals SHA-256 of the canonical string", () => {
    const payload: Json = { action: "lease.executed", ref: "abc" };
    expect(hashPayload(payload)).toBe(sha256(canonicalize(payload)));
  });
});

describe("genesisPrevHash", () => {
  it("is SHA-256 of the stream id (matches the DB bootstrap rule)", () => {
    expect(genesisPrevHash("lease:123")).toBe(sha256("lease:123"));
  });

  it("differs per stream", () => {
    expect(genesisPrevHash("a")).not.toBe(genesisPrevHash("b"));
  });
});

describe("linkEvent", () => {
  it("starts a stream at seq 1 with the genesis prevHash", () => {
    const e = linkEvent("platform", { k: 1 }, null);
    expect(e.seq).toBe(1);
    expect(e.prevHash).toBe(genesisPrevHash("platform"));
    expect(e.payloadHash).toBe(hashPayload({ k: 1 }));
  });

  it("links to the previous link hash and increments seq", () => {
    const first = linkEvent("platform", { k: 1 }, null);
    const firstLink = computeLinkHash(first);
    const second = linkEvent("platform", { k: 2 }, { seq: first.seq, linkHash: firstLink });
    expect(second.seq).toBe(2);
    expect(second.prevHash).toBe(firstLink);
  });
});

describe("verifyChain", () => {
  it("verifies a valid multi-event chain (ok, no violations, head set)", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }, { b: 2 }, { c: 3 }]);
    const result = verifyChain("lease:abc", events);
    expect(result.ok).toBe(true);
    expect(result.violations).toHaveLength(0);
    expect(result.headHash).toBe(computeLinkHash(events[events.length - 1]));
  });

  it("verifies an empty chain as ok with null head", () => {
    const result = verifyChain("lease:empty", []);
    expect(result.ok).toBe(true);
    expect(result.violations).toHaveLength(0);
    expect(result.headHash).toBeNull();
  });

  it("verifies a single genesis event", () => {
    const events = buildValidChain("platform", [{ only: true }]);
    expect(verifyChain("platform", events).ok).toBe(true);
  });

  it("DETECTS a tampered payload (payload no longer hashes to payloadHash)", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }, { b: 2 }, { c: 3 }]);
    // Mutate the middle event's payload but keep its stored payloadHash.
    const tampered = events.map((e, i) =>
      i === 1 ? ({ ...e, payload: { b: 999 } } as RecordedEvent) : e,
    );
    const result = verifyChain("lease:abc", tampered);
    expect(result.ok).toBe(false);
    const v = result.violations.find((x) => x.kind === "tampered_payload");
    expect(v).toBeDefined();
    expect(v).toMatchObject({ kind: "tampered_payload", seq: 2 });
  });

  it("DETECTS a sequence gap (non-gapless seq)", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }, { b: 2 }, { c: 3 }]);
    // Drop the middle event so the sequence jumps 1 -> 3.
    const withGap = [events[0], events[2]];
    const result = verifyChain("lease:abc", withGap);
    expect(result.ok).toBe(false);
    const v = result.violations.find((x) => x.kind === "seq_gap");
    expect(v).toMatchObject({ kind: "seq_gap", expectedSeq: 2, actualSeq: 3 });
  });

  it("DETECTS a duplicate seq (also a gapless violation)", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }, { b: 2 }]);
    const dup = [events[0], { ...events[0] }];
    const result = verifyChain("lease:abc", dup);
    expect(result.ok).toBe(false);
    expect(result.violations.some((x) => x.kind === "seq_gap")).toBe(true);
  });

  it("DETECTS a broken prevHash link (re-pointed chain)", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }, { b: 2 }, { c: 3 }]);
    // Corrupt the prevHash of the 3rd event.
    const broken = events.map((e, i) =>
      i === 2 ? ({ ...e, prevHash: sha256("not-the-real-link") } as RecordedEvent) : e,
    );
    const result = verifyChain("lease:abc", broken);
    expect(result.ok).toBe(false);
    const v = result.violations.find((x) => x.kind === "broken_link");
    expect(v).toMatchObject({ kind: "broken_link", seq: 3 });
  });

  it("DETECTS a broken genesis link (first event's prevHash wrong)", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }]);
    const broken = [{ ...events[0], prevHash: sha256("wrong-genesis") } as RecordedEvent];
    const result = verifyChain("lease:abc", broken);
    expect(result.ok).toBe(false);
    expect(result.violations.some((x) => x.kind === "broken_link")).toBe(true);
  });

  it("DETECTS an event attributed to the wrong stream", () => {
    const events = buildValidChain("lease:abc", [{ a: 1 }, { b: 2 }]);
    const result = verifyChain("lease:DIFFERENT", events);
    expect(result.ok).toBe(false);
    expect(result.violations.some((x) => x.kind === "wrong_stream")).toBe(true);
  });

  it("reports each defect independently without cascading", () => {
    // A valid chain with ONLY a tampered payload should yield exactly one
    // violation (the tamper), not spurious downstream link errors — because
    // expectations advance from each event's own recorded fields.
    const events = buildValidChain("s", [{ a: 1 }, { b: 2 }, { c: 3 }, { d: 4 }]);
    const tampered = events.map((e, i) =>
      i === 1 ? ({ ...e, payload: { b: -1 } } as RecordedEvent) : e,
    );
    const result = verifyChain("s", tampered);
    expect(result.violations).toHaveLength(1);
    expect(result.violations[0].kind).toBe("tampered_payload");
  });
});

describe("merkleRoot", () => {
  it("returns the single leaf for a one-leaf tree", () => {
    expect(merkleRoot(["aa"])).toBe("aa");
  });

  it("is deterministic and order-sensitive", () => {
    const r1 = merkleRoot(["a", "b", "c", "d"]);
    const r2 = merkleRoot(["a", "b", "c", "d"]);
    expect(r1).toBe(r2);
    expect(merkleRoot(["a", "b"])).not.toBe(merkleRoot(["b", "a"]));
  });

  it("duplicates the last node for odd counts (Bitcoin-style)", () => {
    // 3 leaves => level1 = [H(ab), H(cc)] => root = H(H(ab)||H(cc)).
    const h = (s: string) => sha256(s);
    const expected = h(`${h("ab")}${h("cc")}`);
    expect(merkleRoot(["a", "b", "c"])).toBe(expected);
  });

  it("throws on an empty leaf set (nothing to anchor)", () => {
    expect(() => merkleRoot([])).toThrow();
  });
});
