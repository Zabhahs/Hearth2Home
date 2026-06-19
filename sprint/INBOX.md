# INBOX — items needing the founder

> The loop writes here when it hits a stop condition, a decision gate, or a blocker. Check this from your phone alongside the daily digest. Clear an item by acting on it and deleting the line (or the loop removes it once the blocker is resolved in `sprint-state.json`).

## Open now (seeded at setup)

- [ ] **INBOX-1 — Start the loop.** When PC2 + phone remote are live, run the start procedure in [OPS-01 §9](../docs/ops/autonomous-operation.md). Nothing burns tokens until you do.
- [ ] **INBOX-2 — Engage counsel Day 1.** Send [counsel-engagement-brief.md (LGL-01)](../docs/legal/counsel-engagement-brief.md). Lease-template sign-off is the hard gate for the legal *content* of T-017 / T-015 / T-024.
- [ ] **INBOX-3 — Confirm launch state.** Washington recommended. Decide whether Seattle is in or out of the pilot (first-in-time + fair-chance ordinances add rules).
- [ ] **INBOX-4 — Vendor sandbox keys (when ready).** Screening CRA, e-sign, payment processor (Stripe-Connect-class), Anthropic API. Adapters are built against stubs until these arrive — paste them into Vercel/`.env.local`, never commit.

## How the loop uses this file
- Stop condition hit → loop appends an item here, sets the task to `in_review`/`blocked`, and pushes a notification (OPS-01 §6).
- It will keep making progress on *other* ready tasks while an item sits here — a blocker parks one task, it does not halt the fleet.
