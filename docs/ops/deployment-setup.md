# OPS-02 — Deployment & Go-Live Setup

| | |
|---|---|
| **Doc ID** | OPS-02 |
| **Version** | 0.1.0-draft · 2026-06-15 |
| **Status** | Draft for founder review |
| **Companion** | [OPS-01](autonomous-operation.md) (the fleet) · [PLN-02](../planning/sprint-map.md) (the plan) |

The one-time setup to take the repo from "pushed" to "auto-deploying + building 24/7." Three things: **Vercel** (app hosting), the **scheduled routine** (the fleet's heartbeat), and the **master switch**.

## 1. Hosting — already live

- **Database:** Supabase project `Hearth2Home` (`goquncvlqseejhfifuvm`, us-west-1). Schema applied (22 tables), types in `src/lib/supabase/database.types.ts`. Public keys in `.env.local` (gitignored).
- **Repo:** pushed to `github.com/Zabhahs/Hearth2Home`, `main` branch-protected (PR required; no force-push; admins included).

## 2. Vercel (app hosting) — one click + env vars

Vercel CLI isn't installed here and a non-interactive deploy needs a token, so the **Git integration** is the right path (it also gives auto-deploy on every merge — exactly what the fleet's PR→merge loop wants):

1. Go to **vercel.com → Add New → Project → Import** `Zabhahs/Hearth2Home` (team *zabhahs' projects*). Framework auto-detects as Next.js.
2. **Environment variables** (Project Settings → Environment Variables):
   | Key | Value | Scope |
   |---|---|---|
   | `NEXT_PUBLIC_SUPABASE_URL` | `https://goquncvlqseejhfifuvm.supabase.co` | All |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `sb_publishable_uJL29yt8eNAcSIf09LEHjQ_3OmqGin5` | All |
   | `SUPABASE_SERVICE_ROLE_KEY` | *(from Supabase dashboard → API → service_role)* | Production, Preview |
   | `DATABASE_URL` | *(Supabase → Database → connection string)* | Production, Preview |
   | `ANTHROPIC_API_KEY`, vendor keys | *(when available)* | as needed |
3. **Deploy.** From then on, **every merge to `main` auto-deploys**; every PR gets a preview URL (handy for reviewing the fleet's work from your phone).

> Alternative if you'd rather I CLI-deploy: provide a `VERCEL_TOKEN` and I'll `vercel link` + `vercel deploy` directly. Git integration is recommended over this.

## 3. The scheduled routine (the fleet's heartbeat)

The 24/7 cadence is a **scheduled cloud routine** (monitorable from the Claude mobile app — this is your "remote monitor from phone"):
- `/sprint-tick` every ~2 hours (the off-minute matters — see OPS-01 §8).
- `/sprint-digest` once each morning (~8am local).

**Where it runs.** A routine runs Claude Code against this repo. For *full-capability* ticks (DB-integration tests, Supabase MCP, `gh`), it needs the same environment this session has — your **PC2** with Claude Code signed in, the Supabase MCP connected, and `.env.local` present — or a cloud routine env with those secrets configured. Code-writing, tests that don't hit the live DB, and PR creation work in either. Add the Supabase + Anthropic keys to the routine's environment for the DB-dependent tasks.

## 4. The master switch — go live

Safety gate: the scheduled routine fires the tick, but **every tick no-ops until you flip the switch.** To start the real build:

1. **Merge the go-live config PR** (the one this setup opened) so `main` has the WA/King County posture, the tick start-gate fix, `.gitattributes`, and this doc.
2. **Set `meta.fleet_status` to `RUNNING`** in `sprint/sprint-state.json` (edit on GitHub from your phone, or ask Claude). That's it — the next tick begins picking tasks, spawning sub-agents, and opening PRs.

**To pause:** set it back to `PAUSED`. **To stop:** disable the routine.

## 5. Your daily loop (≈30–60 min, from your phone)

1. Read the morning **digest** notification.
2. **Review + merge** the fleet's draft PRs (preview URLs from Vercel make this visual).
3. **Clear any [INBOX](../../sprint/INBOX.md) blockers** (usually: a vendor key, or a "which way?" question).
4. Everything else runs itself. Merges auto-deploy.

## 6. Go-live checklist

- [x] Repo pushed; `main` protected
- [x] Supabase live; schema applied; public keys in `.env.local`
- [ ] Service-role key + `DATABASE_URL` pasted into `.env.local` (PC2) and Vercel
- [ ] Vercel project imported + env vars set (INBOX-5)
- [ ] Go-live config PR merged
- [ ] Scheduled routine created (tick + digest)
- [ ] `fleet_status` → `RUNNING` (the switch)
- [ ] Claude mobile app connected for digests/notifications
