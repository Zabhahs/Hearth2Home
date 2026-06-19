# ADR-0018 — ACH Fiat Rail Ships at Launch Alongside Stablecoin

**Status:** Proposed · 2026-06-11

## Context
Three independent pressures: (1) adoption — Phase-1 tenants/landlords largely do not hold stablecoins; an on-ramp-only funnel is a conversion cliff; (2) resilience — issuer freeze (R-08) and sequencer outage (TR-08) need a settlement path that keeps legal obligations whole (Q6-1); (3) law — some jurisdictions restrict mandating electronic-only/crypto-only rent payment (C-L13).

## Decision
A fiat ACH rail (licensed payment partner) is a **launch requirement**, not a Phase-2 add-on. The Rail Router selects per lease/state/party capability; the internal double-entry ledger records obligations rail-agnostically. Stablecoin remains the strategic rail (escrow programmability, settlement transparency, throughput-fee economics); ACH is the availability and adoption floor. On-ramp integration (fiat → stablecoin) is layered in Increment 1b so users can graduate rails without re-onboarding.

## Consequences
- (+) Revenue does not wait for crypto adoption (Increment 1a monetizes on ACH); freeze/outage runbooks have a real fallback; jurisdiction objections answered.
- (−) Dual-rail reconciliation complexity (already owned by the Reconciliation component); NACHA compliance via partner.
- (−) Discipline required so the fallback doesn't quietly become the only rail and hollow out the thesis — tracked as a product KPI (% units settling on-chain) at the Phase-1 gate.

## Alternatives
Stablecoin-only — rejected: conversion cliff + R-08/TR-08 single-rail fragility + C-L13. Fiat-only MVP — rejected: abandons the differentiating settlement thesis.
