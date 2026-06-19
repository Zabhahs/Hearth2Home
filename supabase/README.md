# Supabase — Database Migrations

This directory contains the PostgreSQL migration files for the Hearth2Home MVP database.
The schema is DSN-01 from day one; no rewrite is needed when non-MVP features are built
(PLN-01 §4 / ADR-0019).

---

## Migration ordering

| File | Purpose |
|---|---|
| `0001_extensions.sql` | Enable pgcrypto, pgvector, citext; create `match_features` and `audit` schemas |
| `0002_core_identity.sql` | `organizations`, `parties`, `org_memberships` — identity + RLS tenancy anchor |
| `0003_listings_units.sql` | `properties`, `units`, `listings` — inventory side |
| `0004_applications_screening.sql` | `intake_profiles`, `match_candidates`, `screening_reports`; `match_features.*` tables |
| `0005_leasing_documents.sql` | `negotiations`, `term_sheet_versions`, `leases`, `documents`, `condition_reports` |
| `0006_payments_ledger.sql` | `payment_obligations`, `payment_events`, `deposit_records` |
| `0007_compliance_rulesets.sql` | `jurisdiction_rulesets`; back-fills `ruleset_version_id` FK constraints on prior tables |
| `0008_audit_log.sql` | `audit.audit_record`, `audit.daily_anchor`; `append_audit_event()` security-definer function |
| `0009_rls_policies.sql` | RLS enable + all policies; REVOKE UPDATE/DELETE on audit; `set_updated_at()` trigger |

Files must be applied **in numeric order**. Each file depends on the tables created by its predecessors.

---

## How to apply

### Local development

```bash
supabase start          # start the local Supabase stack
supabase db push        # apply all pending migrations from supabase/migrations/
```

### Staging / production

```bash
supabase db push --db-url "$DATABASE_URL"
```

Or using the Supabase CLI migration commands:

```bash
supabase migration up
```

### Manual apply (psql)

```bash
for f in supabase/migrations/00*.sql; do
  psql "$DATABASE_URL" -f "$f"
done
```

---

## Schema conventions

### UUID primary keys

All tables use `gen_random_uuid()` (from pgcrypto) as the default PK value.

### Timestamps

Every table carries `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` and
`updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`. The `set_updated_at()` trigger
(installed in `0009_rls_policies.sql`) maintains `updated_at` automatically.
The `audit.audit_record` and `documents` tables do **not** have `updated_at`
(they are append-only / immutable by design).

### Soft deletes

Tables with user-facing records (`parties`, `properties`, `units`, `listings`) carry
`is_deleted BOOLEAN NOT NULL DEFAULT FALSE`. Queries should filter `WHERE NOT is_deleted`
unless specifically querying deleted records.

### RLS tenancy

- **Org-scoped tables** (properties, units, listings, leases, etc.) carry `org_id UUID NOT NULL`
  as the tenancy key. RLS policies check `is_org_member(org_id)` via the security-definer helper.
- **Party-scoped tables** (intake_profiles, screening_reports) use `is_party_self(party_id)`
  for self-access plus an org-member policy for the counterparty.
- **Public read** (active listings): the `listings_select_public` policy allows `anon` role
  to SELECT rows where `status = 'active'` — this powers the public listing search (PLN-01 §3).

### match_features schema

All tables in the `match_features` schema are populated by the Guardrail Service running as
`service_role`. No `anon` or `authenticated` client policies exist — default deny applies.
New columns require four-eyes compliance review before addition (ADR-0009).

### audit schema

The `audit.audit_record` table is append-only by enforcement:
- `REVOKE UPDATE, DELETE, INSERT` on `audit.audit_record` from `anon` and `authenticated`.
- All writes go through `audit.append_audit_event()` (SECURITY DEFINER).
- The function serializes inserts per-stream with `pg_advisory_xact_lock`.
- The application layer (Edge Function / server API) computes `prev_hash` and `payload_hash`
  before calling the function; `recorded_at` is set inside the function and cannot be overridden.

### Data classification

Regulated tables carry a `COMMENT` referencing DSN-01 §5 classification:

| Classification | Tables |
|---|---|
| `regulated-identity` | `screening_reports` |
| `regulated-financial` | `payment_obligations`, `payment_events`, `deposit_records` |
| `legal-document` | `documents` |
| `audit` | `audit.audit_record`, `audit.daily_anchor` |

Retention schedules and legal-hold logic are enforced at the application/ops layer;
the schema provides `retain_until`, `is_legal_hold`, and `destruction_due_at` columns
as the data model anchors.

---

## Entities intentionally deferred (post-MVP)

The following DSN-01 entities are **not** created in these migrations. Each file that
touches a related area has a `-- TODO (post-MVP ...)` comment with the DSN section and
re-entry trigger.

| Entity | DSN reference | Re-entry trigger |
|---|---|---|
| `AGENCY_RELATIONSHIP` | DSN-01 §2 | Counsel posture memo G-05 (property manager / Marcus persona) |
| `SMART_ACCOUNT` | DSN-01 §2 | Custody counsel decision O-3 + contract audit + custody partner live → Increment 1b |
| `KYC_VERIFICATION` (full table) | DSN-01 §2 | Dedicated KYC vendor integration returns with stablecoin rails; MVP uses processor payout KYC |
| `ESCROW_AGREEMENT` | DSN-01 §2 | Per-state deposit-rail legality O-5 + custody partner onboarding |
| `DEPOSIT_DEDUCTION` (FK rows) | DSN-01 §2 | Alongside ESCROW_AGREEMENT; replaces `deposit_records.deductions` JSONB |
| `LISTING_COMMITMENT` | DSN-01 §2 / ADR-0011 | Founder decision O-4 (Phase-1 gate; bid-privacy commit-reveal) |
| `MILESTONE_EVENT` / `ATTESTATION` | DSN-01 §2 | Increment 1b/1c (on-chain settlement saga) |
| `APPROVAL` | DSN-01 §2 | Broker/PM surface (G-05 counsel memo); Q1-2 four-eyes gate |
| `BROKER_CASE` | DSN-06 §2 | Same as APPROVAL |
| `DISPUTE` | DSN-01 §2 | Increment 1b (tied to on-chain escrow dispute flow) |
| `PARTNER` / `CONNECTOR_VERSION` | DSN-01 §2 / DSN-03 | Partner connector platform (post-MVP) |
| On-chain settlement tables | ARC-06 / DSN-02 | Contract audit C-T3 passed + O-3/O-5 resolved |

---

## Local Supabase seed

A `seed.sql` file for local development (sample org, landlord party, one property, one
active listing, one jurisdiction ruleset for US-WA) is not included here — create it
under `supabase/seed.sql` following the same conventions as these migrations.
