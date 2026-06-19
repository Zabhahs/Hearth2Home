# Smart-Contract Housing Platform — Product Scope

**Disintermediated Rental & Home-Buying — AI-Mediated, On-Chain Settlement**

Working Title: "HomeChain" (placeholder)
Document v1.0 · Draft for Founder Review · June 2026
*MVP Feature Suite · Risk Analysis · Technical Feasibility · Competitive Landscape*

---

## Contents

1. Executive Summary
2. Problem Statement & Market Opportunity
2A. Title & Recording Strategy
3. Product Goals, Objectives & Scope
3A. Platform Architecture — The Oracle & Integration Layer
4. Feature Suite
5. Target Customer & Personas
6. Technical Feasibility & Recommended Stack
7. Risk Analysis & Register
8. Competitive Landscape
9. Phased Roadmap & Open Items
10. Market Sizing (Bottom-Up TAM/SAM/SOM)
11. State-by-State Legislative & Launch Strategy

---

## 1. Executive Summary

This document scopes a software platform that removes the traditional real-estate intermediary from rental and home-sale transactions, replacing the agent's coordination and documentation role with two AI agents (one representing each party) and a blockchain settlement layer for escrow and verified milestone events.

The founding insight is a real and quantified market gap: despite a $418M antitrust settlement against the National Association of Realtors intended to lower commissions, **average total commissions actually rose to 5.44% in 2025**, with roughly half charged to each side. The middleman cost did not fall. The platform's thesis is that AI can perform the coordination, matching, and documentation work better and at a fraction of the cost, while a smart-contract layer handles escrow, lease enforcement, and (eventually) financing flows more transparently than today's fragmented systems.

Recent federal legislation materially de-risks the payments side of this idea. The **GENIUS Act (signed July 18, 2025)** established the first US federal framework for dollar-backed payment stablecoins, making a regulated stablecoin a legally usable settlement instrument for programmable escrow. The **CLARITY Act** (market-structure rules that would govern any token model) passed the House but remains stalled in the Senate as of mid-2026, with a narrow window before the calendar closes. The strategic implication is decisive: **build settlement on existing regulated stablecoins now; do not build a business model that depends on issuing a token, because the law authorizing that is not yet in place.**

> **STRATEGIC RECOMMENDATION** — Sequence the rollout in two phases. Phase 1 (MVP): rental & lease automation for landlords — recurring revenue, lower liability, lighter licensing burden, fast sales cycle. Phase 2: home-buying transaction suite — higher revenue per deal but heavier regulatory and liability load. This document scopes both, but treats rentals as the beachhead per PMI phase-gating discipline.

On title and recording, the platform adopts a deliberate two-horizon strategy detailed in Section 2A. **Near term (architecture):** the platform owns the entire transaction pipeline — negotiation, signing, escrow, funds, document generation — and the county-recorded deed becomes the trivial final output of that pipeline rather than the place the work happens. **Long term (vision):** advance the legislative groundwork — already begun in Vermont, Arizona, Wyoming, and Ohio — toward on-chain records becoming a recognized system of record. The near-term path requires no change in law and captures the value where the 5–6% currently goes; the long-term path is the company's mission-level moat.

Three founder decisions are recorded as **deliberate, founder-directed choices**. (1) Title/ownership is resolved via the Path 2 architecture in Section 2A — county remains the legal source of truth, the chain holds a deed-reference, and full on-chain title is pursued as the long-game vision (Path 1). (2) Placing listings and bids on a public chain and (3) making the AI matching engine central to the MVP remain flagged for revisit at the Phase-1 gate; each is addressed in the Risk Register (Section 7) with a recommended mitigation.

---

## 2. Problem Statement & Market Opportunity

### 2.1 The Core Problem

Real-estate transactions carry a coordination tax that is large, opaque, and resistant to reform:

- **Commission cost is sticky.** Total agent commissions averaged 5.44% in 2025, up from 5.32% the prior year, even after the NAR settlement was supposed to introduce downward pressure. On a median ~$368K home that is roughly $20,000 in fees.
- **The intermediary is a coordinator, not a creator of value.** Much of the agent's day-to-day work — scheduling, document handling, status-chasing, matching buyers to listings — is coordination labor that software performs faster and documents more completely.
- **Escrow and milestone disputes tie up funds.** Manual verification of conditions (inspection done, funds received, walkthrough completed) is slow and dispute-prone.
- **Rentals are under-served by software.** Small landlords juggle lease drafting, rent increases, utility coordination, and renewals across disconnected tools.

### 2.2 Why Now

- **Regulatory tailwind on payments.** GENIUS Act gives programmable stablecoin escrow a legal foundation that did not exist 18 months ago.
- **Post-settlement consumer openness.** Buyers and sellers are, for the first time, signing explicit representation agreements and questioning what they pay for — a wedge for a transparent alternative.
- **AI capability.** LLM agents can now plausibly conduct structured intake, matching, and document generation with human-in-the-loop approval.

### 2.3 Market Sizing (directional)

The blockchain-real-estate segment is estimated to surpass $3–5B globally in 2026, driven by tokenization and transaction automation; the broader smart-contract market is projected at ~$12.5B by 2032. These are directional third-party figures; the bottom-up TAM/SAM/SOM model is built in Section 10.

