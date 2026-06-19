# ADR-0003 — Modular Monolith on NestJS/TypeScript

**Status:** Proposed (recommendation; scope offered NestJS or FastAPI) · 2026-06-11

## Context
README §6.2 lists Node/TS (NestJS) **or** Python (FastAPI). Frontend is Next.js + TypeScript; mobile is React Native. Team is presumed small (C-O4). The system has many modules but one team and one deploy cadence.

## Decision
One NestJS (TypeScript) modular monolith for the Core plane, with module boundaries enforced (lint rules + module-scoped DB schemas) exactly along the container lines of ARC-05. AI plane and Integration plane run as separate worker deployments of the same codebase (isolation without polyglot cost).

## Consequences
- (+) Single language end-to-end (web, mobile, API, contracts tooling) — shared types/DTOs, one hiring profile.
- (+) NestJS module system + DI matches the enforced-boundary strategy; later extraction is mechanical.
- (−) Python ML ecosystem not natively at hand — acceptable: AI is API-based (Claude, vision APIs), not self-hosted models. If self-hosted ML appears later, it becomes a separate Python service behind an interface.
- (−) Monolith discipline must be enforced in review; boundary-violation lint is CI-blocking.

## Alternatives
FastAPI — rejected: splits the stack into two languages for no MVP gain. Microservices — rejected: operational overhead unjustified at this team size; revisit at >~12 engineers.
