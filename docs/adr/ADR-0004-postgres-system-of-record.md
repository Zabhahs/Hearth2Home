# ADR-0004 — PostgreSQL System of Record; Minimal Trust Kernel On-Chain

**Status:** Accepted · 2026-06-11

## Context
Scope mandates: mutable listing data off-chain (Module C "M" row), only trust-events on-chain (Module E "M" row), privacy concerns on public chains (R-02), county as title authority (R-01).

## Decision
PostgreSQL is the system of record for all business state. The chain is the system of record for exactly four things: **escrowed funds, payment settlement events, attested milestones, and commitments/references** (listing/bid commitments, terms hashes, deed references, audit anchors). Nothing else ever goes on-chain.

## Consequences
- (+) Smallest possible audited contract surface; PII never on-chain (Q4); fraud reversibility preserved.
- (+) Product iteration speed: schema changes don't touch contracts.
- (−) Dual sources of truth require the consistency machinery of ARC-08 §8.4 (indexer, outbox, finality policy, reconciliation) — this is the tax, paid once, centrally.

## Alternatives
Chain-primary state — rejected: privacy, mutability, legal reversibility all fail. Event-sourced store — deferred: the audit log already gives an event spine; full ES adds complexity without an MVP driver.
