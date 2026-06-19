# Module: Listings & Units

## Responsibility (ARC-05 §5.2)

System of record for mutable property data: photos, price, description, amenities, and availability. This data is explicitly off-chain; the module exposes a public read API for the tenant-facing listing browse and a privileged write API for landlords. AI listing-copy generation (with deterministic HUD fair-housing ad-lint) is the AI-plane capability surfaced through this module.

## MVP Scope (PLN-01 Week 2)

Create/edit/publish unit listings with photo upload to S3-compatible storage. Hosted public listing page per unit. AI listing-copy assistant (Claude, behind the guardrail proxy) with deterministic fair-housing lint on the generated copy (ADR-0009 word-list allowlist). Listing detail lives in Postgres; no on-chain commitment at MVP (founder decision, PLN-01 §3 "Out").
