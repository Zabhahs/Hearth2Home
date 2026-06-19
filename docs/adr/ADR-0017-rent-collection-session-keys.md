# ADR-0017 — Rent Collection via Scoped Session Keys / Allowances

**Status:** Accepted (corrects the mechanism implied by README §4.4) · 2026-06-11

## Context
The scope describes "scheduled stablecoin pulls from tenant wallet". ERC-20 has no native pull-payment: a third party can move tokens only within a holder-granted allowance, or the holder's signer must initiate. An unbounded allowance to a platform contract would be a serious fund-safety anti-pattern; a custodian silently pushing from user accounts maximizes custody/licensing exposure (ADR-0007).

## Decision
Tenant smart accounts (ERC-4337) grant a **scoped session key / allowance** to the PaymentRouter at lease activation, cryptographically bounded to: amount ≤ rent (+ lawful fees ceiling), frequency ≤ schedule, payee = the lease's escrow/landlord route, expiry = lease term. Each rent run executes within that envelope; renewal/amendment re-issues the grant. Revocation is the tenant's right (UI-exposed); a revoked grant moves the lease onto the missed-payment/dunning timeline per ruleset — never a forced transfer.

## Consequences
- (+) "Automatic rent collection" delivered with provable bounds — auditable, custody-minimizing, and honest in disclosures.
- (+) Q2-1 holds: even a compromised orchestrator cannot exceed the envelope; custody provider policy independently mirrors the bounds.
- (−) Grant lifecycle management (expiry, re-grant at renewal, amount changes on lawful rent increases) is real product work — owned by the Payments Orchestrator.

## Alternatives
Unbounded ERC-20 approve — rejected (fund safety). Custodian-initiated push without scoped grants — rejected (licensing posture + trust optics). Invoice-and-pay each month (no automation) — rejected: loses the core automation value; retained as the fallback when a grant lapses.
