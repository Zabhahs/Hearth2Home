# Module: Compliance

## Responsibility (ARC-05 §5.2 — Compliance Engine)

Per-state ruleset evaluation for every document and payment decision: deposit caps, return deadlines, late-fee caps, notice periods, required disclosures, RON / e-recording availability, and deposit-rail legality. Rulesets are versioned and follow a draft → attorney-review → approved → active workflow; every generated document stamps the ruleset version it was evaluated against. Also owns the deterministic fair-housing Guardrail Service — the feature-allowlist enforcement and output-validation filter shared by the Matching module and the AI plane. This is a hard wall (C-L4): the guardrail is never optional and cannot be bypassed by model output.

## MVP Scope (PLN-01 Week 1–4, continuous)

One launch-state ruleset (single state, counsel-reviewed before any client data flows through it). Late-fee and notice-period parameters. Deterministic fair-housing ad-lint for listing copy (HUD word list; ADR-0009 allowlist). Guardrail service stub for the Matching module. Broker-review-queue placeholder for future human-in-the-loop actions. Multi-state rulesets, disclosure scheduler, and case-management UI deferred to later increments.
