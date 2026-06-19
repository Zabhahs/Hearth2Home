# ADR-0012 — Hash-Chained Append-Only Audit Log with On-Chain Anchoring

**Status:** Accepted · 2026-06-11

## Context
DR-4 requires 100% of milestone events timestamped and attributable; scope's §6.2 names "append-only log (DB) + selective on-chain anchoring of hashes". A plain DB table is append-only by convention only — not tamper-evident.

## Decision
Per-stream hash chains (`prevHash` linkage, gapless sequence numbers) over audit events; payload hashes + WORM pointers, not blobs. A daily Merkle root across streams is anchored on-chain by the platform anchor key. A public verification API checks chain integrity and anchor inclusion.

## Consequences
- (+) Tamper-evidence with court-friendly explanation; near-zero on-chain cost (one anchor tx/day).
- (+) Aligns with Vermont-style evidentiary recognition of blockchain records (README §11.1) — the anchor strengthens the business-records narrative.
- (−) Anchoring is daily, so intra-day tampering detection relies on the hash chain + DB controls; acceptable.
- (−) Log schema becomes a contract: versioned, additive-only.

## Alternatives
Every event on-chain — rejected (cost, privacy, R-02). External notarization service — unnecessary given we already operate chain infrastructure.
