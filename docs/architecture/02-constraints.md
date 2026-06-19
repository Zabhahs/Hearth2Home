# ARC-02 — Constraints

| | |
|---|---|
| **Doc ID** | ARC-02 · arc42 §2 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

## 2.1 Legal & Regulatory Constraints (non-negotiable)

| ID | Constraint | Consequence for architecture |
|---|---|---|
| C-L1 | County recorder is the legal source of title; on-chain "ownership" is a reference only (founder decision, README §2A) | Chain stores deed-reference pointers and commitments; oracle mirrors county data and is labeled non-authoritative |
| C-L2 | **No native token issuance**; settlement uses established regulated USD stablecoins (GENIUS Act framework) | Multi-issuer stablecoin abstraction; no tokenomics anywhere in the design |
| C-L3 | GENIUS Act implementation timing: signed 2025-07-18, but the full regime phases in (effective the earlier of ~18 months post-enactment or 120 days after final rules) | "GENIUS-compliant" is forward-looking in mid-2026; interim reliance on existing state-regulated issuers; counsel confirms issuer selection (Open Item) |
| C-L4 | Fair Housing Act: no steering/filtering on protected classes or proxies — hard wall (README §4.2) | Deterministic guardrail outside models; allowlisted feature schema; paired-profile bias testing as a CI gate |
| C-L5 | No unlicensed brokerage: broker-of-record supervises all sale-side (and, where state law requires, leasing) activity | Broker review queue is a blocking workflow state, not an advisory log |
| C-L6 | Tenant screening using credit/income/background data is an **FCRA consumer report** | Screening only via FCRA-compliant vendor; adverse-action notice workflow required (gap found — see ANL-02 G-01) |
| C-L7 | State security-deposit statutes (segregated/trust accounts, interest, return deadlines) may conflict with on-chain deposit escrow | Deposit rail is a per-state configuration: stablecoin escrow only where lawful; partner trust-account rail otherwise (gap found — ANL-02 G-02) |
| C-L8 | Custodial holding of user stablecoins may trigger state money-transmitter / custody licensing (WA explicitly cautious, README §11.2a) | Two custody variants designed (ADR-0007); default to licensed-partner custody until counsel clears platform custody |
| C-L9 | E-sign validity: ESIGN/UETA; remote online notarization (RON) and e-recording availability vary by state | Signature ceremony per state ruleset; PRIA-standard e-recording vendor integration (Phase 2) |
| C-L10 | "Good funds" laws constrain when escrow may disburse at closing (Phase 2) | Disbursement state machine has jurisdiction-gated timing rules |
| C-L11 | Lawful orders (court freeze, garnishment, issuer freeze under GENIUS) must be honorable | Every fund-bearing contract has pause/override paths with documented governance; R-08 runbook |
| C-L12 | Record retention per state real-estate rules (broker records commonly ≥ 3 years; platform default 7) | WORM document storage with retention classes (DSN-01) |
| C-L13 | Some jurisdictions restrict mandatory electronic-only rent payment | Fiat/ACH fallback rail is a launch requirement, not nice-to-have (ADR-0018) |

## 2.2 Technical Constraints (directed by scope)

| ID | Constraint | Source |
|---|---|---|
| C-T1 | Web: Next.js + TypeScript; Mobile: React Native (geo walkthrough) | README §6.2 |
| C-T2 | EVM chain; L2 for fees (Base/Arbitrum class); testnet-first (Base Sepolia) | README §6.2 |
| C-T3 | Solidity contracts; independent audit before any mainnet funds | README §6.2, R-06 |
| C-T4 | Oracles: Chainlink Functions + CCIP as baseline substrate | README §3A.3 |
| C-T5 | Custodial / account-abstraction wallets (ERC-4337); users never see seed phrases or gas | README §6.2 |
| C-T6 | PostgreSQL primary DB; S3-compatible object storage; pgvector for semantic matching | README §6.2 |
| C-T7 | LLM via API (Claude) with tool use; deterministic guardrails sit outside the model | README §6.2 |
| C-T8 | KYC/AML via third-party vendor (Persona/Alloy-class) | README §6.2 |
| C-T9 | US-only, 1–2 launch states at MVP (WY/VT operating posture; WA early Tier-2) | README §11.3 |

## 2.3 Organizational Constraints

| ID | Constraint | Consequence |
|---|---|---|
| C-O1 | Phase-gated delivery (PMI discipline); rentals before sales | Architecture must not require Phase-2 components for Phase-1 operation |
| C-O2 | Three founder-directed decisions recorded (R-01 resolved via Path 2; R-02 on-chain listings and R-03 AI-centrality to be revisited at Phase-1 gate) | ADR-0011 and ADR-0010 carry explicit revisit triggers |
| C-O3 | Counsel engagement precedes production contract work (README §9.2 item 1) | All "Decision required" items in ANL-04 route through counsel |
| C-O4 | Presumed small founding team at MVP | Modular monolith over microservices (ADR-0003); managed services over self-hosted infrastructure |
| C-O5 | Monetization numbers are placeholders | Billing architecture parameterized (per-unit fee, throughput bps) — no hardcoded pricing |
