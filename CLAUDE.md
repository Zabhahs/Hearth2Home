# CLAUDE.md — Hearth2Home / HomeChain

Auto-loaded every session, including every autonomous sprint tick. Read this first.

## What this is
An AI-mediated rental/home-buying platform settling money + milestones transparently. Full scope: [README.md](README.md). Architecture & decisions: [docs/INDEX.md](docs/INDEX.md).

## Current phase
Building the **30-day rental MVP** ([docs/planning/mvp-30-day.md](docs/planning/mvp-30-day.md)) via a **24/7 autonomous sprint** ([docs/ops/autonomous-operation.md](docs/ops/autonomous-operation.md)), 2026-06-15 → 2026-06-22. The brain is [sprint/sprint-state.json](sprint/sprint-state.json); the plan is [PLN-02](docs/planning/sprint-map.md).

## Hard invariants (never violate — these are the whole point)
1. **No custody of funds, ever.** Payments are processor-rail (Stripe-Connect-class); the platform never holds money. **Deposits are *documented*, never held.**
2. **Fair housing is deterministic and outside the model.** Matching/screening/listing-copy enforce an allowlist + HUD word rules in code. Protected-class attributes must be *unrepresentable* in feature schemas. An LLM never has final say on protected-class logic. (ADR-0009)
3. **Counsel-gated content stays a labeled placeholder.** Lease template text, adverse-action letter copy, WA ruleset legal values = `TODO(counsel: LGL-01)`. Build engines, not legal text.
4. **Backlog is the only work.** Implement only tasks in `sprint-state.json`. New ideas → [sprint/PROPOSED.md](sprint/PROPOSED.md); never build them. No scope creep.
5. **Nothing reaches `main` without the founder.** Branch + draft PR per task. Never merge or force-push.
6. **No secrets in git, no prod deploys, no destructive DB ops.** Secrets live in `.env.local` (gitignored) only. Schema changes are migration *files* in PRs — never applied to the live DB autonomously.

## Stack & conventions
- Next.js (App Router, TS strict) + Tailwind; Supabase (managed Postgres, RLS). Lean — no heavy ORM. (ADR-0019, ADR-0003)
- DB schema = [docs/design/data-model.md](docs/design/data-model.md) (DSN-01); types in `src/lib/supabase/database.types.ts`.
- Code modules mirror [ARC-05](docs/architecture/05-building-block-view.md) under `src/modules/*`.
- Leave every lane green: `npm run typecheck && npm run lint && npm run test`.

## Documentation-first rule
Any architectural/design change updates the matching doc in `docs/` in the same change set (new decisions → new ADR). Keep the traceability matrix ([ANL-01](docs/analysis/requirements-traceability-matrix.md)) and doc versions current. Don't write feature code beyond the assigned backlog task.
