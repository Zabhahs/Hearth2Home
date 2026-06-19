# PLN-01 — 30-Day MVP Definition ("Take Clients in 30 Days")

| | |
|---|---|
| **Doc ID** | PLN-01 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |
| **Governing decision** | [ADR-0019](../adr/ADR-0019-mvp-30-day-concessions.md) |
| **Supersedes-in-part** | ARC-04 §4.3 increment boundaries (Increment 0/1a merged & re-scoped) |

## 1. The MVP in One Sentence

**AI-powered leasing and rent automation for self-managing landlords in one launch state:** list a unit → screen applicants (vendor-led, FCRA-compliant) → generate + e-sign an attorney-reviewed lease → collect rent by ACH autopay → document deposits and move-in condition — every step on the tamper-evident, chain-anchored audit trail.

## 2. The Shaping Insight — Step Around Every Blocker

The 30-day scope is drawn so that **none of the three legal blockers (ANL-02) and neither existential licensing risk is in the critical path**:

| Hazard | How the MVP avoids it entirely |
|---|---|
| TR-03 / G-03 custody & money transmission | Payments run on a **PayFac partner model (Stripe Connect-class)**: tenant ACH debit settles to the landlord's connected account; the platform **never holds funds**; payout-side KYC is the processor's regulated function |
| G-02 deposit statutes | The platform **does not hold deposits**. It records amount/location/dates, runs statutory timers, and generates itemization letters — deposits stay wherever the landlord lawfully holds them today |
| G-01 FCRA | **Vendor-led, tenant-initiated screening** (SmartMove-class): the CRA runs consent and report delivery; the platform supplies adverse-action notice workflow and templates (DSN-06 §6) |
| R-04 brokerage licensing | Serve **self-managing landlords only** (Priya): the platform is software used by the principal — no negotiating on others' behalf, no commissions, no showings. Property managers (Marcus) deferred (G-05 posture memo from counsel before adding them) |
| R-06 contract exploit | **No user funds touch a contract.** The only on-chain element is the daily audit-log Merkle anchor, written as an attestation on Base (EAS-class, platform-only transaction, zero fund risk) — C-T3 ("audit before mainnet funds") is not triggered |
| R-05 fair housing | No scoring of *people* at MVP: tenant-side **unit matching** only (scoring properties for tenants is the safe direction); applicant views show objective, uniform, lawful facts; deterministic ad-copy lint (HUD word list) on AI-generated listings; ADR-0009 allowlist discipline from day one |

This keeps the company sellable in 30 days while the regulated differentiators (stablecoin escrow, dual-agent negotiation) proceed on their own gated tracks.

## 3. Scope

### In (Day-30 client-facing)

| Capability | Notes |
|---|---|
| Landlord onboarding + processor connect | Org/property/unit models; processor onboarding doubles as payout KYC |
| Listings + hosted listing page | Photos, terms; AI listing-copy assistant behind deterministic fair-housing ad lint |
| Tenant application intake | Conversational AI intake (allowlisted fields) with plain-form fallback |
| Tenant-side unit matching | Rule-based, explainable (ADR-0010); per-feature "why this match" |
| Screening | Vendor-led flow; adverse-action letter generation + delivery tracking |
| Structured offer / counter forms | The term-sheet rails (human-driven at MVP — agents plug in later, DSN-04 §2 schema reused) |
| Lease generation + e-sign | Attorney-reviewed template, **one state**, ruleset-parameterized (ADR-0013); executed docs hashed + archived |
| ACH rent autopay | NACHA authorization UX, retries, jurisdiction-aware late-fee math, notices (Rail Router with one rail) |
| Deposit documentation | Amount, holding location, statutory timers, itemization letter generator — **never held** |
| Move-in/out condition reports | Web photo upload, timestamps, both-party acknowledgment (geo attestation deferred) |
| Audit trail | Hash-chained log (ADR-0012) + daily Merkle anchor on Base via existing attestation infrastructure |
| Landlord dashboard + AI lease explainer | Plain-language summaries flagged assistive-not-advice |

### Out (with re-entry trigger)

