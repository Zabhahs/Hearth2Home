# ANL-04 — Architecture Validation Report

| | |
|---|---|
| **Doc ID** | ANL-04 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Complete (desk validation) — items in §5 require founder/counsel |
| **Method** | Coverage analysis · risk-control mapping · internal consistency checks · feasibility cross-check · standards conformance |

## 1. Coverage Validation — PASS

**Rule:** every Phase-1 Must-have feature maps to ≥1 owning component, ≥1 runtime scenario, and ≥1 governing decision (ANL-01 §1).

Result: **18/18 Phase-1 "M" features fully traced.** Should/Could features traced with phase tags; the single "W" (refi/mortgage) verified *absent* from all components (scope wall holds). SMART objectives each have named architectural support (ANL-01 §2).

## 2. Risk-Control Validation — PASS

**Rule:** every README risk (R-01…R-13) has ≥1 named, designed architectural control; every control names its mechanism, not an intention.

Result: **13/13 mapped** (ANL-01 §3). Strongest coverage: R-04 (case-first workflow makes unsupervised regulated actions structurally unreachable), R-05 (three deterministic layers + CI bias gate), R-02 (commit-reveal + crypto-shredding). Weakest (acceptable): R-11 adoption — architecture can only remove friction (ADR-0018); the rest is go-to-market.

New technical risks identified beyond the README register: **16** (ANL-03), of which three score ≥15 — all with designed mitigations.

## 3. Internal Consistency Checks — PASS (after corrections)

| # | Tension found | Resolution |
|---|---|---|
| CC-1 | Scope's "scheduled stablecoin pulls" vs. ERC-20 reality | Corrected by ADR-0017 (scoped session grants); preserves the feature, fixes the mechanism |
| CC-2 | "Upgradeable proxy + timelock" for *all* contracts vs. fund-safety goal Q2 | Corrected by ADR-0014 (immutable vault, upgradeable periphery) |
| CC-3 | Custodial-UX mandate vs. unanalyzed money-transmission exposure | Resolved by ADR-0007 dual-variant with partner-custody default |
| CC-4 | On-chain listings/bids (founder-directed) vs. R-02 privacy | Resolved by ADR-0011 commit-reveal — honors both (pending founder sign-off) |
| CC-5 | 48 h lease cycle (DR-9) vs. broker review gate (DR-7) | Compatible: risk-tiered fast-path checklists (DSN-06 §2) + SLA timers; broker SLA inside the 48 h budget |
| CC-6 | Chain-settled obligations vs. statutory deadlines under chain outage | Resolved by deadline-independence rule (Q6-1) + DEFERRED_CHAIN + dual rails |
| CC-7 | Audit reproducibility vs. LLM nondeterminism | Resolved by log-don't-replay doctrine (ARC-08 §8.3, TR-06) |
| CC-8 | "AI matching central to MVP" (founder) vs. R-03's own mitigation "rule-based first" | Honored both: ADR-0010 sequences rule-based scoring inside an AI-led product (agents/intake remain LLM-driven from day one) |
| CC-9 | Deletion rights vs. immutable chain | Resolved by PII-never-on-chain (ADR-0004) + crypto-shredding (Q4-1) |

No unresolved internal contradictions remain in the documentation set.

## 4. Feasibility Cross-Check (vs. README §6.1 verdicts)

| Component | Scope verdict | Architecture finding |
|---|---|---|
| AI intake & matching | High | Concur — with guardrail/eval program as the real work (DSN-04 §7) |
| Stablecoin escrow | High | Concur **technically**; legal feasibility is state-dependent for *deposits* specifically (G-02) — verdict should be "High (rent) / Medium (deposits, pending counsel)" |
| Smart-contract lease | Medium | Concur; legal text governs, chain enforces payments (DSN-01 LEASE) |
| Oracle layer | Medium | Concur; per-connector effort is the cost driver (DSN-03 §2 stage 3) |
| Geo-verified walkthrough | Medium | Concur; capped at T3 assurance, never sole gate for large funds (D-5) |
| On-chain listings/bids | Medium ("privacy is the real problem") | Concur; ADR-0011 is the answer |
| On-chain ownership | Low | Concur; reference-only (ADR-0002) |
| Refi/mortgage | Low | Out of scope wall verified |

One addition the scope underweights: **the consistency/reconciliation machinery (G-06) is a Medium-feasibility, high-effort component in its own right** — budgeted as first-class in ADR-0015/ARC-08.

## 5. Open Items Requiring Founder / Counsel Decision (blocking matrix)

| # | Decision | Blocks | Owner |
|---|---|---|---|
| O-1 | Engage RE + securities counsel (README §9.2-1) | Everything legal below; production contracts | Founder |
| O-2 | Launch-state pair selection (README §9.2-2) | Ruleset build; G-01/G-02/G-05 analyses | Founder + counsel |
| O-3 | Custody Variant A vs. B final (ADR-0007) | Increment 1b architecture finalization | Counsel |
| O-4 | Commit-reveal vs. permissioned chain (ADR-0011; README §9.2-3) | CommitmentLog design freeze | Founder (Phase-1 gate at latest) |
| O-5 | Deposit-rail legality per launch state (G-02) | On-chain deposit feature in 1b | Counsel |
| O-6 | KYC, screening-CRA, custody, stablecoin-issuer, ACH vendor selections (README §9.2-6 + additions) | Increments 1a/1b integrations | Founder + counsel |
| O-7 | Monetization numbers (README §9.2-7) | Billing config only (architecture is parameterized) | Founder |
| O-8 | Workflow-engine spike decision (ADR-0015) | Increment 0 backend foundation | Eng lead |
| O-9 | Maintenance-module disposition (G-12: integrate vs. minimal native vs. defer) | Increment 1c scope | Founder |
| O-10 | BSA/AML program design (with custody-variant outcome) | Mainnet funds (1b) | Counsel |

## 6. Standards Conformance

arc42 12/12 sections present · C4 L1/L2 diagrams + L3 tables · 18 ADRs in Nygard format with statuses and revisit triggers · STRIDE model with named abuse cases · MoSCoW traceability 100% for Phase-1 M · risk scoring consistent with the scope's L×I convention.

## 7. Validation Limits (honesty section)

This is a **desk validation**: internally complete and consistent, grounded in the scope document and current (mid-2026) regulatory facts as known. It does **not** substitute for: legal review (multiple gaps are legal questions), security audit (contracts are unbuilt), market validation of pricing (C-O5), or vendor due-diligence outcomes. Statutory references inherited from the README (state laws, acts, market figures) were treated as given; anything load-bearing on them is flagged to counsel rather than asserted as verified law.
