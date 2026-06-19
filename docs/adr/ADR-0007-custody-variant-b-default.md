# ADR-0007 — Custody Variant B (Licensed Partner) by Default

**Status:** Proposed — **counsel decision required** · 2026-06-11

## Context
Scope mandates custodial UX (users never touch keys/gas, §4.1, §6.2). But *who custodies* is a licensing question the scope does not answer: a platform holding customers' stablecoins may be a money transmitter / custodian under state law (WA flagged as MT-cautious, README §11.2a). This is the rental-side cousin of R-04 — an unlicensed-activity risk (logged as TR-03, exposure 16).

## Decision
Two variants are designed; **Variant B is the default until counsel clears Variant A per state**:

- **Variant A — platform custody:** platform controls signing via an MPC/HSM custody technology provider; platform is principal. Requires per-state MT/custody licensing analysis (and possibly licenses).
- **Variant B — partner custody:** a licensed custodian/qualified financial partner holds user accounts and keys; the platform orchestrates via API and policy but never takes possession or control of customer funds. ERC-4337 smart accounts still give the UX (session keys, paymaster), with the partner as signer of record.

The Payments Orchestrator and PaymentRouter are written against a **custody-agnostic interface** so the variant is a deployment/legal choice, not an architectural fork.

## Consequences
- (+) Eliminates the accidental-money-transmission failure mode at launch; faster time-to-market.
- (+) Custody provider's independent policy engine double-enforces transfer limits (Q2-1 defense in depth).
- (−) Partner dependency: fees, onboarding SLAs, outage coupling (Q6-2 runbook); partner due diligence required.
- (−) Some product flexibility (exotic flows) constrained by partner policy.

## Alternatives
Variant A from day one — rejected pending counsel: licensing exposure could be existential. Non-custodial (user-held keys) — rejected: violates the scope's UX mandate and the target persona's tolerance.
