# ADR-0013 — Compliance as Configuration: Versioned Per-State Rulesets

**Status:** Accepted (implements README R-12) · 2026-06-11

## Context
Per-state regulatory fragmentation (R-12, exposure 12); scope directs "build compliance as config, not code" (§11.3 step 4). Rules differ on: deposit caps and return deadlines, late-fee caps and grace periods, notice periods, rent control, required disclosures, RON/e-recording availability, deposit-rail legality, screening restrictions (e.g., portable screening reports, fair-chance ordinances).

## Decision
A **Ruleset** is a versioned, effective-dated parameter pack per jurisdiction (state, with county/city overlays where needed), flowing through a workflow: *draft → attorney review → approved → active*. Every generated document and automated computation (late fee, deposit math, notices) stamps the ruleset version used. Rules are **parameters and decision tables, not code**; a rule that can't be parameterized triggers a design review before any state-specific code is written.

## Consequences
- (+) New state ≈ ruleset + template pack + counsel sign-off (Q5-1: zero code for parameterized rules).
- (+) Reproducibility: a 2026 lease is explainable under the ruleset that generated it, even after rules change.
- (−) Ruleset schema design is significant up-front work; jurisdiction overlays (city rent control) add depth.
- (−) Attorney review becomes a release dependency per state — intentional (C-O3).

## Alternatives
Per-state code branches — rejected: unmaintainable past ~3 states; audit nightmare.
