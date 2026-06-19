# ADR-0008 — Chainlink Functions + CCIP as Oracle Substrate

**Status:** Accepted (directed by scope §3A.3/§6.2) · 2026-06-11

## Context
The oracle/integration layer is the declared core asset (README §3A). Scope names Chainlink Functions (off-chain data/compute) + CCIP (cross-chain/service messaging) as the proven baseline.

## Decision
Chainlink Functions carries verified external events to contracts; CCIP is reserved for future cross-chain needs. **Our canonical event schema and Attestation Service sit in front of it** — business logic and contracts depend on our normalized events, never on Chainlink payload shapes directly.

## Consequences
- (+) Proven DON security model; no bespoke oracle network to operate.
- (+) The normalizer/attestation indirection caps vendor lock-in: swapping oracle transport touches one adapter (Q5-class evolvability; vendor concentration reviewed quarterly, ARC-11).
- (−) DON fees and latency on every on-chain event delivery; batched/anchored where event granularity allows.
- (−) Chainlink outage = attested events queue (DEFERRED_CHAIN); never blocks off-chain business progress.

## Alternatives
Self-operated signer-oracle only — rejected as sole mechanism (single-party trust undermines the "verified milestone" claim); retained as one attester within N-of-M tiers (DSN-03 §4). Other oracle networks — no maturity advantage today; revisit at Phase-2 vendor review.
