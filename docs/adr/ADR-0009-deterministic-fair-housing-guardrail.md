# ADR-0009 — Deterministic Fair-Housing Guardrail Outside the Model

**Status:** Accepted — hard constraint, never relaxed · 2026-06-11

## Context
Fair Housing Act compliance is existential (R-05, exposure 15; README §4.2 warning). Scope directs: "deterministic fair-housing filter sitting outside the model; the model never gets final say on protected-class logic" (§6.2). Prompt instructions alone are not a compliance control.

## Decision
Three independent, deterministic layers — none of which is an LLM:

1. **Schema allowlist (input firewall).** Matching and negotiation operate only on an explicitly allowlisted feature set (price, dates, lease length, verified income/credit within legal bounds, amenities, stated style descriptors, location radius). Protected attributes and enumerated proxies are not representable in the feature schema — they cannot be filtered out late because they never enter.
2. **Output validation.** Every ranked match must be reproducible from the allowlisted vector + scoring version; every agent term-sheet delta is schema- and bounds-checked. Unexplainable variance → rejected + flagged.
3. **Continuous paired-profile auditing.** CI-blocking bias harness (Q3-1) + production sampling; reports retained for regulators.

Free-text from users (intake, listings) is feature-extracted **through classifiers into allowlisted descriptors only**; raw text never feeds scoring. Data that reveals protected class (e.g., familial status implied during intake) is retained for compliance records but excluded from the feature store. Adding any feature to the allowlist requires compliance review (four-eyes, Q3-3).

## Consequences
- (+) Architecturally demonstrable compliance: the system *cannot* steer on what it cannot see; evidence trail for regulators.
- (−) Matching expressiveness deliberately reduced; some "smart" inferences (README's "subconscious wants", MoSCoW C) are constrained to allowlisted style descriptors with shown reasoning.
- (−) Allowlist governance is ongoing work (proxy drift: e.g., school-district filters correlating with protected classes must be policy-reviewed).

## Alternatives
Prompt-level instructions / model self-policing — rejected: not auditable, not deterministic, not a legal defense.