---

## 2A. Title & Recording Strategy

This section addresses the central architectural question: where does legal ownership live, and how does the platform relate to it. It defines a primary path for the MVP and a long-horizon vision path.

### 2A.1 Why the County Holds the Record Today

The county recorder is not merely a database; it is the legal anchor that resolves competing claims to a parcel with finality. Recording statutes (race, notice, and race-notice, varying by state) determine priority among buyers, lenders, and lienholders, and courts enforce those priorities against the recorded record. The record is what title insurers underwrite against and what protects an owner from a forged deed, a double-sale, or an unconsented lien. A key property of this system is that erroneous or fraudulent records can be judicially unwound. This matters for design: raw immutability is a liability in a title context, because it would make fraud permanent rather than reversible.

> **FOUNDER VISION (recorded as mission, not present law)** — The company's stated vision is to push the locus of property sovereignty back toward the citizen and into a data-rich, on-chain future — to make property transfer easy, transparent, and modern rather than slow and paper-bound. This document treats that as the mission-level goal driving Path 1. It is framed as a future state the company intends to help bring about, distinct from the current legal framework the MVP must operate within. Stating it this way is deliberate: sophisticated investors discount proposals that conflate vision with present law, and reward those that show a credible path from one to the other.

### 2A.2 Primary Path (MVP) — Pipeline Ownership, County as Output

The platform originates and runs the full transaction: AI-mediated negotiation, identity/KYC, document generation, programmable escrow, and funds settlement in a regulated stablecoin. At completion, the platform auto-generates the deed and recording package and submits it to the county (e-recording where available). The county remains the legal source of truth; it becomes the last, automated step of a pipeline the platform owns end-to-end.

- **Requires no change in law** — buildable in target states today.
- **Captures the value** — the 5–6% intermediary cost lives upstream of recording, in exactly the steps the platform automates.
- **Keeps fraud reversible** — because the legal anchor stays with the county and courts.
- **Precedent** — this is broadly the model Propy operates under: chain-coordinated transaction, traditionally-recorded deed.

### 2A.3 Vision Path (Long Game) — On-Chain Record of Authority

The long-horizon goal is for an on-chain registry to become a recognized system of record. The legislative groundwork has already begun (full state detail and citations in Section 11):

- **Vermont:** 12 V.S.A. § 1913 gives a blockchain-registered record recognized evidentiary standing (treated as a regularly-conducted-business record under VT Rule of Evidence 803(6)), with the on-chain timestamp and recording party legally recognized.
- **Arizona:** HB 2417 (2017) recognized blockchain signatures and smart contracts as valid electronic records; SB 1084 directed agencies toward electronic records/signatures.
- **Ohio:** SB 220 / SB 300-era provisions deem blockchain-secured records and signatures electronic records with legal standing.
- **Wyoming:** Teton County signed an MOU with Medici Land Governance to migrate county land records onto a blockchain-based system.
- **Pilot precedent:** Propy executed the first US blockchain property pilot in Chittenden County, Vermont (2018).

> **HONEST DISTINCTION** — None of these laws yet make the chain the legal source of title — they make on-chain records admissible and recognized. That is a step toward Path 1, not arrival at it. The credible pitch is: "the groundwork exists; we intend to complete it," backed by the state-by-state engagement strategy in Section 11. Note also that allodial title (ownership free of any superior claim) effectively does not exist for US individuals; fee simple — the strongest private ownership — remains subject to tax, eminent domain, and recording. Path 1 is therefore a policy-change ambition, not a reinterpretation of current ownership law.

---

## 3. Product Goals, Objectives & Scope

### 3.1 Product Vision

> **VISION** — A housing transaction platform where two AI agents — one for each party — conduct the entire rental or purchase process, pinging each human only for genuine decisions, documenting every step, and settling money and milestones through transparent smart contracts. The human keeps control and the audit trail; the platform removes the cost and opacity of the legacy middleman.

### 3.2 SMART Objectives

| Objective | Target (illustrative — set real numbers at planning) |
|---|---|
| Reduce transaction cost | Deliver landlord/seller savings of ≥ 60% vs. legacy agent/PM fees |
| Cycle-time | Rental lease execution in < 48 hrs from match to signed+funded |
| Phase-1 traction | Onboard 50 landlords / 250 managed units within 6 months of launch |
| Documentation quality | 100% of milestone events captured with timestamped, attributable audit trail |
| Compliance | Zero unlicensed-activity enforcement actions; broker-of-record supervising all sale-side activity |

### 3.3 Scope: What We Build vs. What We Integrate

This platform is an aggregator. Per the platform thesis (Section 3A), most adjacent services are not things the company builds or refuses — they are external services oracled in through a curated, validated partner program. The scope question is therefore not "in vs. out" but "build ourselves vs. integrate vs. genuinely cannot."

