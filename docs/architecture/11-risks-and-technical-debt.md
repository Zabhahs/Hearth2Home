# ARC-11 — Risks and Technical Debt

| | |
|---|---|
| **Doc ID** | ARC-11 · arc42 §11 |
| **Version** | 0.1.0-draft · 2026-06-11 |
| **Status** | Draft for founder review |

## 11.1 Risk Registers

- **Business/strategic risks** R-01…R-13: owned by the scope document (README §7); every row's mitigation is mapped to architectural controls in [ANL-01](../analysis/requirements-traceability-matrix.md) §3.
- **Technical risks** TR-01…TR-16: new register maintained at [ANL-03](../analysis/technical-risk-register.md). Top exposures: TR-01 prompt injection (16), TR-03 custody/licensing misstep (16), TR-02 deposit-statute conflict (15), TR-04 on/off-chain divergence (12).
- **Scope gaps** G-01…G-14: [ANL-02](../analysis/gap-analysis.md).

## 11.2 Deliberately Accepted Technical Debt (with exit criteria)

| # | Debt | Why accepted | Exit criterion |
|---|---|---|---|
| D-1 | Modular monolith (no service extraction) | Team size; iteration speed | Extract Integration plane first if connector volume or isolation needs demand it |
| D-2 | Single-region deployment, cold-standby DR | Cost; MVP risk profile | Re-evaluate at 1,000 managed units |
| D-3 | On-chain escrow amounts publicly visible | Privacy tech adds complexity; disclosed in ToS | Phase-2 gate, with R-02 revisit |
| D-4 | Queue-based saga implementation if Increment-0 spike rejects a workflow engine | Avoid premature infrastructure | Re-evaluate when closing pipeline (R7) is built — Phase 2 likely needs durable workflows |
| D-5 | Geo-walkthrough at medium assurance (attestation + dual confirmation, no hardware GNSS verification) | Spoof-resistance vs. cost; never gates large funds alone | Incident-driven; Phase-2 closing walkthroughs re-assessed |
| D-6 | Manual partner vetting workflow (tooling-light) | Few partners at launch | Automate when partner count > ~20 (per §3A.2 "open later") |
| D-7 | RLS single-DB multi-tenancy | Simplicity | Re-evaluate if enterprise PM orgs (>1k units) require isolation guarantees |

## 11.3 Standing Revisit Calendar

| When | What |
|---|---|
| Phase-1 gate | Founder decisions R-02 (ADR-0011), R-03 (ADR-0010); debt D-3, D-4 |
| Pre-mainnet | ADR-0014 final form post-audit; key ceremony; bug bounty launch |
| Per new state | Ruleset + deposit-rail legality + payment-law check (ADR-0018) |
| Quarterly | TR register re-score; vendor concentration (ADR-0008); GENIUS/CLARITY regulatory watch (C-L3) |
