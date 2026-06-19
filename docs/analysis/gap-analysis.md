# ANL-02 — Gap Analysis (Scope Document v1.0)

| | |
|---|---|
| **Doc ID** | ANL-02 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

Gaps found in the README during architecture derivation. Severity: **Blocker** (must resolve before the affected increment ships) / **Major** (material risk or rework if deferred) / **Minor**. "Disposition" = where this documentation set addresses it, or who must.

## 1. Legal & Compliance Gaps

| ID | Gap | Severity | Disposition |
|---|---|---|---|
| **G-01** | **Tenant screening is FCRA-regulated and the scope never mentions it.** "Verified income/credit" (Module B) means consumer reports → permissible purpose, consent, and adverse-action notice duties; state overlays (portable screening reports, fair-chance ordinances) add more. | **Blocker** (Increment 1a) | Designed: DSN-06 §6 adverse-action workflow; screening CRA added to context (ARC-03); ruleset overlays (ADR-0013). Counsel validates per launch state. |
| **G-02** | **State security-deposit statutes may prohibit the designed deposit vehicle.** Many states require deposits in segregated/in-state/trust (sometimes interest-bearing) accounts; a stablecoin vault may not qualify. The scope treats deposit escrow as purely technical. | **Blocker** (1b for stablecoin deposits) | Designed: deposit-rail legality is a ruleset parameter (C-L7); partner trust-account rail as alternative. **Counsel question per state — could materially shrink the on-chain deposit feature.** |
| **G-03** | **Custody licensing unanalyzed.** Custodial wallets (scope mandate) make someone a custodian of customer funds; the scope never says who, or addresses money-transmitter exposure for the platform itself. | **Blocker** (1b) | Designed: ADR-0007 two variants, partner-custody default; TR-03. Counsel decision gates Variant A. |
| **G-04** | Jurisdictions restricting electronic-only rent payment; tenants without stablecoin access. No fiat path anywhere in scope. | Major | Designed: ADR-0018 ACH rail at launch; Rail Router. |
| **G-05** | Leasing activity itself requires a license in some states (scope assumes broker-of-record is a sale-side concern). | Major | Flagged: DSN-06 §1 row 1; per-state activity gating; launch-state legal map (counsel). |
| **G-08** | Tax information reporting (platform processing rent may trigger 1099-class duties for platform or landlords). | Major | Flagged: DSN-06 §1; ledger exports designed (DSN-01); tax counsel determination. |
| **G-09** | GENIUS Act timing: scope leans on it, but the regime phases in (~18 months post-enactment / post-rules). "GENIUS-compliant stablecoin" is partly forward-looking in mid-2026. | Minor (narrative), Major (if issuer choice assumes it) | Captured: C-L3; ADR-0006 interim posture (existing regulated issuers); quarterly regulatory watch (ARC-11 §11.3). |
| **G-13** | E-sign is named but the **identity-binding chain** (KYC ↔ signature ↔ wallet ↔ legal person) needed for enforceability is not. | Major | Designed: ARC-08 §8.1; evidence packages (DSN-06 §5). |

## 2. Technical Architecture Gaps (in the scope's own stack section)

| ID | Gap | Severity | Disposition |
|---|---|---|---|
| **G-06** | **No on-chain/off-chain consistency story**: nothing on finality, reorgs, idempotency, partial failure, reconciliation — the hardest recurring problem in this class of system. | **Blocker** (1b) | Designed: ARC-08 §8.4 (outbox, finality policy, indexer, reconciliation); ADR-0015 sagas. |
| **G-07** | **"Scheduled stablecoin pulls" is not how ERC-20 works.** Pull-payments need allowances/session keys or custodian-initiated pushes — each with different safety and licensing profiles. | Major (design correction) | Corrected: ADR-0017 scoped session grants; DSN-02 §3. |
| **G-10** | **Prompt injection / adversarial content is absent from the risk register** despite LLM agents negotiating with money at stake — arguably the top *technical* threat to the differentiator. | Major | Designed: DSN-04 §3 containment stack; TR-01 (exposure 16); injection corpus gate (DSN-04 §7). |
| **G-11** | **Dual-agent conflict of interest / information leakage** unaddressed: same platform runs both fiduciary-flavored agents. | Major | Designed: ADR-0016 information barrier + disclosure posture; per-party vaults. |
| **G-14** | Upgradeable-proxy-everything (scope §6.2) concentrates custody risk in the upgrade key for fund-holding contracts. | Major | Corrected: ADR-0014 immutable vault / upgradeable periphery. |
| **G-15** | L2 sequencer centralization & chain-outage handling unaddressed while legal deadlines (rent due, deposit return) ride on chain events. | Major | Designed: Q6-1 deadline independence; DEFERRED_CHAIN states; ADR-0018. |
| **G-16** | No observability/SRE, incident response, or DR/BCP anywhere in scope. | Major | Designed: ARC-07 §7.4, ARC-08 §8.7; runbook inventory (DSN-05 §5). |

## 3. Product Scope Gaps

| ID | Gap | Severity | Disposition |
|---|---|---|---|
| **G-12** | **No maintenance-request module**, yet the competitor table credits PM SaaS with it and Phase-1 buyers (Priya/Marcus) currently get it from the tools this product replaces. Adoption risk: landlords won't drop a PM tool that handles maintenance for one that doesn't. | Major | Recommended: integrate (oracle-in) a maintenance/work-order partner in Increment 1c, or a minimal native ticket flow; **founder product decision** — flagged in ANL-04. |
| **G-17** | Tenant-side value proposition is thin in Phase 1 (tenant pays nothing, but also gets little beyond the application flow; rent reporting to credit bureaus, renter profiles, deposit-interest transparency are cheap wins). | Minor | Product backlog suggestion; no architectural change needed. |
| **G-18** | Lease renewals/amendments (rent increase re-grants, term extensions) implied by "auto rent-increase" but no renewal flow is scoped. | Major | Designed into saga set (renewal = amendment saga re-issuing grants, ADR-0017); needs product spec. |

## 4. Summary

- 3 Blockers (G-01, G-02/G-03 pair, G-06) — all have designed mitigations in this set; G-01/02/03 additionally require counsel sign-off per launch state before the affected increments.
- The two scope **corrections** (G-07 pull-payments, G-14 upgradeability) change implementation approach but preserve every scoped capability.
- No gap invalidates the core thesis. The architecture absorbs all of them without structural change — which is the point of finding them now.
