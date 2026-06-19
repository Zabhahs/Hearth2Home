# sprint/ — the autonomous fleet's working memory

This directory is the **durable brain** of the 24/7 build (see [OPS-01](../docs/ops/autonomous-operation.md)). Each scheduled tick rehydrates from here and writes back.

| File | Role |
|---|---|
| [sprint-state.json](sprint-state.json) | **Source of truth.** Tasks, status, deps, budget policy, model routing, stop conditions, inbox. Machine-read every tick. |
| [BACKLOG.md](BACKLOG.md) | Human-readable mirror of the task list (lanes A–D). |
| [INBOX.md](INBOX.md) | Items needing the founder (blockers, decisions). Check from your phone. |
| [PROPOSED.md](PROPOSED.md) | Scope-creep catcher — ideas the fleet noticed but must NOT build. |
| [token-ledger.jsonl](token-ledger.jsonl) | Per-tick token burn (governor reads this to pace against subscription caps). |
| `journal/` | Per-tick append-only logs (created at runtime). |
| `digest/` | Daily digests for the founder (created at runtime). |
| `.tick.lock` | Concurrency lock (created/removed at runtime). |

## Operating it
- **Status:** `meta.fleet_status` in `sprint-state.json` — currently **STAGED_NOT_RUNNING**. Nothing runs until the founder starts the loop ([OPS-01 §9](../docs/ops/autonomous-operation.md)).
- **One tick:** `/sprint-tick` · **Daily digest:** `/sprint-digest` (registered slash commands in `.claude/commands/`).
- **Pause:** set `meta.fleet_status` to `PAUSED`. **Resume:** set to `RUNNING` (or restart the routine).
- **Review loop:** the fleet opens draft PRs; the founder merges (~30–60 min/day). Nothing hits `main` autonomously.
