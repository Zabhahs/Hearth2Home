---
description: Produce the daily sprint digest for the founder's phone — merged, in-review, blocked, burn, today's plan.
model: haiku
---

# Sprint Digest — the founder's morning view

You were invoked to summarize sprint status for a founder with ~30–60 min/day, reading on a phone. Be short, skimmable, action-first. Do **not** change any code or task status.

## Steps
1. Read `sprint/sprint-state.json`, the last day of `sprint/token-ledger.jsonl`, `sprint/INBOX.md`, and `gh pr list` (open PRs with links).
2. Write `sprint/digest/<YYYY-MM-DD>.md` and emit the same content as the notification body.

## Format (keep it to one screen)
```
# Hearth2Home — Daily Digest <date> · Day N/7

## ✅ Merged since yesterday
- <PR title> (T-xxx)

## 👀 Needs you (do these first)
- MERGE: <PR link> — <one line>
- ANSWER: <INBOX item — the specific question>

## 🚧 Blocked (parked, fleet continues elsewhere)
- T-xxx — <why, what unblocks it>

## 🔄 In progress / planned today
- <lane>: T-xxx, T-xxx

## 📊 Tokens
- Last 24h: ~<n> · current window: <n>/<cap> · throttled: <yes/no>

## One-liner
<e.g. "Foundation lanes green; listings+matching landing today; counsel sign-off is the only hard blocker.">
```

Rules: lead with what the founder must do (merge/answer). If nothing needs them, say so explicitly. Never invent progress — report only what `sprint-state.json` and `gh pr list` show.
