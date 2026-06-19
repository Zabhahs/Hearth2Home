# Module: Audit

## Responsibility (ARC-05 §5.2 — Audit Log Service)

Hash-chained, append-only event log for every material action taken on the platform: user actions, agent decisions (with prompt/output/version), document hashes, payment state changes, compliance evaluations, and consent records. Each log entry carries the SHA-256 hash of the previous entry, forming a tamper-evident chain. A nightly job computes the Merkle root of the day's entries and anchors it on Base via the Attestation Service (EAS-class, platform-signed, zero fund risk — R-06 / C-T3 not triggered). The module exposes a verification API for checking whether a given entry is intact and chain-consistent.

## MVP Scope (PLN-01 Week 1–4, continuous)

Append-only Postgres audit table with hash-chain columns (schema from DSN-01). Write helpers called by every other module at key events. Daily Merkle-anchor job (graphile-worker task, deferred implementation). Verification endpoint (read-only). Anchor on Base Sepolia at MVP; mainnet anchor follows after contract audit (C-T3). Structured query / search UI deferred.
