# ANL-01 — Requirements Traceability Matrix

| | |
|---|---|
| **Doc ID** | ANL-01 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

Traces every scoped feature (README §4, Modules A–F, with MoSCoW/Phase) to owning components (ARC-05), runtime scenario (ARC-06), and governing decisions/risks. **Validation rule:** every Phase-1 "M" must have all four columns filled — verified in ANL-04.

## 1. Feature Traceability

| Feature (README) | MoSCoW/Ph | Component(s) | Runtime | Decisions / risk controls |
|---|---|---|---|---|
| **A** KYC/AML both parties | M/1 | KYC & Screening; vendor | R1 | C-T8; DSN-06 §4; R-04 adjacency |
| **A** Landlord/unit profiles | M/1 | Identity & Access; Listings & Units | R1 | ADR-0004 (off-chain) |
| **A** Tenant/buyer intake | M/1 | Intake Pipeline; Matching | R2 | ADR-0009 (allowlist extraction) |
| **A** Custodial wallet provisioning | M/1 | Smart Accounts; custody provider | R1 | **ADR-0007 (variant B default)**; TR-03 |
| **A** Reputation / tx history | S/2 | MilestoneRegistry attestations + PG projections | — (P2) | ADR-0004; privacy review at P2 gate |
| **B** Conversational intake | M/1 | Intake Pipeline (LLM) | R2 | DSN-04 §4; TR-01 controls |
| **B** Aesthetic ingestion (boards/images) | S/1 | Vision pipeline → style descriptors | R2 (1c) | Consent records; ADR-0009 bounded descriptors |
| **B** Preference inference | C/1 | Matching (suggestions w/ reasoning only) | R2 (1c) | DSN-04 §4 anti-manipulation stance |
| **B** Match scoring + explanations | M/1 | Matching Service | R2 | **ADR-0010**; Q3-2 |
| **B** Seller-side optimization | S/1 | Matching (lawful criteria only) | R2 | **ADR-0009 hard wall; AC-1**; R-05 |
| **B** Dual-agent negotiation w/ gates | M/1 | Agent Runtime; Negotiation Orchestrator; Guardrail Proxy | R2 | **ADR-0016, ADR-0009**; DR-1; TR-01 |
| **B** Decision explainability log | M/1 | Explainability Logger; Audit | R2 | ADR-0012; Q3-4; TR-06 |
| **C** Listings on-chain | S/1 | CommitmentLog | R2 | **ADR-0011 (commit-reveal) — founder gate**; R-02 |
| **C** Bids/offers on-chain | S/1 | CommitmentLog | R2/R7 | ADR-0011; Q4-3 |
| **C** Tokenized deed-reference | C/2 | DeedReference NFT | R7 | **ADR-0002**; R-01 |
| **C** Ownership attestation oracle | C/2 | Read oracles; MilestoneRegistry | R7 | ADR-0002 (non-authoritative); DSN-03 §5 |
| **C** Listing detail off-chain mutable | M/1 | Listings & Units (PG) | R2 | ADR-0004 |
| **D** Programmable escrow | M/1 | EscrowVault; Payments Orchestrator | R2, R4 | **ADR-0014**; Q2 invariants; R-06 |
| **D** Smart-contract lease w/ encoded terms | M/1 | LeaseRegistry + legal doc (WORM) | R2 | Legal-text-governs rule (DSN-01 LEASE); C-L9 |
| **D** Automatic rent collection | M/1 | PaymentRouter; Rail Router; dunning | R3 | **ADR-0017 (session grants)**; ADR-0018; Q6-1 |
| **D** Auto rent-increase (lawful caps) | S/1 | Compliance Engine + Payments | R3 | ADR-0013 ruleset params; grant re-issue (ADR-0017) |
| **D** Security-deposit lifecycle | M/1 | EscrowVault; deposit saga | R4 | **G-02 deposit-rail legality per state**; statutory timers |
| **D** Late-fee / grace automation | S/1 | Dunning & Grace + ruleset | R3 | ADR-0013 |
| **D** Smart utility management | C/2 | Utility connectors | — (P2) | DSN-03 lifecycle |
| **D** Refi / 2nd mortgage / assistance | W/2+ | — (deliberately absent) | — | Scope wall (README §3.3) |
| **E** Geo-verified walkthrough | S/1 | Mobile App; Attestation | R6 | R-09; T3 cap; D-5 |
| **E** Oracle layer (Functions/CCIP) | M/1 | Integration plane (all) | R2–R7 | **ADR-0008**; DSN-03 |
| **E** Connector SDK + sandbox | M/1 | Connector Host; Registry | — | DSN-03 §2; R-13 |
| **E** Partner vetting & monitoring | M/1 | Partner Registry; Partner Ops | — | DSN-03 §2; AC-4 |
| **E** County/tax read oracle | S/2 | Read oracles | R7 | ADR-0002 |
| **E** Vertical connectors (lender/utility/title/inspection) | S/2 | Connector Host | R7 | DSN-03 |
| **E** Off-chain refresh w/o chain writes | M/1 | Normalizer default path | — | DSN-03 §1 |
| **F** Broker-of-record dashboard | M/1 | Broker Dashboard; Case Mgmt | R2, R4, R7 | **R-04 control**; Q1-2 |
| **F** Full timestamped audit trail | M/1 | Audit Log Service | all | **ADR-0012**; Q1-1, Q1-3 |
| **F** Disclosure & doc generation | M/1 | Lease & Document Service | R2 | ADR-0013; DSN-06 §5 |
| **F** Fair-housing guardrail | M/1 | Guardrail Service (Compliance + AI planes) | R2 | **ADR-0009**; Q3-1; R-05 |
| **F** Dispute / override workflow | S/1 | Case Mgmt; vault freeze paths | R4, R5 | DSN-06 §8; C-L11 |

