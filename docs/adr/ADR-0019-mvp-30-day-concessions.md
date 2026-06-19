# ADR-0019 — 30-Day MVP: Scope & Stack Concessions (Time-Boxed)

**Status:** Proposed (founder review) · 2026-06-11

## Context
Founder directive: begin taking clients within 30 days. The documented increments (ARC-04 §4.3) assumed counsel-gated sequencing without a hard calendar constraint. A 30-day window cannot contain: smart-contract audit (C-T3), custody partner onboarding (ADR-0007), per-state deposit-rail analysis (G-02), or a safety-evaluated dual-agent negotiation release (DSN-04 §7). It can contain a lawful, sellable rental-automation product if scope is drawn to keep every regulated hazard out of the critical path.

## Decision
1. **MVP scope per [PLN-01](../planning/mvp-30-day.md):** self-managing landlords, one launch state, vendor-led screening, processor-held money flows (platform never custodies), deposits documented but never held, no user funds on-chain. The only chain element is the daily audit anchor (attestation on Base; platform-only transaction).
2. **MVP build stack:** single Next.js full-stack deployable + managed Postgres (RLS) + pg-backed queue, with module directories mirroring ARC-05 boundaries and the DSN-01 data model from day one. This is a **time-boxed concession to ADR-0003** (NestJS modular monolith), which remains the committed target; extraction trigger: dual-agent negotiation build start, stablecoin rails build start, or team ≥ 5 engineers — whichever first.
3. **Hard gate retained:** no client-facing lease without counsel-reviewed template and licensing posture memo. Calendar pressure never overrides C-O3.
4. **Increment renumbering:** PLN-01 replaces the Increment 0/1a boundary; 1b (on-chain settlement) and 1c (differentiators) keep their entry triggers unchanged.

## Consequences
- (+) Clients and revenue inside 30 days with TR-03/G-01/G-02/R-04/R-06 all outside the critical path; thesis DNA (audit chain, allowlist, rulesets, structured offers) ships rather than being deferred.
- (−) Day-30 product overlaps incumbent landlord tools; differentiation rests on the audit-trail story, AI assistance, and the roadmap until 1b/1c land.
- (−) Two build-stack migrations are pre-paid by discipline (module boundaries, shared data model) but still real work later.
- (−) KYC vendor integration deferred (processor covers payout identity); returns with stablecoin rails.

## Alternatives
Ship the full Increment 0+1a as documented — rejected: misses the 30-day directive by weeks. Launch with stablecoin rails anyway — rejected: violates C-T3 and TR-03 posture; unauditable in the window. Waitlist-only "launch" — rejected: does not satisfy "taking clients."
