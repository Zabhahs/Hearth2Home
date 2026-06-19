# Module: Leasing

## Responsibility (ARC-05 §5.2 — Lease & Document Service)

State-templated lease document generation using attorney-reviewed templates parameterised by the compliance ruleset for the jurisdiction in effect at signing time. Manages the e-sign ceremony (via an e-sign vendor), document versioning, and WORM archival of executed documents to S3 Object Lock. Every executed document is hashed and the hash is recorded in the audit log; the WORM copy in S3 is the primary evidentiary artefact (PLN-01 §4). Handles offer / counter-offer structured forms (the term-sheet rails that agent negotiation will plug into in a later increment).

## MVP Scope (PLN-01 Week 3)

One launch-state lease template (counsel sign-off is a hard gate before any client uses it). Ruleset-parameterised merge fields (ADR-0013). E-sign ceremony via vendor API with webhook confirmation. Executed PDF hashed and archived to WORM S3 bucket. Hash written to audit log. Plain-language AI lease explainer flagged "assistive, not legal advice." Multi-state templates and RON deferred.
