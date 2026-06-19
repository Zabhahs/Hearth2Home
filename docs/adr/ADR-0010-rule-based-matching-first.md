# ADR-0010 — Rule-Based Matching First; Semantic Layer Later

**Status:** Accepted (implements README R-03 mitigation) · 2026-06-11

## Context
Founder decision keeps AI matching central to the MVP; the risk register's own mitigation (R-03, exposure 12) says: ship rule-based matching first, layer ML behind the explainability log.

## Decision
Matching v1 = hard filters (budget, dates, beds, pets, radius) + weighted additive scoring over the allowlisted features, with a per-feature contribution breakdown shown to the user. The semantic/aesthetic component (pgvector embeddings of consented style inputs) is added later as **one bounded score term** (capped weight), logged like every other feature.

## Consequences
- (+) Explainable from day one (Q3-2); de-risks the build path while keeping the AI-differentiator narrative intact (agents + intake are still LLM-driven).
- (+) The aesthetic layer arrives as an increment (1c), not a foundation.
- (−) Early match quality leans on intake quality; acceptable for MVP volumes.

## Alternatives
Embedding-led matching from day one — rejected: explainability and bias-audit burden front-loaded onto the riskiest component (R-03, R-05).

**Revisit:** Phase-1 gate, with match-quality metrics in hand.
