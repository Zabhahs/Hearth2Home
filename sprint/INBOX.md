# INBOX — items needing the founder

> The loop writes here when it hits a stop condition, a decision gate, or a blocker. Check this from your phone alongside the daily digest. Clear an item by acting on it and deleting the line (or the loop removes it once the blocker is resolved in `sprint-state.json`).

## Open now (seeded at setup)

- [ ] **INBOX-1 — Flip the master switch to go live.** The scheduled routine already fires `/sprint-tick`, but every tick **no-ops until `meta.fleet_status` in `sprint-state.json` == `RUNNING`.** To start the real build: merge the go-live config PR, then set `fleet_status` to `RUNNING` (one edit — do it from your phone, or ask Claude to). See [OPS-01 §9](../docs/ops/autonomous-operation.md).
- [x] **INBOX-2 — Counsel: DEFERRED (your call, 2026-06-15).** Building the MVP without counsel. Engage with [LGL-01](../docs/legal/counsel-engagement-brief.md) **before taking real clients** to confirm lease template + adverse-action copy + WA/King County ruleset values. The fleet builds engines + labeled placeholders meanwhile and never blocks.
- [x] **INBOX-3 — Launch jurisdiction: RESOLVED.** Washington, **King County (incl. Seattle)**. Seattle first-in-time + fair-chance overlays are in scope; rulesets target them (values TODO counsel).
- [ ] **INBOX-4 — Vendor sandbox keys (when ready).** Screening CRA, e-sign, payment processor (Stripe-Connect-class), Anthropic API. Adapters run against stubs until these arrive — paste into Vercel env / `.env.local`, never commit.
- [ ] **INBOX-5 — Connect Vercel (one click).** Import the GitHub repo at vercel.com → New Project, set the env vars from [docs/ops/deployment-setup.md](../docs/ops/deployment-setup.md). After that, every merge to `main` auto-deploys.

## How the loop uses this file
- Stop condition hit → loop appends an item here, sets the task to `in_review`/`blocked`, and pushes a notification (OPS-01 §6).
- It will keep making progress on *other* ready tasks while an item sits here — a blocker parks one task, it does not halt the fleet.
