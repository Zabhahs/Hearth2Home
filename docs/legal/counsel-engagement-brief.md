# LGL-01 — Counsel Engagement Brief (Rental MVP)

| | |
|---|---|
| **Doc ID** | LGL-01 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | **Draft for founder review — not legal advice** |
| **Audience** | Real-estate + fintech/payments attorney engaged Day 1 of the 30-day MVP sprint |
| **Prepared by** | Founder (HomeChain / Hearth2Home) |
| **Engagement target** | Lease-template sign-off + licensing-posture memo within ~3 weeks |
| **Source docs** | [PLN-01](../planning/mvp-30-day.md) (30-day MVP), [DSN-06](../design/compliance-and-audit.md) (compliance & audit), [ANL-02](../analysis/gap-analysis.md) (gap analysis), [ARC-02](../architecture/02-constraints.md) (legal constraints), [ANL-04 §5](../analysis/validation-report.md) (open items) |

> **Purpose & read order.** We are a software startup building rental-automation software for self-managing landlords. We intend to take our first design-partner clients within 30 days, in a single launch state. The single hard gate on that timeline is an attorney-reviewed lease template plus a written licensing-posture memo. This brief tells you what the MVP does (and deliberately does **not** do), proposes the launch jurisdiction, and gives you a prioritized, concrete question list. Everything in this document is the founder's understanding for your review — it is **not** itself legal advice, and the figures and statutory references are illustrative pending your confirmation.

---

## 1. Product Summary for Counsel

HomeChain's 30-day MVP is **leasing-and-rent-automation software used by a self-managing landlord on their own property**: the landlord lists a unit, the prospective tenant initiates a third-party background/credit screening, the landlord generates and the parties e-sign an attorney-reviewed lease, the tenant sets up rent autopay, and the platform documents the security deposit and the move-in condition — every step written to a tamper-evident audit log. It is positioned, structurally, as a tool the principal operates for themselves, not as an intermediary acting on others' behalf.

The MVP is **deliberately drawn to keep three regulated hazards — money transmission, security-deposit trust statutes, and real-estate brokerage licensure — out of the critical path.** Concretely, in this MVP the platform:

- **Takes no custody of funds and holds no deposits.** Rent moves over a **third-party payment-processor rail (Stripe-Connect-class PayFac model)**: the tenant's ACH debit settles **directly to the landlord's own connected account**; the platform never receives, holds, or directs customer money, and payout-side identity verification is the regulated processor's function (PLN-01 §2; ARC-02 C-L8; [ADR-0007](../adr/ADR-0007-custody-variant-b-default.md)).
- **Documents deposits but never holds them.** The platform records the deposit amount, where the landlord holds it, and the statutory deadlines, and generates the itemization letter — the money stays wherever the landlord lawfully holds it today (PLN-01 §3; ANL-02 G-02; DSN-06 §3).
- **Does not run screening itself.** Screening is **tenant-initiated and vendor-led** (a consumer reporting agency of the SmartMove class runs consent and report delivery); the platform supplies the adverse-action notice workflow and templates only (PLN-01 §2; DSN-06 §6).
- **Serves self-managing landlords only.** No negotiating on another party's behalf, no commissions, no showings, no acting for a client — the platform is software used by the property's principal. Third-party property managers are deferred pending your posture memo (PLN-01 §3; ANL-02 G-05).
- **Conducts no brokerage activity and moves no money on-chain.** The only blockchain element is a once-daily cryptographic anchor of the platform's own audit log (an attestation transaction the platform itself signs); **no user funds ever touch a smart contract** (PLN-01 §2; ADR-0019).

Everything regulated-and-heavier — stablecoin escrow, on-chain deposits, custodial wallets, and AI dual-agent negotiation — is explicitly **out of this MVP** and gated behind later increments and your sign-off (PLN-01 §3 "Out"; ARC-02 C-L2/C-L7/C-L8). The questions in §3 are scoped to the MVP as described above; the AI questions in topic (h) and the agent-feature note are flagged forward-looking where they exceed it.

