# ARC-09 — Architecture Decisions (ADR Index)

| | |
|---|---|
| **Doc ID** | ARC-09 · arc42 §9 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

ADRs live in [docs/adr/](../adr/). Format: Nygard (Status / Context / Decision / Consequences / Alternatives). Statuses: **Accepted** (binding), **Proposed** (recommended, awaiting founder/counsel sign-off), **Founder-directed** (recorded business decision honored by architecture).

| ADR | Title | Status | Revisit trigger |
|---|---|---|---|
| [ADR-0001](../adr/ADR-0001-rental-first-phasing.md) | Rental automation first; home-buying second | Founder-directed | Phase-1 gate |
| [ADR-0002](../adr/ADR-0002-county-source-of-truth.md) | County recorder stays legal source of truth; chain holds deed-references | Founder-directed (resolves R-01) | Path-1 legislative milestones |
| [ADR-0003](../adr/ADR-0003-modular-monolith-nestjs.md) | Modular monolith on NestJS/TypeScript | Proposed | Team > ~12 eng or hot-path scale limits |
| [ADR-0004](../adr/ADR-0004-postgres-system-of-record.md) | PostgreSQL system of record; minimal trust kernel on-chain | Accepted | — |
| [ADR-0005](../adr/ADR-0005-base-l2.md) | Base L2 (mainnet) / Base Sepolia (dev) | Proposed | Sequencer-decentralization roadmap; fee regimes |
| [ADR-0006](../adr/ADR-0006-no-token-regulated-stablecoin.md) | No native token; regulated third-party stablecoins, multi-issuer | Accepted (GENIUS-aligned) | CLARITY Act passage |
| [ADR-0007](../adr/ADR-0007-custody-variant-b-default.md) | Custody Variant B (licensed partner) default; Variant A gated on counsel | Proposed — **counsel decision required** | Per-state MT licensing analysis |
| [ADR-0008](../adr/ADR-0008-chainlink-oracle-substrate.md) | Chainlink Functions + CCIP oracle substrate | Accepted (per scope) | Vendor concentration review at Phase-2 |
| [ADR-0009](../adr/ADR-0009-deterministic-fair-housing-guardrail.md) | Deterministic fair-housing guardrail outside models; allowlisted feature schema | Accepted (hard constraint) | Never relaxed |
| [ADR-0010](../adr/ADR-0010-rule-based-matching-first.md) | Rule-based matching v1; semantic layer later | Accepted (R-03 mitigation) | Phase-1 gate |
| [ADR-0011](../adr/ADR-0011-bid-privacy-commit-reveal.md) | Bid/listing privacy: salted commit-reveal on public L2 (over permissioned chain) | Proposed — **founder decision (Open Item 3, R-02)** | Phase-1 gate |
| [ADR-0012](../adr/ADR-0012-hash-chained-audit-log.md) | Hash-chained audit log + daily on-chain Merkle anchoring | Accepted | — |
| [ADR-0013](../adr/ADR-0013-compliance-as-configuration.md) | Versioned per-state rulesets with attorney-approval workflow | Accepted (R-12) | — |
| [ADR-0014](../adr/ADR-0014-immutable-vault-upgradeable-periphery.md) | Immutable EscrowVault; upgradeable periphery behind timelock+multisig | Proposed (refines scope §6.2) | Post-audit review |
| [ADR-0015](../adr/ADR-0015-saga-outbox-pipeline.md) | Saga orchestration + transactional outbox; workflow-engine evaluation | Proposed | Increment 0 spike |
| [ADR-0016](../adr/ADR-0016-dual-agent-isolation.md) | Dual-agent information barrier ("designated agency" analogue) | Accepted | — |
| [ADR-0017](../adr/ADR-0017-rent-collection-session-keys.md) | Rent collection via scoped session keys/allowances (no open-ended pulls) | Accepted (corrects scope §4.4 mechanism) | — |
| [ADR-0018](../adr/ADR-0018-fiat-fallback-rail.md) | ACH fiat rail ships at launch alongside stablecoin | Proposed | Launch-state payment-law review |
| [ADR-0019](../adr/ADR-0019-mvp-30-day-concessions.md) | 30-day MVP scope & stack concessions (time-boxed; see [PLN-01](../planning/mvp-30-day.md)) | Proposed | Extraction trigger: 1b/1c build start or team ≥ 5 eng |

**Decisions deliberately NOT made here** (require founder/counsel, tracked in [ANL-04](../analysis/validation-report.md)): launch-state pair, KYC + stablecoin + custody vendor selection, monetization numbers, workflow-engine product choice, Variant A/B custody final call, commit-reveal vs. permissioned chain final call.
