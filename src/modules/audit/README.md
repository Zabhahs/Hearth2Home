# Module: Audit

## Responsibility (ARC-05 §5.2 — Audit Log Service)

Hash-chained, append-only event log for every material action taken on the platform: user actions, agent decisions (with prompt/output/version), document hashes, payment state changes, compliance evaluations, and consent records. Each log entry carries the SHA-256 hash of the previous entry, forming a tamper-evident chain. A nightly job computes the Merkle root of the day's entries and anchors it on Base via the Attestation Service (EAS-class, platform-signed, zero fund risk — R-06 / C-T3 not triggered). The module exposes a verification API for checking whether a given entry is intact and chain-consistent.

## MVP Scope (PLN-01 Week 1–4, continuous)

Append-only Postgres audit table with hash-chain columns (schema from DSN-01). Write helpers called by every other module at key events. Daily Merkle-anchor job (graphile-worker task, deferred implementation). Verification endpoint (read-only). Anchor on Base Sepolia at MVP; mainnet anchor follows after contract audit (C-T3). Structured query / search UI deferred.

## Implementation (T-005)

- `hash-chain.ts` — **pure**, DB-free integrity core: canonical-JSON serialization (RFC-8785-style key ordering) + SHA-256 payload hashing (`node:crypto`), genesis bootstrap (`prevHash` of the first event = `SHA-256(stream_id)`), per-event link hashing, gapless-`seq` + tamper + broken-link chain verification (`verifyChain`), and `merkleRoot` for the daily anchor. No I/O, no env, no PII.
- `audit-log.ts` — `AuditLog` writer. Resolves the stream head, computes `prevHash`/`payloadHash`, and appends via the security-definer `audit.append_audit_event` (DSN `0008_audit_log.sql`). The DB call is hidden behind the injectable `AuditStore` interface so the writer is unit-testable with a fake (no live DB, no service-role key). Payloads are reduced to a hash + optional tokenized summary — the raw body never leaves the caller.
- `supabase-store.ts` — production `AuditStore` wiring the writer to a Supabase service-role client (`audit` schema). Depends only on the minimal structural client surface it uses, because the `audit` schema is not in the generated `database.types.ts`.
- Tests (`__tests__/`) cover the chain core (valid chain verifies; tampered payload, seq gap, broken link, wrong stream each detected independently), the writer against a fake store, and the Supabase store against a fake structural client. All run with no live-DB dependency.

The on-chain anchor submission, the read-only Verification API endpoint, and a typed `database.types.ts` for the `audit` schema are out of scope for this task.