---

## 2. Jurisdiction — Recommended Launch State

**We recommend Washington State as the single launch state** and ask you to confirm it or advise a better alternative for a software-first rental MVP.

- **Why WA:** founder's home state; it has a published electronic real-property recording standard (WAC 434-661) and recognized e-signatures/e-records, which fits the "software documents the transaction" posture; landlord-tenant law (RCW 59.18) is well-developed and reasonably legible (README §11.2a; ARC-02 C-L9).
- **Specific sub-question we want answered, not assumed — Seattle city overlays.** Seattle layers two ordinances on top of state law that directly touch MVP features: (i) the **first-in-time / "first qualified applicant"** rule (screening and applicant ordering), and (ii) the **fair-chance housing** ordinance (limits on criminal-history use in screening). We need to know whether to (a) implement first-come applicant ordering and fair-chance-constrained screening from day one, or (b) restrict the pilot to WA **outside** Seattle initially (PLN-01 §6.3). This is a launch-blocking implementation decision.
- **What we need from you:** confirm WA is workable for a software-only, no-custody, self-managing-landlord MVP — or, if another single state is materially cleaner for this posture (lighter leasing-license exposure, simpler deposit-documentation duties, fewer city overlays), name it and say why. One state only at MVP; the ruleset is built per-state, so the choice gates which statutory parameters we encode (ARC-02 C-L7; [ADR-0013](../adr/ADR-0013-compliance-as-configuration.md); ANL-04 O-2).

---

## 3. Prioritized Question List

Questions are grouped by topic and ordered so the **lease-template and licensing-posture items (A, B) — the Week-3 hard gate — come first.** Each row states the concrete question, **why it matters**, and **which MVP feature it gates.** "Gate" means: if the answer is adverse, that feature changes or is pulled before launch. Topic I collects five additional exposure questions surfaced during the architecture review; they are lower-urgency than A–H but should be addressed before a full public launch.

