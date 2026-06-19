# Sprint Backlog — Hearth2Home MVP (human-readable view)

> Machine-readable source of truth: [sprint-state.json](sprint-state.json). This file is the human mirror — the loop keeps both in sync each tick. **Agents may only work tasks listed here; new ideas go to [PROPOSED.md](PROPOSED.md), never built autonomously.**

**Autonomous window:** 2026-06-15 → 2026-06-22 · **Fleet status:** STAGED (not yet firing) · **Review gate:** branch + PR per task, founder merges.

## Status legend
`todo` · `in_progress` · `blocked` (waiting on a dependency or counsel) · `in_review` (PR open) · `done`

## Lane A — Platform
| ID | Task | Pri | Status | Deps | Model | Blocked on |
|---|---|---|---|---|---|---|
| T-001 | Repo scaffold (Next.js + Supabase) | 1 | ✅ done | — | sonnet | — |
| T-002 | Supabase project + apply 9 migrations | 1 | 🔄 in_progress | T-001 | opus | — |
| T-003 | CI pipeline (Actions) | 2 | todo | T-001 | sonnet | — |
| T-004 | Auth + session middleware + org/party bootstrap | 2 | todo | T-002 | opus | — |
| T-005 | Audit-log writer (hash chain) + tests | 2 | todo | T-002 | opus | — |
| T-006 | Config/secrets hardening (server-only) | 3 | todo | T-001 | sonnet | — |
| T-024 | Ruleset engine + WA v1 (placeholder values) | 3 | todo | T-002 | opus | counsel values |
| T-023 | Daily audit-anchor job (Merkle; chain optional) | 5 | todo | T-005 | sonnet | — |
| T-030 | Observability + PII-scrubbed logging | 5 | todo | T-004 | sonnet | — |
| T-033 | Seed/demo data + dev setup script | 4 | todo | T-002 | sonnet | — |

## Lane B — Listings & Matching
| ID | Task | Pri | Status | Deps | Model | Blocked on |
|---|---|---|---|---|---|---|
| T-010 | Org/properties/units CRUD + RLS tests | 2 | todo | T-004 | sonnet | — |
| T-011 | Listings + hosted public listing page | 3 | todo | T-010 | sonnet | — |
| T-012 | AI listing-copy + deterministic fair-housing lint | 4 | todo | T-011 | opus | — |
| T-013 | Tenant application intake → allowlisted fields | 3 | todo | T-002, T-004 | sonnet | — |
| T-014 | Tenant-side unit matching (explainable) | 4 | todo | T-013, T-011 | opus | — |

## Lane C — Transactions
| ID | Task | Pri | Status | Deps | Model | Blocked on |
|---|---|---|---|---|---|---|
| T-016 | Structured offer/counter forms (term-sheet rails) | 4 | todo | T-011, T-013 | sonnet | — |
| T-017 | Lease generation engine (template merge) | 4 | todo | T-005, T-024 | opus | counsel template |
| T-018 | E-sign adapter + WORM archival + hash | 5 | todo | T-017 | sonnet | — |
| T-019 | Rent schedules + ACH autopay + dunning + late-fee | 4 | todo | T-010, T-024 | opus | processor key (stub OK) |
| T-020 | Deposit documentation + timers + itemization | 5 | todo | T-019 | sonnet | — |
| T-021 | Condition reports (photo + ack) | 5 | todo | T-010 | sonnet | — |

## Lane D — Compliance & Surface
| ID | Task | Pri | Status | Deps | Model | Blocked on |
|---|---|---|---|---|---|---|
| T-015 | Screening adapter + FCRA adverse-action workflow | 3 | todo | T-013 | opus | counsel letter copy |
| T-022 | Landlord dashboard + AI lease explainer | 4 | todo | T-010, T-011, T-019 | sonnet | — |
| T-031 | Accessibility pass (WCAG 2.2 AA) | 6 | todo | T-011, T-022 | haiku | — |
| T-032 | Runbooks + status page stub | 6 | todo | — | haiku | — |

## Critical-path notes
- **Counsel is the real critical path.** T-017 / T-015 / T-024 build their *engines* autonomously but leave legal *content* as labeled placeholders until LGL-01 sign-off. The loop never stalls — it builds around the gate.
- **No-custody discipline:** T-019/T-020 must never hold funds or deposits (processor-rail + documentation only). This is a stop-condition-guarded invariant.
- **Fair-housing is deterministic:** T-012/T-013/T-014 enforce the allowlist outside the model (ADR-0009). A model never gets final say on protected-class logic.
