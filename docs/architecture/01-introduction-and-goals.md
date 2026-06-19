# ARC-01 — Introduction and Goals

| | |
|---|---|
| **Doc ID** | ARC-01 · arc42 §1 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

## 1.1 What HomeChain Is

HomeChain (repository: Hearth2Home; product name placeholder) is a housing-transaction platform that replaces the human intermediary's coordination role with **two AI agents — one representing each party** — and settles money and milestone events through **smart-contract escrow on a regulated stablecoin**. Humans retain decision authority via approval gates; every agent decision is captured in an attributable audit trail.

- **Phase 1 (MVP):** rental & lease automation for small-to-mid landlords and independent property managers — recurring per-unit SaaS revenue plus stablecoin rent throughput.
- **Phase 2:** home-buying transaction suite under broker-of-record supervision, with the county-recorded deed as the automated final output of a platform-owned pipeline ("Path 2", README §2A.2).
- **Long-horizon vision ("Path 1"):** on-chain records advancing toward recognized legal authority — a policy program, not a product feature, and explicitly **not** an MVP assumption.

## 1.2 Driving Requirements (condensed from scope)

| # | Requirement | Source |
|---|---|---|
| DR-1 | Dual AI agent representation with human approval on every material term | README §3.1, §4.2 |
| DR-2 | Programmable escrow & rent settlement in a regulated third-party stablecoin (no native token) | README §1, §6.2 |
| DR-3 | County recorder remains the legal source of truth; chain holds references/commitments only | README §2A.2, R-01 |
| DR-4 | 100% of milestone events captured in a timestamped, attributable audit trail | README §3.2 |
| DR-5 | Hard, deterministic fair-housing guardrail outside the model | README §4.2 warning, R-05 |
| DR-6 | Curated, validated oracle/integration layer as the core platform asset | README §3A |
| DR-7 | Broker-of-record supervision of all regulated activity | README §4.6, R-04 |
| DR-8 | Compliance implemented as per-state configuration, not code forks | README R-12, §11.3 |
| DR-9 | Rental lease execution < 48 h from match to signed + funded | README §3.2 |
| DR-10 | Custodial wallet UX — users never touch keys or gas | README §4.1, §6.2 |

## 1.3 Stakeholders

| Stakeholder | Role | Architecture expectation |
|---|---|---|
| Founder | Product & strategy owner | Decisions R-01/R-02/R-03 honored; revisit points flagged at Phase-1 gate |
| Landlords / property managers (Priya, Marcus) | Paying customers (Phase 1) | Reliability of rent collection; lower cost than 8–10% PM fee; simple UX |
| Tenants | Counterparty users | Fair treatment, transparent terms, lawful deposit handling, no crypto friction |
| FSBO sellers / buyers (Phase 2) | Paying customers (Phase 2) | Safe escrow, lawful closing, large savings vs. commission |
| Broker-of-record | Licensed supervisor | Complete review queue, veto power, defensible record of supervision |
| Real-estate / securities counsel | Legal gatekeeper | Architecture exposes clear control points; nothing forecloses legal options |
| Integration partners | Supply ecosystem | Stable connector spec, sandbox, fair vetting, fast onboarding |
| Regulators / auditors | External scrutiny | Reconstructable transactions; tamper-evident records; fair-housing evidence |
| Smart-contract auditors | Pre-mainnet gate | Minimal, analyzable trust kernel with stated invariants |

## 1.4 Quality Goals (ranked — drives every trade-off)

| Rank | Quality | Concrete meaning here |
|---|---|---|
| 1 | **Regulatory compliance & auditability** | Any transaction reconstructable end-to-end by a third party; broker supervision provable; fair-housing behavior demonstrable with evidence |
| 2 | **Fund safety** | Escrowed money can never move to an arbitrary destination; bounded blast radius; freeze/dispute states never strand funds permanently |
| 3 | **Fairness & explainability** | Matching/negotiation outputs reproducible from an allowlisted feature set; protected classes architecturally unreachable by models |
| 4 | **Privacy** | Negotiation data and PII never on a public chain; on-chain artifacts limited to salted commitments and settlement flows; deletion achievable via crypto-shredding |
| 5 | **Evolvability (state-by-state)** | New state = new validated ruleset configuration, not a code fork |
| 6 | **Availability of obligations** | Legal deadlines (rent due, deposit return) never depend solely on chain liveness; degraded-mode rails exist |

A lower-ranked quality is never bought by sacrificing a higher-ranked one (e.g., we accept slower lease execution if broker review requires it; we accept worse UX if custody compliance requires it).
