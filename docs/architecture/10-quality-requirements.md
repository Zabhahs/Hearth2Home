# ARC-10 — Quality Requirements

| | |
|---|---|
| **Doc ID** | ARC-10 · arc42 §10 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

Quality tree per ARC-01 §1.4 ranking. Scenarios are testable acceptance criteria for the architecture; several become standing CI/monitoring gates.

## Q1 — Compliance & Auditability

| ID | Scenario | Measure |
|---|---|---|
| Q1-1 | An external auditor, given read access, reconstructs a complete lease transaction (every decision, approval, document, payment) | ≤ 1 person-day, no engineering help; audit-chain verification passes |
| Q1-2 | A regulated action is attempted without broker approval | Architecturally impossible: workflow cannot reach approved state without broker case ID; attempt is logged |
| Q1-3 | Audit log tampering (row edit/delete in DB) | Detected by hash-chain verification + on-chain anchor mismatch within 24 h |
| Q1-4 | Fair-housing audit request (regulator) | Paired-test reports + per-decision explanations producible for any date range |
| Q1-5 | Generated lease challenged in court | Document + e-sign evidence package + ruleset version + identity binding chain retrievable from WORM storage for ≥ retention period |

## Q2 — Fund Safety

| ID | Scenario | Measure |
|---|---|---|
| Q2-1 | Compromise of any single platform service key | Cannot move escrow funds to an arbitrary address: vault only pays the agreement's party set; custody policy engine independently enforces limits |
| Q2-2 | Invariant: vault solvency | On-chain balance ≥ Σ recorded obligations; continuously monitored; fuzz-verified pre-deploy |
| Q2-3 | Emergency pause during active leases | New operations halt; party-withdrawal paths remain executable (pause never strands funds) |
| Q2-4 | Issuer freezes the stablecoin backing live escrows | R5 runbook completes: rails suspended, obligations re-routed or held lawfully, parties notified ≤ 24 h |
| Q2-5 | Governance attack (malicious upgrade) | Vault immutable; periphery upgrade visible during timelock ≥ 48 h; monitored + alertable; multisig 3-of-5 geographically separated |

## Q3 — Fairness & Explainability

| ID | Scenario | Measure |
|---|---|---|
| Q3-1 | Paired profiles differing only in protected attribute (or known proxy) | Match-score distributions statistically indistinguishable (pre-registered threshold); CI-blocking |
| Q3-2 | Any surfaced match | Reproducible from allowlisted feature vector + scoring version; per-feature contribution shown to user |
| Q3-3 | Attempt to add a feature to matching | Schema change requires guardrail-service allowlist review (four-eyes incl. compliance) |
| Q3-4 | Agent negotiation outcome questioned | Full round-by-round term-sheet deltas + model/prompt versions retrievable |

## Q4 — Privacy

| ID | Scenario | Measure |
|---|---|---|
| Q4-1 | Deletion request from a former user | PII erased/anonymized off-chain; on-chain commitments unlinkable via salt destruction (crypto-shredding); completion ≤ statutory window |
| Q4-2 | Chain analyst examines public L2 state | Recovers: pseudonymous flows + commitments only; no listing terms, identities, or negotiation data (until reveal-at-settlement per ADR-0011) |
| Q4-3 | Pre-settlement bid leakage attempt (dictionary attack on commitments) | Infeasible: per-record salts ≥ 128-bit, off-chain |

## Q5 — Evolvability

| ID | Scenario | Measure |
|---|---|---|
| Q5-1 | Enter a new state | New ruleset + counsel approval + template pack; **zero code changes** for parameterized rules; ≤ 2 weeks calendar |
| Q5-2 | Swap stablecoin issuer | Config + liquidity migration runbook; no contract redeploy (PaymentRouter multi-issuer) |
| Q5-3 | Replace KYC/CRA/e-sign vendor | Adapter interface bounded; ≤ 1 sprint integration |

## Q6 — Availability of Obligations

| ID | Scenario | Measure |
|---|---|---|
| Q6-1 | Base sequencer down 24 h on rent day | Rent obligations tracked, notices correct, no late fees caused by platform; settlement defers or falls back to ACH |
| Q6-2 | Custody provider outage 8 h | Time-critical disbursements re-routed per runbook; no statutory deadline breached |
| Q6-3 | Core API region incident | RTO ≤ 4 h, RPO ≤ 5 min (ARC-07 §7.4) |

## Performance & Cost Envelopes (initial, non-binding)

- Match request → ranked results: p95 ≤ 2 s (rule-based path).
- Negotiation round (agent → validated delta): p95 ≤ 30 s; full negotiation ≤ 24 h including human gates (supports DR-9's 48 h target).
- Rent-run throughput: 10k units/hour headroom at MVP scale (trivial for L2 + batch design; constraint is dunning workflows).
- LLM cost ceiling per completed lease: low single-digit dollars — negligible vs. revenue; tracked per transaction in Billing.
