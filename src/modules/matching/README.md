# Module: Matching

## Responsibility (ARC-05 §5.2 — Matching Service)

Tenant-side unit matching: hard filters on lawful, non-protected criteria followed by a weighted allowlisted scoring pass. Every match result includes a per-feature explanation object ("why this property surfaced") so that recommendations are transparent and auditable (ADR-0010; R-03 mitigation). The scoring function reads only from an allowlisted feature store; protected classes and their proxies are structurally absent from the input schema, enforced by the Compliance Guardrail Service. Semantic / pgvector component and the AI preference-intake pipeline are later additions that sit behind the same guardrail.

## MVP Scope (PLN-01 Week 4)

Rule-based hard-filter + weighted-score implementation (no ML inference at MVP — ships rule-based, layers ML later per ADR-0010). Allowlisted feature schema (price range, bedrooms, bathrooms, pet policy, lease-term preference). Explanation object per match result. Guardrail-service call to validate inputs and outputs. Conversational AI intake (tenant application form with plain-form fallback) to populate the preference record. pgvector semantic component and aesthetic-preference ingestion (vision model) deferred to Increment 1c.