### (A) Brokerage / Licensing Posture — *highest priority, gates the whole MVP*

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| A1 | In WA, does providing leasing-and-rent-automation **software to a self-managing landlord operating on their own property** require a real-estate or property-management license, given no negotiating for others, no commissions, and no showings? | This is the existential question (README R-04). If "software for the principal" needs a license, the MVP business model breaks. | Entire MVP go/no-go; "self-managing landlords only" scope (PLN-01 §3) |
| A2 | What specific activities would **cross the line** from unlicensed software into licensed brokerage/property-management activity in WA — e.g. the platform communicating offers/counters, "showing," collecting a fee contingent on a lease, or holding a key? | We need bright lines to design feature gating against (DSN-06 §1 activity gating; ARC-02 C-L5). | Structured offer/counter forms; any future "concierge" assistance; the line for Increment-1c agent features |
| A3 | Does it change the analysis that the platform **generates the lease document and the rent-payment instruction** (vs. the landlord doing it manually)? Is document automation "the unauthorized practice of law" or unlicensed activity in any respect? | Document generation is a core MVP feature; UPL is a distinct risk from brokerage licensure. | Lease generation + e-sign; AI lease explainer (assistive-not-advice) |
| A4 | Confirm the **third-party property-manager / agency** path is correctly deferred — i.e. adding Marcus-type users (managing others' units) is what would trigger licensure, and should wait for a posture memo. | Validates the deferral decision and the re-entry trigger (ANL-02 G-05; PLN-01 §3 "Out"). | Property-manager onboarding (deferred); confirms it stays out |

### (B) Lease Template & Required Disclosures / Addenda — *Week-3 hard gate*

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| B1 | Provide / sign off on a **WA residential lease template** suitable for self-managing landlords. Which clauses must be **attorney-drafted and fixed**, vs. which may be **safely parameterized** by our ruleset (e.g. rent, term, late-fee formula within statutory caps, deposit amount, pet terms)? | The template is the launch gate (PLN-01 §6.1). We need to know the fixed/variable boundary to build the ruleset correctly ([ADR-0013](../adr/ADR-0013-compliance-as-configuration.md); DSN-06 §3). | Lease generation engine (parameter families); ruleset sign-off |
| B2 | Which **disclosures and addenda are mandatory** for a WA residential lease — including the **federal lead-based-paint disclosure + EPA pamphlet for pre-1978 housing** — and which must be presented/acknowledged at or before signing? | Missing a mandatory disclosure can void terms or create liability; lead-paint is a federal must (DSN-06 §3, §7 disclosure inventory). | Disclosure inventory; e-sign ceremony ordering; condition-report acknowledgment |
| B3 | Are there WA-specific **mandatory notice forms / timing** (rent increase, entry, nonpayment, termination) we must generate and that the lease should reference? Any required statutory summary/handbook attachment? | Our notice generator and late-fee math must match statute exactly (DSN-06 §3 notices; ARC-02 C-L13). | Notice generation; jurisdiction-aware late-fee automation; ACH dunning notices |
| B4 | Any **rent-control / increase-cap or just-cause** constraints at WA-state or Seattle level we must encode (caps, notice windows, prohibited-increase periods)? | "Auto rent-increase logic" must be lawful or it is a liability, not a feature (README §4.4; ARC-02 C-L7). | Rent-increase logic; renewal/amendment flow |

### (C) FCRA Adverse-Action Workflow + WA/Seattle Fair-Chance + Portable Screening

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| C1 | Is our **adverse-action workflow adequate** for a tenant-initiated, vendor-led model: when a decline (or approve-with-conditions) is based wholly or partly on a screening report, we generate a notice carrying the **CRA name/address/phone, right to a free report, dispute rights, and risk-score factors where applicable**, delivery-tracked? Does the **landlord-initiated decline** correctly route through the same workflow so no un-noticed adverse action can be emitted? | FCRA non-compliance is a per-violation statutory-damages risk and a documented blocker (ANL-02 G-01; DSN-06 §6). | Screening integration; adverse-action letter generation + delivery tracking |
| C2 | Because screening is **tenant-initiated and the CRA runs consent/permissible purpose**, does the **platform itself** incur any FCRA obligations (e.g. as a user of consumer reports, or by transmitting report data), or do they sit with the landlord and the CRA? | Determines whether we need our own FCRA compliance posture or are purely a workflow tool (ARC-02 C-L6; DSN-06 §1 FCRA row). | Whether platform needs its own FCRA program vs. template-only |
| C3 | How do **Seattle fair-chance housing** rules constrain the **content and display** of screening results (criminal-history use/exclusion) we may show the landlord, and what applicant-facing language/process is required? | We must filter what the applicant-view surfaces and how declines are justified (DSN-06 §1 fair-chance overlay; PLN-01 §6.3). | Applicant-view fields; adverse-action reason content; ruleset overlay |
| C4 | Do WA / Seattle **portable-tenant-screening-report** rules apply — must we accept a reusable applicant-provided report, and on what terms (recency, fee limits)? | Portable-report mandates change the intake flow and any screening-fee handling (DSN-06 §1; ARC-02 C-L6). | Application intake; screening-fee/charge handling |
| C5 | Any limits on **who pays for screening** and how that charge is disclosed (the MVP assumes the applicant bears the tenant-initiated cost)? | Fee-shifting and disclosure rules vary; affects the intake UX and ToS (PLN-01 §5 cost note). | Application intake; fee disclosure copy |

### (D) Security-Deposit Handling — Platform *Documents* but Never *Holds*

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| D1 | If the platform **records** deposit amount, holding location, and statutory timers and **generates the itemization letter**, but **never receives or holds** the deposit (the landlord holds it as they lawfully do today), does that keep us **outside WA trust-account / deposit-handling statutes** entirely? | The whole deposit-documentation feature depends on "documenting ≠ holding" being legally clean (ANL-02 G-02; DSN-06 §3; ARC-02 C-L7). | Deposit-documentation module go/no-go |
| D2 | What **records and timelines must we generate** to support the landlord's compliance — WA deposit **return deadline**, **itemized-deductions** requirements, any **receipt / written-checklist / holding-institution disclosure**, and whether interest is owed? | Our timers and letter templates must encode the exact statutory duties, or the feature misleads users (DSN-06 §3 deposit parameter family). | Statutory-timer engine; itemization-letter generator; move-in condition report content |
| D3 | Does generating a **move-in/move-out condition report with both-party acknowledgment** satisfy (or help satisfy) any WA statutory checklist requirement, and what must it contain to be useful evidence? | Determines whether the condition-report feature is compliance-bearing or merely nice-to-have (PLN-01 §3; DSN-06 §3). | Move-in/out condition reports |
| D4 | Is there any **disclosure we must surface to the tenant** about where/how the deposit is held, given the platform documents but does not control it? | Mis-stating the platform's role re: the deposit is itself a risk (DSN-06 §7). | Deposit disclosure copy; ToS role description |

### (E) Payments — Processor Model, No Platform Custody

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| E1 | Under a **Stripe-Connect-class PayFac model** where tenant ACH debits settle **directly to the landlord's connected account** and the platform **never takes possession or control of funds**, does the platform avoid **money-transmitter / MSB licensing** at the **federal (FinCEN)** and **WA state** levels? Does the **payment-processor / agent-of-payee exemption** apply, and what must be true to stay inside it? | This is the payments existential question (ANL-02 G-03; TR-03; ARC-02 C-L8). WA is flagged as money-transmitter-cautious. Getting this wrong is unlicensed-MT exposure. | Rent autopay (entire payments feature); confirms platform-never-holds posture |
| E2 | What **contractual / flow-of-funds facts** must hold for the exemption — e.g. funds never routed through a platform-controlled account, no platform-held balances, processor is merchant-of-record for payout KYC — so we can design and document to them? | We need design constraints, not just a conclusion, to keep the exemption durable (PLN-01 §2; ADR-0007). | Payment-rail architecture; processor onboarding flow |
| E3 | Does the MVP's reliance on the **processor's KYC for the payout (landlord) side** suffice, with **no separate platform KYC program** at this stage? | KYC-vendor integration is deferred on the theory the processor covers payout identity (PLN-01 §3 "Out"; ARC-02 C-L8). | Landlord onboarding; deferral of KYC vendor |
| E4 | Are there **WA limits on mandating electronic-only rent payment** — must we always offer a non-electronic alternative, and does offering ACH-only at MVP create exposure? | Some jurisdictions bar electronic-only mandates; our launch rail is ACH (ARC-02 C-L13; ANL-02 G-04; [ADR-0018](../adr/ADR-0018-fiat-fallback-rail.md)). | ACH autopay as sole rail; need for a fallback payment method |

### (F) ToS / Privacy / E-Sign Enforceability & Identity-Binding Evidence

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| F1 | Review our **Terms of Service and Privacy Policy** for a software-not-broker, no-custody posture — including disclaimers that AI outputs are **assistive, not legal/financial advice**, and that the platform does not hold funds or deposits. What must these say to support the §1 posture? | The ToS is where we assert and preserve the non-brokerage / non-custodial characterization (DSN-06 §7; PLN-01 §5). | Onboarding consent; platform-wide disclosures |
| F2 | Is our **e-sign ceremony ESIGN/UETA-enforceable** in WA for a residential lease, and what **identity-binding evidence** should we retain (KYC/identity ↔ signer ↔ signature ↔ timestamp ↔ IP/device metadata) to make an executed lease hold up if challenged? Is **remote online notarization** needed for anything at MVP (we assume not for a lease)? | E-sign was named in scope but the identity-binding chain needed for enforceability was a gap (ANL-02 G-13; ARC-02 C-L9; DSN-06 §5). | Lease e-sign ceremony; WORM evidence package; condition-report acknowledgments |
| F3 | What **consumer-disclosure / consent** is required to conduct the transaction electronically (ESIGN consumer consent), and how should we capture it? | ESIGN requires affirmative consumer consent to electronic records; missing it weakens enforceability (DSN-06 §3 execution). | Electronic-transaction consent step |
| F4 | Any **WA consumer-privacy** obligations (collection/deletion, sensitive data) that the Privacy Policy and our data-handling must reflect at MVP scale? | Determines privacy-policy content and any deletion/retention duties (DSN-06 §1 privacy row). | Privacy policy; data-retention/deletion design |

### (G) Tax Information Reporting (1099-class)

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| G1 | In the processor model where rent settles **directly to the landlord** and the platform never holds funds, do **1099-class information-reporting duties** (e.g. 1099-K for payment settlement, 1099-MISC) fall on the **platform, the processor, or the landlord**? | Mis-assigned reporting duty is an IRS-penalty risk; the boundary is genuinely unclear in a PayFac flow (ANL-02 G-08; DSN-06 §1 tax row). | Whether platform must issue/collect tax forms; ledger-export design |
| G2 | If any reporting or **W-9 collection** duty does land on the platform, what **data must we capture at onboarding** and export, and at what thresholds? | We must design the ledger/exports and onboarding capture now to avoid a retrofit (DSN-06 §1; PLN-01 §4 data model). | Billing/ledger exports; landlord onboarding fields |

### (H) AI-Specific — Fair Housing, Disclosure Language, and Forward-Looking Agent Feature

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| H1 | Does our **AI listing-copy assistant** create **Fair Housing advertising** exposure, and is a **deterministic HUD-word-list lint** on generated copy an adequate control? What must the human-in-the-loop review attest? | Discriminatory advertising is FHA liability even if unintentional (README §4.2 fair-housing warning; ARC-02 C-L4; DSN-06 §1). | AI listing-copy assistant; ad-copy lint gate |
| H2 | Is **tenant-side unit matching** (scoring **properties for a tenant**, never scoring **people**) the legally safe direction, and are there FHA constraints on the matching criteria or the "why this match" explanations we surface? | The MVP deliberately scores units-for-tenants, not applicants, to avoid steering; we need that confirmed (PLN-01 §2; [ADR-0010](../adr/ADR-0010-rule-based-matching-first.md); README R-05). | Tenant-side matching engine; match-explanation copy |
| H3 | What **disclosure language** should accompany AI-assisted features so they are clearly **"assistive, not advice"** and not a representation the platform is acting as a broker or lawyer? | Protects the §1 posture and manages reliance/UPL risk (DSN-06 §7; PLN-01 §3 lease explainer). | AI lease explainer; AI intake; listing assistant disclosures |
| H4 | **(Forward-looking, not MVP.)** When we later add **AI dual-agent representation**, will **dual-agency-style disclosures / information-barrier** language be required (one platform "representing" both sides), and what consent framework should we plan toward? | Flagging early so the later increment is not a surprise; not gating anything in the 30-day MVP (ANL-02 G-11; [ADR-0016](../adr/ADR-0016-dual-agent-isolation.md); DSN-06 §7). | **Deferred** dual-agent negotiation (Increment 1c) — planning input only |

### (I) Additional Exposures — *surfaced in architecture review*

| # | Question | Why it matters | Feature it gates |
|---|---|---|---|
| I1 | If a landlord relies on a **platform-generated lease, notice, or deposit-itemization letter that proves defective**, how should the ToS allocate liability between the platform and the landlord, and what **limitation-of-liability / indemnification posture is enforceable in WA** (including enforceability of a consequential-damages waiver in a consumer-adjacent B2B agreement)? | Document generation is a core MVP feature; if a defective generated document exposes a landlord to tenant claims, the platform's contractual exposure needs a durable WA-law cap (DSN-06 §7; PLN-01 §5). | ToS scope; lease generation; deposit-itemization letter; notice generator |
| I2 | WA bars source-of-income discrimination; how must the **application intake, screening display, and tenant-side matching flows be designed to comply** with RCW 49.60 and the Seattle source-of-income ordinance — and should **source-of-income be a configured protected category** in the fair-housing guardrail ruleset rather than left to landlord discretion? | Landlord-configurable exclusions of voucher holders via the platform's own UI could make the platform a conduit for unlawful discrimination; the control design must prevent that (ARC-02 C-L4; [ADR-0010](../adr/ADR-0010-rule-based-matching-first.md); DSN-06 §1 fair-housing row). | Matching engine; screening integration; applicant-view fields; ruleset protected-category configuration |
| I3 | Beyond the security deposit, WA regulates **non-refundable move-in fees and the combined deposit-plus-fee structure**; must the platform **document, cap, or require disclosure** of these adjacent charges, and what records — if any — must be generated and retained? | If the platform's lease-terms and deposit-documentation features expose landlords to fee-cap violations by omission, the feature design is deficient; the platform may also need to surface these charges in the lease parameter family (DSN-06 §3 deposit parameter family; PLN-01 §3). | Deposit-documentation module; lease-generation parameter families; lease terms |
| I4 | Does an AI feature that answers a landlord's **"what does this clause mean / what should I do about this situation"** question cross into **unauthorized practice of law under the WA UPL standard** (RCW 2.48.180), and is an **"assistive, not advice" disclaimer alone sufficient** — or must the feature be scoped, architecturally gated, or disclaimed differently? | The AI lease explainer and intake features are already in the MVP; if the UPL boundary requires content or capability changes (e.g. answer-type restrictions, mandatory attorney-referral prompts), they must be built before launch (DSN-06 §7 disclaimer language; PLN-01 §3 lease explainer; ARC-02 C-L5). | AI lease explainer; AI intake; assistive-not-advice disclaimer copy |
| I5 | Given the platform holds **tenant PII and screening-adjacent data**, what **breach-notification obligations under WA's data-breach statute (RCW 19.255.010)** must the ToS, privacy policy, and internal incident runbooks reflect — including notification timing, scope, and required content — and does the nature of the data (screening-adjacent, financial) trigger any enhanced duty? | A breach of tenant screening or payment data without a compliant notification program is independently actionable; the platform's incident runbooks and external-facing policies must encode the statutory duty before the first real tenant record is ingested (DSN-06 §1 privacy row; PLN-01 §4 data model; F4 above). | Privacy policy; incident runbooks; data-handling and retention design |

---

## 4. Documents We Will Provide / Deliverables We Need Back

### Documents we will provide to counsel

| Doc | What it is | Why it's relevant to your review |
|---|---|---|
| [PLN-01](../planning/mvp-30-day.md) | 30-day MVP definition: exact in/out scope, build plan, legal track, risks | The authoritative statement of **what the MVP does and does not do** — the factual basis for every question above |
| [DSN-06](../design/compliance-and-audit.md) | Compliance & audit architecture: broker workflow, state ruleset engine, FCRA adverse-action, KYC/AML, records, disclosures | Shows the **controls already designed** so your review can confirm/correct them rather than start cold |
| [ANL-02](../analysis/gap-analysis.md) | Gap analysis: the legal blockers (G-01 FCRA, G-02 deposits, G-03 custody, G-05 leasing-license, G-08 tax, G-13 e-sign) and their dispositions | Each gap maps to a question topic; flags **exactly where counsel sign-off is required** |
| *(On request)* | README product scope; [ARC-02](../architecture/02-constraints.md) legal constraints; relevant ADRs (0006, 0007, 0010, 0013, 0016, 0017, 0018, 0019) | Background / deeper context for any topic |

### Deliverables we need back (mapped to the sprint)

| # | Deliverable | Target | Sprint mapping |
|---|---|---|---|
| 1 | **Licensing-posture memo** — software-for-the-principal does/does not require RE or PM licensure in WA; the activities that would cross the line (topic A) | **End of Week 1** | Confirms the MVP is buildable as scoped before heavy engineering commits (PLN-01 §5 W1) |
| 2 | **Launch-state confirmation** — WA workable, or named alternative; Seattle first-in-time / fair-chance call (implement vs. restrict pilot) (§2) | **End of Week 1** | Gates ruleset parameter selection and pilot geography (ANL-04 O-2; PLN-01 §6.3) |
| 3 | **Payments / money-transmission opinion** — platform-never-holds processor model avoids MT/MSB licensing; flow-of-funds conditions to maintain it (topic E) | **End of Week 2** | Unblocks the rent-autopay build and processor onboarding design (PLN-01 §5 W1–2) |
| 4 | **FCRA + fair-chance sign-off** — adverse-action workflow and letter templates adequate; Seattle overlays reflected (topic C) | **End of Week 2** | Adverse-action letters are reviewed in Week 2 (PLN-01 §5 W2) |
| 5 | **Deposit-handling confirmation** — documents-not-holds avoids trust-account statutes; required records/timelines (topic D) | **End of Week 2–3** | Feeds the deposit-documentation build in Week 4 (PLN-01 §5) |
| 6 | **LEASE TEMPLATE SIGN-OFF + mandatory disclosures/addenda + notice forms** (topics B, plus lead-paint) | **End of Week 3 — HARD GATE** | **No client-facing lease without this.** If it slips, launch slips (PLN-01 §6.1) |
| 7 | **ToS / Privacy / e-sign review** — enforceability + identity-binding evidence to retain (topic F) | **End of Week 3** | ToS/privacy drafted in Week 1, finalized for launch (PLN-01 §5 W1) |
| 8 | **Tax-reporting determination** — 1099-class duty allocation; any platform W-9/export duty (topic G) | **End of Week 3** (may extend) | Confirms ledger-export design; not launch-blocking if deferred (ANL-02 G-08) |

> **The one immovable date is Deliverable 6 (template + disclosures) by end of Week 3.** Everything else can flex by days; the lease template cannot, because we will not put a client on an unreviewed lease (PLN-01 §6.1; ARC-02 C-O3).

---

## 5. Engagement Logistics

- **Engagement shape.** We are seeking a **fixed-fee initial engagement** scoped to the deliverables in §4 — primarily (1) the licensing-posture memo, (2) the WA lease template + disclosure/addenda package, and (3) the payments/FCRA/deposit confirmations — with the **lease template by end of Week 3** as the binding milestone. We would prefer a defined cap with clearly bounded scope over open-ended hourly billing for this first phase.
- **Illustrative budget.** Our planning figure for this initial engagement is **roughly $10,000–$25,000** (PLN-01 §6; rush turnaround acknowledged). **This range is illustrative and from internal planning — we expect you to quote against the actual scope.**
- **In scope (this engagement):** WA launch-state confirmation + Seattle overlay call; licensing-posture memo; lease template + mandatory disclosures/addenda + notice forms; FCRA adverse-action workflow review; security-deposit documentation confirmation; payments/money-transmission posture opinion; ToS/privacy/e-sign review; tax-reporting determination (topics A–H, MVP-scoped).
- **Out of scope (later engagements):** smart-contract / stablecoin custody and BSA/AML program design (deferred to the on-chain settlement increment — ANL-04 O-3, O-10); property-manager / agency licensing posture (deferred — ANL-02 G-05); Phase-2 home-sale brokerage, good-funds, and recording-law work; multi-state expansion; the AI dual-agent disclosure framework (H4, forward-looking).
- **Working materials.** We will provide PLN-01, DSN-06, and ANL-02 up front (§4), with deeper docs and ADRs on request. We can turn around founder questions quickly to keep the 3-week clock.
- **Status of this brief.** This is **founder-review material prepared by a non-lawyer.** All characterizations (e.g. "software for the principal," "no money transmission," "documents but does not hold") are our **proposed** posture for your independent assessment, not conclusions. Dollar figures and statutory citations are illustrative and pending your confirmation. Nothing here is legal advice.

---

*LGL-01 · v0.1.0-draft · 2026-06-11 · Draft for founder review — not legal advice. Cross-references: PLN-01, DSN-06, ANL-02, ARC-02, ANL-04, and ADRs 0006/0007/0010/0013/0016/0017/0018/0019.*