| Deferred | Trigger to build |
|---|---|
| Stablecoin escrow/rent, custody, smart accounts | Custody counsel decision (O-3) + contract audit + custody partner live → Increment 1b |
| Dual-agent AI negotiation | Eval harness + injection corpus green (DSN-04 §7) → Increment 1c |
| Deposit custody (on-chain or otherwise) | Per-state legality (O-5) |
| Mobile app / geo-attested walkthrough | Increment 1c |
| Property managers / agency relationships | Counsel posture memo (G-05) |
| On-chain listing/bid commitments | Founder decision O-4 (Phase-1 gate) |
| KYC vendor integration | Returns with stablecoin rails (driver is C-L2 money movement; processor covers payout identity at MVP) |
| Phase-2 anything | Per ADR-0001 |

## 4. MVP Build Stack (ADR-0019)

Next.js full-stack app (single deployable) on managed hosting + managed Postgres with RLS (Supabase/Vercel-class — both already in the founder's tooling), pg-backed job queue for sagas-lite, S3 Object Lock bucket for executed-document WORM copies (e-sign vendor's tamper-sealed copy is the primary evidentiary artifact at MVP). Module directories mirror ARC-05 container boundaries so the NestJS extraction (ADR-0003) is mechanical when the trigger hits. The data model is DSN-01 from day one — **no schema rewrite later**.

## 5. Four-Week Plan (assumes 2–3 full-time builders + founder; counsel engaged Day 1)

| Week | Engineering | Legal/ops parallel track |
|---|---|---|
| 1 | App skeleton: auth, orgs/properties/units, audit-log schema + hash chain; landlord onboarding + processor connect; vendor accounts opened | **Counsel engaged Day 1**: launch-state confirmation, lease template review started, ToS/privacy, licensing posture memo (software-not-brokerage), city-overlay check |
| 2 | Listings + photos + hosted page; application intake (AI + form); screening integration + adverse-action workflow; ad-copy lint | Template iteration; adverse-action letters reviewed; pricing decision (O-7) |
| 3 | Lease generation (template merge + ruleset params) + e-sign + WORM archival; rent schedules + ACH autopay + dunning/late-fee math + notices | Counsel sign-off on template & notices (**hard gate**); design-partner outreach (5–10 landlords from founder network) |
| 4 | Deposit documentation + itemization; condition reports; matching + explanations; daily chain anchoring; dashboards; hardening, a11y pass, runbooks | Pilot onboarding (concierge, per R-11); support playbook; Day-30: first design-partner clients live |

**Launch definition:** closed design-partner cohort, not open signup — concierge onboarding, feedback loop, compliance surface kept small until hardened.

## 6. Critical Path & Honest Risks of the 30-Day Shape

1. **Counsel is the critical path, not code.** Lease template + posture memo in ≤3 weeks requires engaging a firm Day 1 (rush fees if needed). **Non-negotiable rule: no clients on an unreviewed lease — if counsel slips, launch slips.**
2. **Differentiation risk:** Day-30 feature set overlaps incumbent landlord tools (Avail/TurboTenant-class). Mitigation: design partners sold on the audit-trail trust story + AI assistance now and the settlement/agent roadmap next; founder-network distribution.
3. **City overlays:** if launch state is WA (recommended — founder home state, §11.2a), Seattle adds first-in-time and fair-chance screening rules; either implement first-come ordering or restrict pilot outside Seattle initially — counsel call.
4. **Scope discipline:** the cut list in §3 is the plan; anything re-entering before Day 30 displaces something.
5. **Team assumption:** with fewer than ~2 experienced full-stack builders, cut the AI listing assistant and condition reports first; the core loop (list → screen → lease → rent) is the irreducible MVP.

Illustrative cash needs (30 days): counsel $10–25k; vendors usage-based (screening cost borne by applicant in the tenant-initiated model); infra < $500/mo. Engineering is the dominant cost.

## 7. What This Sets Up (no dead ends)

- Offer forms = the negotiation term-sheet rails; agents attach later without UX rework.
- Ruleset engine, audit chain, allowlisted feature store, and DSN-01 entities ship in MVP form — the full architecture grows from them, not beside them.
- Contracts (DSN-02) continue on Base Sepolia in parallel, unblocked, heading for audit when O-3/O-5 resolve.
- Day-30 KPI seed for the Phase-1 gate: landlords onboarded, units under rent automation, lease cycle time (DR-9 measurable immediately), % leases fully executed in-platform.
