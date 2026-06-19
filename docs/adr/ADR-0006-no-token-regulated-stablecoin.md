# ADR-0006 — No Native Token; Regulated Third-Party Stablecoins (Multi-Issuer)

**Status:** Accepted · 2026-06-11

## Context
GENIUS Act (signed 2025-07-18) provides the federal stablecoin framework; CLARITY (token market structure) remains stalled (README §1). Scope: "do NOT mint your own" (§6.2); R-07 strands any token model.

## Decision
No platform token of any kind — not for fees, governance, incentives, or fractional anything. Settlement uses established regulated USD stablecoins behind a **multi-issuer abstraction** in PaymentRouter (issuer allowlist, per-issuer circuit breakers, balance migration runbook).

## Consequences
- (+) R-07 eliminated; securities-law surface minimized; GENIUS alignment.
- (+) Issuer freeze (R-08) survivable: suspend one issuer, settle on another or via ACH (ADR-0018).
- (−) GENIUS full regime phases in (C-L3): until effective, issuer selection rests on existing state regimes (e.g., NYDFS-supervised issuers) — **counsel confirms the launch issuer list** (ANL-04).
- (−) Escrow-float yield is NOT modeled as revenue (R-10) — Billing depends only on SaaS + throughput fees.

## Alternatives
Native token — rejected (R-07; stalled CLARITY). Single-issuer hard dependency — rejected (R-08 becomes existential instead of operational).