**Architecture-added requirements** (from gap analysis, recommended into scope): FCRA adverse-action workflow (G-01 → DSN-06 §6, M/1); ACH fallback rail (G-04 → ADR-0018, M/1); deposit-rail state gating (G-02 → ruleset, M/1); reconciliation & finality machinery (G-06 → ARC-08 §8.4, M/1).

## 2. SMART Objectives → Architectural Support

| Objective (README §3.2) | Architectural support |
|---|---|
| ≥60% cost savings | Parameterized Billing (C-O5); automation of coordination labor (R2); flat-fee P2 framing unaffected by architecture |
| Lease < 48 h match→signed+funded | Saga pipeline w/ SLA timers (ADR-0015); broker fast-path checklists (DSN-06 §2); p95 envelopes (ARC-10) |
| 50 landlords / 250 units in 6 mo | Increment plan 1a monetizes before full chain stack (ARC-04 §4.3) |
| 100% milestone audit trail | ADR-0012 + Explainability Logger; Q1 scenarios |
| Zero unlicensed-activity actions | Broker case-first workflow (Q1-2); activity gating per ruleset; ADR-0007 custody posture |

## 3. README Risk Register → Architectural Controls

| Risk | Exp | Control(s) in this architecture |
|---|---|---|
| R-01 title confusion | 15 | ADR-0002; DeedReference disclosures (DSN-06 §7) |
| R-02 listing/bid leakage | 16 | ADR-0011 commit-reveal + salts; Q4-2/4-3 |
| R-03 AI-matching build risk | 12 | ADR-0010 rule-based first; ADR-0009; eval program (DSN-04 §7) |
| R-04 unlicensed brokerage | 20 | Broker case-first (Q1-2); per-state activity gating; DSN-06 §1-2 |
| R-05 fair-housing violation | 15 | ADR-0009 three layers; paired-test CI gate (Q3-1); AC-1 |
| R-06 contract exploit | 10 | DSN-02 invariants; immutable vault (ADR-0014); audit+bounty; Q2 |
| R-07 token rules stall | 12 | ADR-0006 — no token exists to strand |
| R-08 issuer freeze | 6 | Multi-issuer + circuit breakers; R5 runbook; ADR-0018 fallback |
| R-09 geo spoofing | 9 | Attestation + dual confirmation; T3 cap (DSN-03 §4); D-5 |
| R-10 float-yield assumption | 9 | Billing models SaaS + throughput only (ADR-0006) |
| R-11 adoption resistance | 9 | ADR-0018 (no crypto prerequisite); explainability as product (ARC-08 §8.10) |
| R-12 state fragmentation | 12 | ADR-0013 rulesets; Q5-1 |
| R-13 malicious partner | 15 | DSN-03 §2 lifecycle; sandbox+egress allowlists; N-of-M; AC-4 |

All 13 risks have at least one named architectural control. Confirmed in ANL-04 §2.