| We Build (Phase 1) | We Integrate (oracle-in) | Genuinely Cannot / Won't |
|---|---|---|
| Landlord onboarding & unit profiles | Mortgage / refi origination (partner lenders) | Replace legal title transfer (county is source of truth — Path 1 vision only) |
| AI intake + matching engine | Utility setup / transfer (provider APIs) | Issue our own stablecoin (use regulated 3rd-party — GENIUS) |
| Smart-contract lease + escrow | Property-tax & county record data | Operate as unlicensed broker (broker-of-record required) |
| Stablecoin rent collection | Title search & title insurance | Build our own secondary-market trading engine (Phase 3+) |
| Geo-verified walkthrough | Inspection providers (sign-off oracle) | Steer/optimize on protected classes (illegal — hard wall) |
| The oracle/integration layer itself | Insurance, fractional-ownership rails, payment assistance | Multi-country jurisdictions at MVP (later) |

---

## 3A. Platform Architecture — The Oracle & Integration Layer

> **PLATFORM THESIS** — The product is not a single application — it is the connective tissue of home transactions. Like a social platform that won by owning the graph and the integration surface rather than producing the content, this platform wins by owning the validated network of services that every home transaction needs — lending, utilities, tax, title, inspection, insurance — and the trusted rails that connect them. The oracle/integration layer is therefore the core asset, not a supporting module.

### 3A.1 What the Layer Does

Mutable, real-world data stays off-chain at the authoritative source (county records, utility accounts, lender systems). The oracle layer reads from and writes to those sources and translates verified events into on-chain contract actions — e.g. "inspection passed," "funds received," "title clear," "walkthrough geo-confirmed" — which release escrow steps or advance the transaction. The chain holds the trust-critical events and references; the services hold their own data.

- **Read oracles:** pull county/tax/title/lender status into transaction logic.
- **Write/attestation oracles:** record verified milestones on-chain with attributable, timestamped provenance.
- **Source-of-truth discipline:** the layer mirrors authoritative sources; it does not pretend to replace them (esp. county title — Section 2A).

### 3A.2 Curated & Validated Partner Program (the moat)

Integrations are curated and validated, not open. In a domain where every connector touches money or title, an open marketplace is a fraud surface. The vetting program is itself a defensible asset: a buyer or landlord trusts that every service on the platform has been validated.

- **Partner vetting:** licensing checks, security review, data-handling audit, and on-platform reputation before a connector goes live.
- **Standardized connector spec:** partners integrate against a defined schema (the SDK), so onboarding scales without bespoke work.
- **Continuous monitoring:** anomaly detection and offboarding for partners that fail ongoing checks — anti-scam by design.
- **Open later, carefully:** the spec can open to self-serve connectors in a later phase once validation tooling is mature; launch stays curated.

### 3A.3 Technical Substrate

- **Oracle networks:** Chainlink Functions (arbitrary off-chain data/compute) + CCIP (cross-service/cross-chain messaging) as the proven baseline.
- **Connector SDK:** typed adapter interface + sandbox for partner testing; versioned, signed connectors.
- **Event bus:** verified external events normalized into a canonical schema before they touch contract logic.
- **Fail-safe:** human-approval gate on high-value state changes; oracle disagreement triggers escalation, not silent execution.

---

## 4. Feature Suite

