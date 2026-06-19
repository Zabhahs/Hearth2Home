# ADR-0001 — Rental Automation First; Home-Buying Second

**Status:** Founder-directed (recorded) · 2026-06-11

## Context
The scope (README §1, §3.2, §9.1) sequences the product: Phase 1 rentals (recurring revenue, lighter licensing, faster cycles), Phase 2 home-buying (higher per-deal revenue, heavier regulatory load).

## Decision
Architecture treats rental flows as the primary load-bearing path. Phase-2 components (DeedReference NFT, closing pipeline, RON/e-recording connectors) are designed now (ARC-06 R7) but nothing in Phase 1 depends on them.

## Consequences
- (+) Phase-1 deployable without any Phase-2 vendor or licensing dependency (C-O1).
- (+) Escrow/lease/oracle components are shared — Phase 2 reuses the kernel.
- (−) Some Phase-1 designs carry forward constraints chosen for Phase-2 compatibility (e.g., milestone tiers sized for closing flows).

## Alternatives
Build both simultaneously — rejected: doubles regulatory surface before first revenue.
