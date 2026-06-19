# DSN-06 — Compliance & Audit Architecture

| | |
|---|---|
| **Doc ID** | DSN-06 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review — design support for counsel, **not legal advice** |

## 1. Compliance Surface Map (what regime touches which component)

| Regime | Trigger here | Owning components |
|---|---|---|
| RE licensing / brokerage law (R-04) | Matching, negotiation facilitation, leasing activity (state-dependent), all Phase-2 sale activity | Broker case mgmt; activity gating per ruleset (some states require licensing even for leasing services — per-state legal map is a launch gate) |
| Fair Housing Act + state analogues (R-05) | Matching, agent behavior, advertising | Guardrail Service (ADR-0009); paired-test program; ad-copy lint for listings |
| **FCRA** (gap G-01) | Tenant screening reports | Screening orchestration: permissible purpose, consent, **adverse-action workflow** (notice w/ CRA identity, score disclosures where applicable, dispute rights); state overlays (portable screening reports, fair-chance ordinances) via ruleset |
| State landlord-tenant law | Deposits, late fees, notices, entry, habitability disclosures | Ruleset engine (ADR-0013); deposit-rail legality per state (G-02): stablecoin escrow only where deposit statutes permit; otherwise partner trust-account rail |
| ESIGN/UETA + state e-notary/RON | Lease execution; Phase-2 closing docs | Lease & Document Service ceremony config; evidence packages to WORM |
| GENIUS / money transmission / custody (TR-03) | Stablecoin movement, escrow holding | Custody variant policy (ADR-0007); issuer allowlist (ADR-0006); BSA/AML program design with counsel (KYC, sanctions/OFAC screening incl. counterparty wallets, SAR-equivalent escalation via partners) |
| Good-funds statutes (P2) | Closing disbursement | Disbursement gates in closing saga (ARC-06 R7) |
| Recording law / PRIA practice (P2) | Deed package, e-recording | Recording connector; county-rejection workflows |
| Consumer privacy (state acts where applicable) | PII handling, deletion | DSN-01 §5 classes; crypto-shredding (Q4-1) |
| Tax information reporting | Rent processing may create 1099-class duties (platform/landlord) | Billing/ledger exports; **counsel/tax determination required** (G-08) |
| ADA / WCAG | Consumer-facing surfaces | WCAG 2.2 AA (ARC-08 §8.10) |

## 2. Broker-of-Record Workflow (R-04 control)

- **Case-first design:** any regulated action (listing publication where required, lease execution, sale-side steps, escrow overrides) requires an open BROKER_CASE; the approval object references it (Q1-2 "architecturally impossible without").
- Queues with SLA timers (48 h lease target, DR-9, includes broker SLA); risk-tiered review depth (checklist fast-path for standard leases; full review for exceptions).
- Broker actions: approve / reject with reason / request changes / freeze transaction. All recorded; broker sees the same explainability record the parties do.
- Supervision reporting: per-period digest of actions taken under the broker's license — the broker's own regulatory file (Q1-1 supports it).

## 3. State Ruleset Engine (operational view)

Parameter families: deposit (cap, rail legality, segregation/interest, return deadline, itemization requirements), fees (late-fee formula caps, grace), notices (increase, entry, termination, nonpayment), rent control overlays, screening restrictions, disclosures (lead paint pre-1978 federal; state/local addenda), execution (RON availability, witness requirements), records (retention years).

Workflow (ADR-0013): legal-ops drafts → counsel reviews (sign-off recorded) → activated with effective date → telemetry: every automated computation logs `(ruleset_id, version, parameters_used)`.

## 4. KYC / AML / Sanctions

Vendor-orchestrated IDV at onboarding (both parties — Module A "M"); OFAC/sanctions screen at onboarding + periodic re-screen + counterparty wallet screening before on-chain settlement; risk-tiered review (manual queue); record-keeping per program design. The formal BSA/AML program (whether ours or inherited via custody partner per ADR-0007 variant) is a **counsel deliverable before mainnet funds** (ANL-04).

## 5. Document & Records Management

Attorney-reviewed template packs per state (lease, addenda, disclosures, adverse-action letters, notices); generation stamps template + ruleset versions; e-sign ceremony evidence (identity binding, timestamps, IP/device metadata) archived with the executed document to WORM (C-L12 retention classes per DSN-01 §5); legal-hold flags suspend any expiry.

## 6. Adverse-Action Workflow (G-01 closure)

Decline / approve-with-conditions based wholly or partly on a screening report → generate compliant notice (CRA name/address/phone, right to free report, dispute rights, score factors where applicable) → delivery-tracked → logged with the decision basis snapshot. Landlord-initiated declines route through the same workflow — the platform cannot emit an un-noticed adverse decision.

## 7. Disclosure Inventory (product-level)

- Dual-agent platform operation + information barrier + broker supervision (ADR-0016, DSN-04 §8).
- DeedReference NFT is not title; county record governs (ADR-0002 consequence).
- On-chain visibility of escrow amounts (D-3); rail mechanics & session-grant scope (ADR-0017); issuer-freeze possibility (R-08) in plain language.
- AI-generated explanations are assistive, not legal advice; human approval gates are the decision of record.
- Fee schedule transparency (positioning vs. 5–6% commission, README §8.1).

## 8. Dispute, Override & Lawful Orders

Single intake (party dispute, court order, issuer freeze, regulator inquiry) → case typed & routed (broker, compliance ops, counsel) → entity freezes applied via T4 path (vault FROZEN_LEGAL where funds) → resolution instructions executed with four-eyes → full file exportable for proceedings (Q1-5). Deposit disputes follow ARC-06 R4 with statutory timers visible to both parties.
