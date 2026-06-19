# HomeChain (Hearth2Home) — Technical Documentation Index

| | |
|---|---|
| **Doc ID** | IDX-00 |
| **Version** | 0.1.0-draft |
| **Date** | 2026-06-11 |
| **Status** | Draft for founder review |
| **Source scope** | [README.md](../README.md) — Product Scope v1.0 (June 2026) |

## Purpose

This documentation set translates the product scope ([README.md](../README.md)) into a complete, validated technical architecture for the HomeChain platform. It is a **design-phase artifact set**: no implementation code exists or is prescribed here. Diagrams are expressed in Mermaid (renders natively on GitHub); contract and API designs are specified descriptively, not as code.

## Standards & Conventions

| Concern | Standard used |
|---|---|
| Architecture description | **arc42** template (12 sections), aligned with ISO/IEC/IEEE 42010 |
| Diagram model | **C4 model** (Context, Container, Component) rendered in Mermaid |
| Decision records | **ADR** (Michael Nygard format), one decision per file, immutable once Accepted |
| Threat modeling | **STRIDE** per trust boundary |
| Requirement priority | **MoSCoW** (carried over from the scope document) |
| Risk scoring | Likelihood × Impact (1–5 each), consistent with README §7 |
| Doc versioning | SemVer per document; all docs start at 0.1.0-draft |

**Source-of-truth hierarchy:** README (business scope) → arc42 set (architecture) → design deep-dives (subsystem specs) → ADRs (govern all decisions; a design doc may not contradict an Accepted ADR).

## Document Map

### Architecture (arc42)

| Doc | File | Contents |
|---|---|---|
| ARC-01 | [01-introduction-and-goals.md](architecture/01-introduction-and-goals.md) | Purpose, stakeholders, ranked quality goals |
| ARC-02 | [02-constraints.md](architecture/02-constraints.md) | Legal, technical, organizational constraints |
| ARC-03 | [03-context-and-scope.md](architecture/03-context-and-scope.md) | C4 system context, external systems, scope boundary |
| ARC-04 | [04-solution-strategy.md](architecture/04-solution-strategy.md) | Core strategies and rationale; delivery increments |
| ARC-05 | [05-building-block-view.md](architecture/05-building-block-view.md) | C4 containers & components; mapping to README modules A–F |
| ARC-06 | [06-runtime-view.md](architecture/06-runtime-view.md) | Key scenarios incl. failure paths (8 sequences) |
| ARC-07 | [07-deployment-view.md](architecture/07-deployment-view.md) | Environments, cloud reference, key management, DR/BCP |
| ARC-08 | [08-crosscutting-concepts.md](architecture/08-crosscutting-concepts.md) | Identity, consistency, audit, privacy, testing, observability |
| ARC-09 | [09-architecture-decisions.md](architecture/09-architecture-decisions.md) | ADR index with statuses |
| ARC-10 | [10-quality-requirements.md](architecture/10-quality-requirements.md) | Quality tree + measurable scenarios |
| ARC-11 | [11-risks-and-technical-debt.md](architecture/11-risks-and-technical-debt.md) | Risk summary; deliberately accepted debt |
| ARC-12 | [12-glossary.md](architecture/12-glossary.md) | Domain & technical glossary |

### Architecture Decision Records

[docs/adr/](adr/) — ADR-0001 … ADR-0018. Index in [ARC-09](architecture/09-architecture-decisions.md).

### Design Deep-Dives

| Doc | File | Contents |
|---|---|---|
| DSN-01 | [data-model.md](design/data-model.md) | ERD, entities, multi-tenancy, retention classes |
| DSN-02 | [smart-contracts.md](design/smart-contracts.md) | Contract modules, state machines, invariants, governance |
| DSN-03 | [oracle-integration-layer.md](design/oracle-integration-layer.md) | Connector lifecycle, canonical events, attestation policy |
| DSN-04 | [ai-agents-and-matching.md](design/ai-agents-and-matching.md) | Agent topology, guardrails, negotiation protocol, matching |
| DSN-05 | [security-threat-model.md](design/security-threat-model.md) | Assets, trust boundaries, STRIDE, abuse cases, controls |
| DSN-06 | [compliance-and-audit.md](design/compliance-and-audit.md) | Broker workflow, state rules engine, KYC/AML, FCRA, records |

### Planning

| Doc | File | Contents |
|---|---|---|
| PLN-01 | [mvp-30-day.md](planning/mvp-30-day.md) | 30-day MVP definition: scope, build plan, legal track, risks (governed by ADR-0019) |
| PLN-02 | [sprint-map.md](planning/sprint-map.md) | Autonomous-window sprint map (Jun 15–22): task graph, day plan, model routing, DoD |

### Operations

| Doc | File | Contents |
|---|---|---|
| OPS-01 | [autonomous-operation.md](ops/autonomous-operation.md) | The 24/7 self-managed build system: tick loop, token governor, sub-agent orchestration, escalation, safety, start/stop |
| OPS-02 | [deployment-setup.md](ops/deployment-setup.md) | Go-live: Vercel Git integration, scheduled routine, the master switch, daily founder loop, go-live checklist |

### Legal

| Doc | File | Contents |
|---|---|---|
| LGL-01 | [counsel-engagement-brief.md](legal/counsel-engagement-brief.md) | Day-1 counsel brief: WA posture, prioritized question list (Topics A–I), deliverables, the lease-template hard gate |

### Sprint Execution (live working state)

| File | Role |
|---|---|
| [sprint/](../sprint/) | The fleet's durable brain: [sprint-state.json](../sprint/sprint-state.json), [BACKLOG.md](../sprint/BACKLOG.md), [INBOX.md](../sprint/INBOX.md), [PROPOSED.md](../sprint/PROPOSED.md), token-ledger |
| [CLAUDE.md](../CLAUDE.md) | Per-session guardrails auto-loaded every tick |
| `.claude/` | [settings.json](../.claude/settings.json) (permission allowlist), commands `/sprint-tick` + `/sprint-digest`, `build-lane` agent |

### Analysis & Validation

| Doc | File | Contents |
|---|---|---|
| ANL-01 | [requirements-traceability-matrix.md](analysis/requirements-traceability-matrix.md) | Every scoped feature → component → scenario → risk control |
| ANL-02 | [gap-analysis.md](analysis/gap-analysis.md) | Gaps found in the scope document, severity, disposition |
| ANL-03 | [technical-risk-register.md](analysis/technical-risk-register.md) | TR-01…TR-16 technical risks (complements README R-01…R-13) |
| ANL-04 | [validation-report.md](analysis/validation-report.md) | Coverage/consistency/feasibility validation results |

## Change Process

1. Architecture changes are proposed as a new ADR (or supersession of an existing one).
2. arc42 and design docs are updated in the same change set; the traceability matrix (ANL-01) is re-checked.
3. Documents carry their own version and date; this index is bumped on any structural change.
