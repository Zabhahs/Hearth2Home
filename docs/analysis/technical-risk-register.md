# ANL-03 — Technical Risk Register

| | |
|---|---|
| **Doc ID** | ANL-03 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

Complements README §7 (business/strategic risks R-01…R-13). Same scoring: Likelihood × Impact, 1–5 each. Owner roles are placeholders until the team exists. Review cadence: quarterly re-score (ARC-11 §11.3).

| ID | Risk | L | I | Exp | Mitigation (designed) | Residual / trigger |
|---|---|---|---|---|---|---|
| **TR-01** | **Prompt injection / adversarial content** subverts a negotiation agent (bad proposals, attempted vault leakage, guardrail bypass attempts) | 4 | 4 | **16** | DSN-04 §3: structural separation, read-only tools, deterministic bounds, barrier (ADR-0016), injection corpus as release gate | Residual = nuisance proposals caught at human gates; trigger for re-score: any corpus escape |
| **TR-02** | **Deposit-statute conflict**: stablecoin deposit escrow ruled non-compliant in a launch state after build | 3 | 5 | **15** | Ruleset-gated deposit rail (G-02); partner trust-account alternative designed; counsel pre-launch | If both launch states bar it, on-chain deposits slip to later states; rent settlement unaffected |
| **TR-03** | **Custody/licensing misstep**: platform deemed unlicensed money transmitter / custodian | 4 | 4 | **16** | ADR-0007 Variant B default (licensed partner); per-state counsel analysis gates Variant A | Existential if ignored; managed to low with Variant B |
| **TR-04** | **On-chain/off-chain state divergence** (reorg, missed events, double-processing) causes wrong fund actions or audit contradictions | 3 | 4 | **12** | ARC-08 §8.4: finality policy, idempotent outbox, indexer checkpoints, human-paged reconciliation | Monitored continuously; incident class, not silent corruption |
| **TR-05** | Session-grant lifecycle failures (expiry/revocation mid-lease) break "automatic" rent at scale | 3 | 3 | **9** | ADR-0017 lifecycle owned by Payments Orchestrator; dunning saga; ACH fallback | UX/ops burden, not fund risk |
| **TR-06** | **LLM nondeterminism vs. audit expectations** — outputs can't be replayed for regulators | 4 | 3 | **12** | Complete I/O + model/prompt version capture (Explainability Logger); pinned params; "log, don't replay" doctrine (ARC-08 §8.3) | Communicate doctrine to counsel early |
| **TR-07** | Oracle/DON outage or fee spike stalls attested milestones | 3 | 3 | **9** | DEFERRED_CHAIN states; off-chain truth advances sagas; batched anchoring | Chain attestation lags; business continues |
| **TR-08** | **Base sequencer outage/censorship** during deadline-bearing operations | 3 | 4 | **12** | Q6-1: deadlines never chain-dependent; force-inclusion escape hatch; ADR-0018 rail fallback; ADR-0005 revisit trigger | Accepted residual at MVP (D-2 class) |
| **TR-09** | Vault or periphery contract defect despite audit | 2 | 5 | **10** | DSN-02 invariant fuzzing + audit + bounty + invariant monitors; immutable-vault blast-radius design (ADR-0014); pause-without-stranding (Q2-3) | Mirrors README R-06; kept separate for engineering ownership |
| **TR-10** | Commitment dictionary attacks / salt mismanagement de-anonymize listings or strand proofs | 2 | 4 | **8** | ≥128-bit salts, vault table, access logging (DSN-01); crypto-shredding procedures; Q4-3 | Salt loss = unprovable commitment (operational runbook) |
| **TR-11** | Connector supply-chain compromise (post-vetting) | 3 | 4 | **12** | Signing + sandbox + egress allowlists + anomaly suspension (DSN-03); N-of-M prevents single forged attestation from moving funds | Mirrors README R-13 technical face |
| **TR-12** | Privacy-law deletion demands vs. immutable artifacts | 2 | 3 | **6** | Crypto-shredding (Q4-1); PII never on-chain (ADR-0004); audit retention under legal-obligation basis | Periodic counsel review of basis |
| **TR-13** | Vendor concentration (Chainlink, custody partner, KYC, single L2) | 3 | 3 | **9** | Adapter indirection everywhere (ADR-0008 consequence, Q5-2/5-3); quarterly concentration review | Accepted at MVP |
| **TR-14** | Paymaster griefing / gas-spike economics break sponsored UX | 2 | 2 | **4** | Balance caps, target allowlist, monitoring (DSN-02 §5) | Minor |
| **TR-15** | Fairness regression as models/weights evolve (drift reintroduces proxy bias) | 3 | 4 | **12** | Paired-test CI gate + production sampling (Q3-1, DSN-04 §7); allowlist change control (Q3-3) | The control *is* the moat here |
| **TR-16** | Saga/idempotency discipline erodes as team grows (duplicate money actions) | 3 | 4 | **12** | ADR-0015 conventions, chaos tests (ARC-08 §8.8), reconciliation safety net | Culture + CI enforcement |

## Top Technical Exposures

**TR-01 (16), TR-03 (16), TR-02 (15)** — note all three are *interface* risks (AI↔world, platform↔regulators, contracts↔state law), not pure code risks, consistent with the README's observation that the existential risks are legal-shaped. The highest pure-engineering exposures are the consistency family (TR-04/08/16, 12 each) — which is why ARC-08 §8.4 and ADR-0015 exist as first-class machinery.
