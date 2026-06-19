# ARC-08 — Crosscutting Concepts

| | |
|---|---|
| **Doc ID** | ARC-08 · arc42 §8 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

## 8.1 Identity Model

One **verified legal identity** (KYC) anchors: platform account (authn), role assignments (RBAC), organization/agency links, smart account address, and signature identities (e-sign + EIP-712 where used). The binding chain — *legal person ↔ KYC verdict ↔ account ↔ wallet ↔ signed documents* — is itself recorded in the audit log, because lease enforceability depends on attributing on-chain actions to legal persons (ESIGN/UETA).

Agency relationships are first-class: a property manager (Marcus persona) acts *for* an owner with scoped permissions; every action records both the actor and the principal.

## 8.2 Authorization

- RBAC with org scoping: Owner, Manager, Staff, Tenant, Broker, Compliance Ops, Partner Ops, Admin.
- **Four-eyes rule** for: ruleset activation, connector go-live, escrow overrides, governance proposals.
- Broker approvals are workflow states (blocking), not permissions — a regulated action cannot exist in an approved state without a broker case ID attached.

## 8.3 Audit Logging (DR-4 — the spine)

- Every state-changing action and every AI decision emits an audit event: `{seq, ts, actor, principal, action, entity, payloadHash, prevHash}` — hash-chained per stream, sequence-gapless.
- Daily Merkle root over all streams anchored to the MilestoneRegistry (or a dedicated anchor contract) — tamper-evidence without data on-chain (ADR-0012).
- Documents: executed versions to S3 Object Lock (WORM) with retention class; payloads in the log are hashes + pointers, not blobs.
- AI events additionally capture: model ID + version, prompt template version, full input/output refs, guardrail verdicts (Explainability Logger). LLMs are nondeterministic — **reproducibility comes from logging, not replay** (TR-06).
- Verification API: third party can check chain integrity and anchor inclusion for any time range.

## 8.4 On-Chain / Off-Chain Consistency

The hardest recurring problem in this system. Rules:

1. **PostgreSQL is the system of record for business state; the chain is the system of record for fund custody and attested events.** Neither mirrors the other blindly — the indexer projects chain → PG; the Integration plane is the only chain writer.
2. **Transactional outbox** everywhere a DB change implies an external action (chain tx, webhook, email): state change + outbox row commit atomically; dispatcher delivers with retries; consumers idempotent (idempotency keys on all money-adjacent operations).
3. **Finality policy:** an on-chain event is `OBSERVED` at soft confirmation, `CONFIRMED` for business purposes only after the configured policy (L2 finality / L1 posting depth by amount tier). Fund-release sagas advance on `CONFIRMED` only.
4. **Reorg handling:** indexer tracks block hashes; on reorg, affected projections roll back and sagas re-evaluate; any saga that already advanced on a now-orphaned event opens an incident (should be impossible by rule 3 — monitored anyway).
5. **Reconciliation:** scheduled jobs compare internal ledger ↔ indexer projections ↔ custody-provider balances ↔ ACH partner reports. Discrepancies page a human. No auto-healing of money state.

## 8.5 Privacy & Data Protection

- **Nothing personally identifying on-chain. Ever.** On-chain artifacts: escrow balances and flows (pseudonymous addresses), terms *hashes*, milestone *evidence hashes*, salted listing/bid commitments (ADR-0011).
- **Crypto-shredding:** every on-chain commitment uses a per-record salt stored off-chain; deleting the salt severs linkability, satisfying deletion requests despite chain immutability (TR-12).
- Amount visibility: escrow/rent amounts are visible on-chain at MVP (accepted, disclosed in ToS); revisit amount-bucketing or privacy tech at Phase-2 gate alongside R-02.
- PII minimization: KYC artifacts stay vendor-side where the vendor supports it; we store verdicts + references. FCRA reports handled per CRA terms with mandated retention/destruction.
- Data classification: `public / internal / confidential / regulated (KYC, FCRA, financial)` — classification drives storage, encryption, access logging, and retention class (DSN-01 §5).

## 8.6 Error Handling & Escalation Taxonomy

| Class | Examples | Policy |
|---|---|---|
| Retryable-technical | RPC timeout, vendor 5xx | Exponential backoff w/ jitter; saga stays in step |
| Business-rejection | Guardrail veto, ruleset violation | Returned to initiator with machine-readable reason; logged |
| Disagreement | Oracle sources conflict, reconciliation mismatch | **Escalate to human, never auto-resolve** (README §3A.3 fail-safe) |
| Legal-hold | Court order, issuer freeze | Freeze affected entities; case management; counsel notified |
| Security | Attestation failure, signature mismatch, anomaly | Circuit-break the surface; incident response |

## 8.7 Observability (distinct from audit)

OpenTelemetry traces/metrics/logs (PII-redacted at source — audit log carries the sensitive trail under stricter access, observability stays scrubbed). Chain-side: contract event alerting, **invariant monitors** (vault solvency: on-chain balance ≥ Σ recorded obligations), oracle SLA dashboards, governance-action alerts. Paging policy tied to the error taxonomy above. Status page for landlords (rent-run health).

## 8.8 Testing Strategy (architecture-level)

| Layer | Approach |
|---|---|
| Contracts | Unit + property-based/invariant fuzzing (Foundry/Echidna-class): vault solvency, no-arbitrary-destination, pause-never-strands-funds; static analysis (Slither-class); fork tests against Base; **independent audit before mainnet funds** (C-T3) + bug bounty (R-06) |
| Fair housing | **Paired-profile harness as a CI gate**: synthetic applicant pairs differing only in protected attributes (and known proxies) must produce statistically indistinguishable match scores and agent behavior; disparity thresholds block release (DSN-04 §7) |
| AI agents | Golden-set intake/negotiation sims; adversarial suite (prompt-injection corpus, jailbreak attempts via listing text); model/prompt version pinning per release |
| Sagas | Chaos-style tests: kill/duplicate/delay every external call; assert idempotency and compensation |
| Connectors | Certification suite in sandbox (schema conformance, latency, failure behavior) before signing (DSN-03) |
| Compliance | Ruleset regression packs per state (deposit math, late fees, notices) reviewed with counsel |

## 8.9 SDLC & Supply Chain

Trunk-based development; CI gates = lint/type/tests + bias harness + contract static analysis + secret scanning; IaC (Terraform) for all environments; signed, versioned connector artifacts with provenance (SLSA-lean); dependency pinning + review for anything touching funds; SOC 2 Type II trajectory from Increment 1a (enterprise PM customers will ask).

## 8.10 Accessibility & UX Conventions

WCAG 2.2 AA target for all user surfaces (housing platform — ADA exposure is real); plain-language summaries adjacent to every legal document; explainability surfaces ("why this match", "why this term") are product features, not debug tools.