Features are grouped into modules and tagged with a MoSCoW priority (M=Must, S=Should, C=Could, W=Won't-yet) and the release phase. "Phase 1" = rental MVP; "Phase 2" = home-buying.

### 4.1 Module A — Identity, Onboarding & Verification

| Feature | MoSCoW | Phase | Notes |
|---|---|---|---|
| KYC/AML identity verification (both parties) | M | 1 | Required for any stablecoin movement; use a regulated KYC vendor. |
| Landlord / unit profile creation | M | 1 | Address, terms, non-negotiables. |
| Tenant/buyer profile + needs intake | M | 1 | Conversational AI intake. |
| Wallet provisioning (custodial) | M | 1 | Abstract crypto away from users; custodial to start. |
| Reputation / transaction history | S | 2 | On-chain attestations of completed deals. |

### 4.2 Module B — AI Agent & Matching Engine (Central Differentiator)

Each party is represented by an AI agent that conducts intake, negotiates within human-set guardrails, and explains its reasoning. The matching engine fuses explicit criteria with inferred aesthetic/lifestyle preferences.

| Feature | MoSCoW | Phase | Notes |
|---|---|---|---|
| Conversational needs intake | M | 1 | Structured + free-text capture of must-haves. |
| Aesthetic preference ingestion (e.g., Pinterest board, uploaded images) | S | 1 | Vision model extracts style signal; user consents to source. |
| Preference inference ("subconscious wants") | C | 1 | Frame as suggestions w/ explanation, never hidden manipulation. |
| Match scoring & ranked recommendations | M | 1 | Explainable score; show why each match surfaced. |
| Seller-side optimization (preferred tenant/buyer profile) | S | 1 | CAUTION: fair-housing landmine — see note below. |
| Dual-agent negotiation w/ human approval gates | M | 1 | Agent proposes; human approves each material term. |
| Decision explainability log | M | 1 | Every recommendation/decision is human-readable & stored. |

> **FAIR-HOUSING WARNING (must read)** — Optimizing for sellers who "prefer selling to a family with kids vs. a young couple" describes conduct that is illegal under the federal Fair Housing Act. Familial status is a protected class; so are race, color, religion, sex, national origin, and disability. An AI that steers or filters on these — even via correlated proxies — creates direct legal liability and is a reputational catastrophe. The matching engine MUST optimize only on lawful, non-protected criteria (price, dates, lease length, verified income/credit within legal bounds, amenities, stated style). This is a hard constraint, not a tunable preference.

### 4.3 Module C — On-Chain Listings, Bids & Ownership Reference

| Feature | MoSCoW | Phase | Notes |
|---|---|---|---|
| Listing records on-chain | S | 1 | Founder-directed. Privacy risk — see R-02; recommend hashed/commit-reveal or permissioned chain. |
| Bid/offer records on-chain | S | 1 | Same caveat; public bids leak negotiation data. |
| Tokenized deed-reference (NFT pointer to county record) | C | 2 | Represents/links to deed; county recorder remains legal source of truth. |
| Ownership attestation via oracle | C | 2 | Oracle mirrors county data; not a legal transfer. |
| Listing detail off-chain, mutable | M | 1 | Photos, descriptions, price changes live in DB, not chain. |

### 4.4 Module D — Smart-Contract Lease & Escrow

| Feature | MoSCoW | Phase | Notes |
|---|---|---|---|
| Programmable escrow (earnest money / deposit) | M | 1 | Releases on verified conditions; regulated stablecoin. |
| Smart-contract lease w/ encoded terms | M | 1 | Human-readable lease + on-chain enforcement of payment terms. |
| Automatic rent collection | M | 1 | Scheduled stablecoin pulls from tenant wallet. |
| Auto rent-increase logic (capped, lawful) | S | 1 | Must respect local rent-control / notice laws. |
| Security-deposit handling & lawful return | M | 1 | Escrowed; auto-return minus documented deductions. |
| Late-fee / grace-period automation | S | 1 | Configurable, jurisdiction-aware. |
| Smart utility management | C | 2 | Coordinate transfer/splitting; needs provider APIs. |
| Refi / 2nd mortgage / payment-assistance flows | W | 2+ | Heavily regulated; deliberately deferred. |

### 4.5 Module E — Geo-Verified Conditions & Oracle Integrations

The oracle/integration layer is specified as core architecture in Section 3A. The features below are its Phase-tagged deliverables.

| Feature | MoSCoW | Phase | Notes |
|---|---|---|---|
| Geo-authenticated walkthrough/move-in | S | 1 | Device-attested location + timestamp as contract condition. |
| Oracle integration layer (Chainlink Functions/CCIP) | M | 1 | Core spine — see Section 3A. |
| Curated partner connector SDK + sandbox | M | 1 | Standardized, validated integrations only. |
| Partner vetting & monitoring pipeline | M | 1 | Licensing/security/data audit; anti-scam by design. |
| County / tax record read oracle | S | 2 | Mirrors authoritative source; does not replace it. |
| Lender / utility / title / inspection connectors | S | 2 | Validated partners; rolled out per vertical. |
| Off-chain data refresh w/o on-chain writes | M | 1 | Only trust-events hit chain. |

### 4.6 Module F — Compliance, Audit & Human-in-the-Loop

| Feature | MoSCoW | Phase | Notes |
|---|---|---|---|
| Broker-of-record supervision dashboard | M | 1 | Licensed principal reviews/approves regulated actions. |
| Full timestamped audit trail | M | 1 | Every agent decision + human approval recorded. |
| Disclosure & document generation | M | 1 | State-specific lease/disclosure templates, attorney-reviewed. |
| Fair-housing guardrail enforcement | M | 1 | Hard filter on protected-class criteria. |
| Dispute / override workflow | S | 1 | Human escalation path; freeze/override escrow per lawful order. |

---

## 5. Target Customer & Personas

Per the margin analysis, the **Phase-1 paying customer is the small-to-mid landlord / independent property manager** — recurring revenue, lower liability, lighter licensing burden, repeat usage. FSBO sellers and budget-conscious buyers are higher-revenue but one-shot, high-liability, and slow-cycle; they are marked for later "toolkit drops."

| Persona | Profile | Why they pay |
|---|---|---|
| Priya — small landlord (Phase 1) | Owns 4–12 units, self-manages, hates PM fees of 8–10% | Per-unit SaaS < PM fee; automation of rent + leases |
| Marcus — indie property manager (Phase 1) | Manages 30–150 units for owners | Margin expansion; fewer staff hours per unit |
| The Foxes — FSBO sellers (Phase 2) | Selling own home, resent 5–6% commission | Flat fee + AI coordination vs. $20K commission |
| Dana — budget buyer (Phase 2) | Wants representation cheaply post-NAR | Low-cost AI buyer-agent w/ broker oversight |

### 5.1 Monetization (illustrative)

- **Phase 1:** per-unit monthly SaaS fee (e.g., $X/unit/mo) + small % on stablecoin rent throughput.
- **Phase 2:** flat transaction fee or low take-rate on sale (positioned explicitly against 5–6% commission).
- **Float/yield:** GENIUS-era stablecoin yield rules are unsettled — do not assume escrow-float yield as revenue until CLARITY/yield rules resolve.

---

## 6. Technical Feasibility & Recommended Stack

### 6.1 Feasibility Verdict by Component

| Component | Feasibility | Assessment |
|---|---|---|
| AI intake & matching | High | Mature LLM + vision capability; main work is product/UX and guardrails. |
| Programmable escrow (stablecoin) | High | Legally grounded post-GENIUS; standard smart-contract patterns. |
| Smart-contract lease | Medium | Enforceable for payment terms; full lease enforceability still relies on off-chain signed agreement. |
| Oracle layer | Medium | Chainlink Functions/CCIP proven, but each integration is real work. |
| Geo-verified walkthrough | Medium | Device location is spoofable; needs attestation + anti-fraud. |
| On-chain listings/bids | Medium | Technically easy; privacy is the real problem — see R-02. |
| On-chain ownership | Low | Cannot be legal title in US; only a reference/pointer is feasible. |
| Refi / mortgage flows | Low | Feasible technically but heavy regulation — deferred to Phase 2+. |

### 6.2 Recommended Stack

**Frontend & App**
- Web: Next.js (React) + TypeScript; Tailwind for UI.
- Mobile: React Native (shared logic) — needed for geo-verified walkthrough capture.

**Backend & Data**
- API: Node/TypeScript (NestJS) or Python (FastAPI).
- Primary DB: PostgreSQL (listings, profiles, mutable home data, audit log).
- Object storage: S3-compatible for documents/images.
- Search/match: vector store (e.g., pgvector) for aesthetic/semantic matching.

**AI Layer**
- Agents: LLM via API (Claude) for intake, negotiation, explainability; tool-use for structured actions.
- Vision: multimodal model for aesthetic-preference extraction from images/boards.
- Guardrails: deterministic fair-housing filter sitting *outside* the model; the model never gets final say on protected-class logic.

**Blockchain Layer**
- Phase 0/1 dev: EVM testnet (e.g., Base Sepolia) — build and iterate at zero financial risk.
- Chain choice: an L2 (Base / Arbitrum) for low fees + EVM tooling. Evaluate a permissioned/private deployment or commit-reveal for bid privacy.
- Contracts: Solidity; audited escrow + lease modules; upgradeable proxy pattern with timelock.
- Stablecoin: integrate an established GENIUS-compliant USD stablecoin; do NOT mint your own.
- Oracles: Chainlink Functions (off-chain data) + CCIP (cross-chain/service messaging).
- Wallets: custodial / account-abstraction (ERC-4337) so users never touch seed phrases.

**Compliance & Ops**
- KYC/AML: third-party vendor (e.g., Persona/Alloy-class).
- Audit trail: append-only log (DB) + selective on-chain anchoring of hashes.
- Smart-contract audit: independent third-party audit before any mainnet funds.

---

## 7. Risk Analysis & Register

Scored on Likelihood (L) and Impact (I), each 1–5; Exposure = L×I. Rows R-01–R-03 capture the three founder-directed decisions and are recommended for revisit at the Phase-1 gate.

| ID | Risk | L | I | Exp | Mitigation |
|---|---|---|---|---|---|
| **R-01** | "Ownership on-chain" mistaken for legal title → unenforceable contracts / fraud claims | 3 | 5 | **15** | RESOLVED via Path 2 (Sec 2A): county remains legal source of truth; on-chain holds a deed-reference pointer only; explicit disclosures; legal review. Path 1 pursued as vision. |
| **R-02** | Public on-chain listings/bids leak pricing & negotiation data, eroding AI-matching moat | 4 | 4 | **16** | Use permissioned chain or commit-reveal w/ hashed bids; keep raw data off-chain; reveal only on settlement. |
| **R-03** | AI matching central to MVP increases build risk & explainability/bias surface | 3 | 4 | **12** | Ship rule-based matching first; layer ML inference behind explainability log; human-approval gates. |
| R-04 | Unlicensed real-estate activity / acting as broker without license | 4 | 5 | **20** | Licensed broker-of-record supervises all sale-side activity; start with rentals; per-state legal map. |
| R-05 | Fair-Housing violation via AI steering on protected classes | 3 | 5 | **15** | Hard deterministic guardrail; no optimization on protected classes/proxies; audit + bias testing; legal sign-off. |
| R-06 | Smart-contract exploit drains escrow funds | 2 | 5 | **10** | Independent audit; bug bounty; withdrawal limits; pause/timelock; insurance. |
| R-07 | CLARITY Act / token rules don't pass → any token model stranded | 3 | 4 | **12** | Avoid token issuance entirely in MVP; rely on regulated stablecoin under GENIUS. |
| R-08 | Stablecoin issuer freeze/seizure (GENIUS-mandated) disrupts a live escrow | 2 | 3 | **6** | Design contracts to handle freeze gracefully; multi-issuer support; clear user terms. |
| R-09 | Geo-location spoofing fakes a walkthrough condition | 3 | 3 | **9** | Device attestation, multi-signal verification, human confirmation for high-value steps. |
| R-10 | Escrow float treated as revenue but yield ruled impermissible | 3 | 3 | **9** | Do not model float yield as revenue until rules settle. |
| R-11 | Legacy-industry resistance / low adoption | 3 | 3 | **9** | Land-and-expand with landlords; quantify savings; concierge onboarding. |
| R-12 | Per-state regulatory fragmentation slows expansion | 4 | 3 | **12** | Launch in 1–2 favorable states; build compliance as config, not code. |
| R-13 | Malicious/compromised integration partner harms users (fraud, data, fund theft) | 3 | 5 | **15** | Curated-only program (Sec 3A.2): licensing + security + data audit pre-launch; signed connectors; continuous monitoring & rapid offboarding; no open marketplace at launch. |

> **TOP EXISTENTIAL RISKS** — R-04 (unlicensed brokerage), R-01 (ownership/title), R-05 (fair housing), and R-13 (malicious partner) are the ones that can end the company rather than dent it. Most are legal, not technical. Budget for real estate + securities counsel before writing production contracts — the highest-leverage spend in the plan.

---

## 8. Competitive Landscape

The space is real and occupied, but no incumbent combines AI dual-agent representation + rental automation + stablecoin escrow under the post-GENIUS framework. The gap is integration, not invention.

| Competitor | What they do | Gap you exploit |
|---|---|---|
| Propy | Category leader; full on-chain transaction workflow, escrow/title coordination; ~$500M US sales facilitated in 2025 | Focused on sale transactions, not rental automation or AI dual-agent matching; still records deeds traditionally |
| Ubitquity | Blockchain title/record management, tamper-proof ownership records | Records layer only — no AI agent, no consumer transaction experience |
| Deedcoin | Token incentives layered on traditional brokerage to cut costs | Still brokerage-centric; no AI agent, no rental suite |
| BitRent | Connects investors & developers for early-stage capital | Investment/tokenization play, not consumer rent/buy |
| Legacy PropTech (Zillow, Redfin) | Listings, leads, some transaction tooling | Built around agents & MLS; no disintermediation, no smart-contract settlement |
| Property-mgmt SaaS | Rent collection, leases, maintenance | No AI matching, no on-chain escrow, no buy-side path |

### 8.1 Positioning Statement

> **POSITIONING** — For small landlords (and later FSBO sellers and budget buyers) who resent paying 5–10% to intermediaries for coordination work, [HomeChain] is an AI-mediated housing platform that conducts the transaction end-to-end with human approval and settles money + milestones through transparent smart contracts — delivering the agent's coordination and documentation at a fraction of the cost. Unlike Propy (sale-only, no AI agent) or property-management SaaS (no settlement, no matching), [HomeChain] unifies AI representation, rental automation, and on-chain escrow.

### 8.2 Co-opetition: Competitors as Ecosystem Participants

If the platform is the connective layer (Section 3A), then many "competitors" are better treated as supply than as enemies. A property-management SaaS, a title company, or a lender each owns a vertical the platform needs; inviting them in as validated plugins converts a competitive front into distribution and inventory. This is the standard platform move — grow the ecosystem rather than out-build every vertical.

**The strategic logic:**

- **Connection beats replacement.** Building best-in-class lending, title, and inspection in-house is years of work; integrating validated providers is months. The platform's value is the graph and the trusted rails, not each vertical.
- **Plugins deepen the moat.** Every integrated service raises switching costs and makes the platform the default surface where transactions happen — the network-effect flywheel.
- **Curated, not open (consistency with 3A.2).** Plugin partners pass the same vetting program. "Ecosystem" never means "unvetted" in a domain touching money and title.

**Where co-opetition does NOT apply — the lines to hold:**

- **Direct platform substitutes.** A rival that is also an AI-mediated end-to-end transaction layer (e.g. a future Propy pivot) is a competitor, not a plugin — integrating it would commoditize the core.
- **Anything that would re-introduce the middleman cost** the platform exists to remove.
- **Revenue-share discipline.** Plugins must be margin-accretive; a partner taking a large cut of each deal can quietly rebuild the 5–6% you set out to kill.

> **ECOSYSTEM VERDICT** — Yes — foment the ecosystem. Treat vertical-service competitors (PM SaaS, lenders, title, inspection, insurance) as validated plugin partners that supply inventory and distribution. Hold the line only against direct end-to-end substitutes and any integration that re-imports intermediary cost. The plugin program is the same curated, vetted pipeline as 3A.2 — ecosystem breadth with gatekept trust.

---

## 9. Phased Roadmap & Open Items

### 9.1 Phase Gates

| Phase | Focus | Exit criteria to advance |
|---|---|---|
| Phase 0 | Legal foundation + testnet build | Counsel sign-off on structure; working escrow + lease on testnet; broker-of-record secured |
| Phase 1 (MVP) | Rental automation for landlords | 50 landlords / 250 units; clean compliance record; positive unit economics |
| Phase 2 | Home-buying transaction suite | Repeatable FSBO/buyer flow with broker oversight; multi-state legal map |
| Phase 3 | Financing & utility modules | Only after regulatory clarity on refi/mortgage + token rules |

### 9.2 Open Items Requiring Founder / Counsel Input

1. Engage real-estate + securities counsel before any production contract work (highest priority).
2. Select 1–2 launch states with favorable rental + crypto regulatory posture.
3. Decide bid privacy approach: permissioned chain vs. commit-reveal (resolves R-02).
4. Confirm whether ownership representation is strictly a deed-reference (resolves R-01).
5. Validate the bottom-up TAM (Section 10) against real willingness-to-pay research.
6. Choose KYC/AML and stablecoin partners.
7. Define exact monetization numbers (per-unit fee, take-rate).

### 9.3 Document Status

This is a v1.0 founder-review draft. Numbers marked illustrative are placeholders pending the planning phase. The three founder-directed risk decisions (R-01, R-02, R-03) are recorded as deliberate choices and recommended for revisit at the Phase-1 gate.

---

## 10. Market Sizing (Bottom-Up TAM/SAM/SOM)

This replaces the directional figure in Section 2.3 with a bottom-up model built from primary market data. All driver figures are cited; the multiplication is illustrative and should be stress-tested with real pricing during planning.

### 10.1 Phase 1 — Rental Automation TAM

Market drivers (sourced):

- **~46 million** renter-occupied units in the US (single- and multi-family), 2025. [Statista, Residential Rental Market, May 2026]
- **15.7 million** single-family rentals specifically; **89.6%** owned by landlords holding 1–5 properties — the mom-and-pop segment that is the Phase-1 target. [BatchData via ResiClub, Sept 2025]
- US rental housing market valued at **~$1.85 trillion** (2025), growing ~3% CAGR. [Market Data Forecast, May 2026]
- Property-management fees typically run **8–10%** of collected rent — the cost the platform displaces. [Industry benchmark; confirm in planning]

| Layer | Units / basis | Annual revenue basis (illustrative) |
|---|---|---|
| TAM | ~46M rental units | At $25/unit/mo SaaS → ~$13.8B/yr addressable software spend |
| SAM | ~14M small-landlord SFR units (89.6% of 15.7M) | At $25/unit/mo → ~$4.2B/yr |
| SOM (3-yr) | ~0.5% of SAM ≈ 70K units | At $25/unit/mo + rent-throughput fee → ~$21M/yr ARR target |

A rent-throughput fee (a small basis-point charge on stablecoin rent processed) is additive to the per-unit SaaS line and can exceed it at scale; modeled separately because it depends on payment-rail economics and the unresolved stablecoin-yield question (R-10).

### 10.2 Phase 2 — Home-Sale Transaction TAM

Market drivers (sourced):

- **~4.1 million** existing-home transactions completed in 2025; running at a **~4.0–4.1M** annualized rate into 2026. [Statista, Apr 2026; Trading Economics, May 2026]
- Median existing-home price **~$398,000** (early 2026). [NAR via Trading Economics, May 2026]
- Average total commission **5.44%** (2025), split roughly between the two sides. [Clever Real Estate via PRNewswire, June 2025]

| Layer | Basis | Annual revenue basis (illustrative) |
|---|---|---|
| Commission pool (TAM) | 4.1M × $398K × 5.44% | ~$88.8B/yr in total US commissions — the displaceable pool |
| SAM | FSBO + low-fee-seeking, ~10% of transactions | ~$8.9B/yr equivalent value |
| SOM (early) | Flat fee (e.g. $2,500) × 5,000 deals/yr | ~$12.5M/yr at modest penetration |

> **WHY THE FLAT-FEE FRAME WINS** — Against a ~$21,600 average commission on a $398K home (at 5.44%), a flat platform fee of a few thousand dollars is a one-to-two order-of-magnitude saving for the consumer while still being high-margin software revenue. The TAM is the commission pool, but the pitch is the spread between what the seller pays today and what they would pay the platform.

### 10.3 TAM Caveats

- Per-unit and per-deal prices above are placeholders — set them from real willingness-to-pay research before fundraising.
- SOM percentages assume successful state-by-state rollout (Section 11) and are deliberately conservative.
- These are revenue-basis figures, not profit; payment-rail, KYC, audit, and compliance costs must be netted in the financial model.

---

## 11. State-by-State Legislative & Launch Strategy

This section supports both the Phase-2 launch sequencing (where to operate first) and the Path 1 vision (Section 2A.3 — advancing on-chain records toward recognized authority). States are tiered by existing statutory groundwork.

### 11.1 Tier 1 — Established Groundwork (launch + lobby here first)

| State | Statutory groundwork | Strategic read |
|---|---|---|
| Wyoming | First state to enact blockchain-enabling laws (2018–19); recognizes digital assets as property under UCC Title 34.1; SPDIs for blockchain banking; DAO-LLCs (SF38, 2021); ~13 blockchain laws 2018–19. Teton County–Medici Land Governance MOU to migrate land records on-chain. [Lexology 2022; Digital Ascension 2026; LTAMS 2019] | Most advanced statutory infrastructure in the US and an actual county land-record pilot. Primary candidate for the Path 1 flagship and a friendly first home-sale launch. |
| Vermont | 12 V.S.A. § 1913 grants blockchain records evidentiary standing (VT Rule of Evidence 803(6)); Act 205 (S.269, 2018) mandated review of blockchain for land records; first US blockchain property pilot (Propy, Chittenden County, 2018). [VT Legislature; Green Building Law 2018] | Strongest evidentiary recognition + real estate pilot precedent. Best proving ground for the deed-reference model with legal cover. |
| Arizona | HB 2417 (2017) recognizes blockchain signatures & smart contracts as electronic records; SB 1084 directs agencies toward electronic records. [Green Building Law 2018] | Smart contracts explicitly recognized — lowers enforceability risk for the on-chain lease/escrow modules. |

### 11.2 Tier 2 — Recognition Without Land-Record Focus

| State | Statutory groundwork | Strategic read |
|---|---|---|
| Washington | Recognized blockchain & smart contracts (2018–19); workgroup bills named real estate & public record-keeping as exploration areas; formal e-recording framework under WAC 434-661 (Sec. of State — standards, portals, e-signatures). Consumer-protection/money-transmitter-cautious on crypto. [StateScoop 2022; Propy 2019; WAC 434-661] | Founder home state. Strong Path-2 operating state — e-recording already supported. Weaker Path-1 flagship; stablecoin/custody faces more friction than WY. See 11.2a. |
| Montana | SB 426 (2025) modernized UCC for digital assets; SB 265 (2025) protects self-custody/nodes/staking + network-token certification & securities exemption; SB 330 created a Blockchain Task Force. [MT Task Force, Dec 2025] | Fast-advancing, self-custody-friendly, active task force. Strong emerging Tier-1 candidate. |
| Tennessee | Recognized legal authority of blockchain & smart contracts in electronic transactions (2018). [Propy 2019] | Early recognition; secondary expansion target. |
| Ohio | SB 220 / SB 300-era provisions deem blockchain-secured records and signatures electronic records with legal standing. [Green Building Law 2018] | Electronic-record recognition supports document/signature flows; no land-record mandate yet. |
| Texas | Active state real-estate research on blockchain (TRERC); large transaction volume; no dedicated land-record statute yet. [TRERC, Aug 2025] | Huge market, watch-and-engage; Phase-2+ expansion target. |
| Florida | Cited in crypto circles but lacks Wyoming-grade statutory infrastructure. [Digital Ascension 2026] | Large market; engage once template is proven. |

### 11.2a Washington State — Founder Home-State Deep Dive

Because WA is the founder's home state and a natural first-operations candidate, it warrants a fuller read across the two paths:

- **Recording (Path 2) — strong.** WAC 434-661 gives WA a published electronic real-property recording standard administered by the Secretary of State, including portals, business rules, security, and e-signature provisions. The "originate the transaction, county records the deed as the automated last step" model is directly supported — arguably a better near-term operating fit than states with crypto statutes but weaker e-recording rails.
- **Smart-contract enforceability — adequate.** WA recognized blockchain and smart contracts in 2018–19 and named real estate as an exploration area, lowering enforceability risk for on-chain lease/escrow logic.
- **Stablecoin / custody (settlement) — more friction.** WA is more consumer-protection and money-transmitter-cautious than Wyoming. GENIUS helps federally, but WA-specific money-transmission and custody counsel is needed before moving real funds.
- **Path-1 flagship — not first choice.** For the on-chain-record-of-authority vision, Wyoming and Vermont remain stronger flagships; WA is better as a high-value Path-2 launch and later Path-1 follower.

> **WASHINGTON VERDICT** — Launch operations in WA early on the strength of its e-recording framework and home-state advantage, but run settlement through the GENIUS-compliant stablecoin with WA money-transmission counsel, and keep the Path-1 legislative flagship in Wyoming/Vermont. WA is a top-tier operating state, a second-tier policy-change target.

### 11.3 Sequenced Engagement Plan

1. **Launch operations** (Path 2 MVP, needs no law change) in Wyoming + Vermont first — friendliest posture, real precedent, manageable size.
2. **Pilot the deed-reference model** in Vermont, leaning on § 1913 evidentiary recognition for legal cover.
3. **Engage Wyoming** (Blockchain Task Force lineage, Teton County precedent) as the flagship for a recognized on-chain land-record — the Path 1 wedge.
4. **Build compliance as configuration, not code** (R-12) so each new state is a config change, not a rewrite.
5. **Expand to Tier 2** (Washington and Montana early given strength; then Ohio, Texas, Florida) once the template and savings data are proven.
6. **Federal tailwind:** position under GENIUS-Act stablecoin rails now; monitor CLARITY-Act progress (Section 1) before any token-based feature.

> **PATH 1 AS POLICY PROGRAM** — Completing the vision — on-chain records as recognized authority — is a multi-year legislative program, not a product release. The credible investor narrative: "We operate profitably today under Path 2; every state we enter, we also advance the statutory groundwork toward Path 1, compounding a regulatory moat no pure-software competitor is building." The groundwork already exists in Wyoming and Vermont; the company's job is to complete it.

---

*Citations reference public sources gathered during research (NAR/Clever commission data, GENIUS/CLARITY Act coverage, state statutes and reports, market-size sources). Figures marked illustrative are placeholders pending the planning phase. This document is a founder-review draft and not legal advice — engage qualified real-estate and securities counsel before production.*
