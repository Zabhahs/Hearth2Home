# INBOX — items needing the founder

> The loop writes here when it hits a stop condition, a decision gate, or a blocker. Check this from your phone alongside the daily digest. Clear an item by acting on it and deleting the line (or the loop removes it once the blocker is resolved in `sprint-state.json`).

## Open now (seeded at setup)

- [x] **INBOX-1 — Fleet is RUNNING (launched 2026-06-15).** Tick-1 merged PRs #3/#4/#5 green; the scheduled tick continues every 2h at :07. Keep this machine's Claude app open for 24/7. Optional: "Run now" the `hearth2home-sprint-tick` task once to pre-approve its tool permissions so unattended runs never pause.
- [x] **INBOX-2 — Counsel: DEFERRED (your call, 2026-06-15).** Building the MVP without counsel. Engage with [LGL-01](../docs/legal/counsel-engagement-brief.md) **before taking real clients** to confirm lease template + adverse-action copy + WA/King County ruleset values. The fleet builds engines + labeled placeholders meanwhile and never blocks.
- [x] **INBOX-3 — Launch jurisdiction: RESOLVED.** Washington, **King County (incl. Seattle)**. Seattle first-in-time + fair-chance overlays are in scope; rulesets target them (values TODO counsel).
- [ ] **INBOX-4 — Vendor sandbox keys (when ready).** Screening CRA, e-sign, payment processor (Stripe-Connect-class), Anthropic API. Adapters run against stubs until these arrive — paste into Vercel env / `.env.local`, never commit.
- [x] **INBOX-5 — Vercel: LIVE.** https://hearth2home.vercel.app (Git integration connected → every merge to `main` auto-deploys). ⚠️ **Two production env vars are PLACEHOLDERS** — replace `SUPABASE_SERVICE_ROLE_KEY` and `DATABASE_URL` in Vercel (Project → Settings → Environment Variables) with real values from the Supabase dashboard before any server/admin feature relies on them. Also **rotate the Vercel token** shared in chat (vercel.com/account/tokens).

## How the loop uses this file
- Stop condition hit → loop appends an item here, sets the task to `in_review`/`blocked`, and pushes a notification (OPS-01 §6).
- It will keep making progress on *other* ready tasks while an item sits here — a blocker parks one task, it does not halt the fleet.
