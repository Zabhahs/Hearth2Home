# Module: Identity & Access

## Responsibility (ARC-05 §5.2)

Owns authentication (passwordless / OIDC), role-based access control (RBAC), organisation and property-owner entities, and — in later increments — agency relationships that allow a property manager to operate on behalf of a unit owner. It is the authoritative source for "who is this user and what are they allowed to do."

## MVP Scope (PLN-01 Week 1)

Landlord onboarding: create organisation, attach properties and units, invite team members. Auth via Supabase Auth (magic-link / OAuth). Basic RBAC roles: `owner`, `manager`, `tenant`. Processor-connect onboarding flow (Stripe Connect-class) doubles as payout-KYC identity step. Property-manager agency relationships and ERC-4337 smart-account provisioning are deferred to a later increment.
