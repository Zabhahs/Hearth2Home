# ADR-0015 — Saga Orchestration + Transactional Outbox for the Transaction Pipeline

**Status:** Proposed (engine choice spiked in Increment 0) · 2026-06-11

## Context
A lease or closing spans days, two humans, several vendors, and a blockchain — every step can fail independently, and human approval gates park flows for hours. Naive request/response logic cannot model this; the 48 h cycle-time objective (DR-9) depends on flows resuming, not restarting.

## Decision
All multi-step business transactions (lease funding, rent runs, deposit return, dunning, closing) are **durable sagas**: explicit state machines with persisted state, idempotent steps keyed by idempotency tokens, compensation actions, timeout/escalation policies, and human gates as first-class waiting states. Every DB-change-plus-external-effect uses the **transactional outbox**.

Engine: evaluate a durable workflow engine (Temporal-class) vs. a Postgres/queue-backed state machine in an Increment-0 spike. Decision criteria: operational burden at team size, visibility tooling, testability of compensation paths. The saga *model* is binding; the engine is swappable.

## Consequences
- (+) Partial failure becomes routine handled state, not incident; chaos-testable (ARC-08 §8.8).
- (+) DEFERRED_CHAIN and freeze states (R5/R-08) are just saga states — no special-case machinery.
- (−) Engineering discipline cost: every external call must be idempotent and compensable; this is the single biggest backend convention to enforce.

## Alternatives
Event choreography (no orchestrator) — rejected: money flows need a single accountable state machine per transaction for audit (Q1-1). Synchronous orchestration — rejected: human gates and chain finality make long waits the norm.
