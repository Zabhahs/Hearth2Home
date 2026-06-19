-- =============================================================================
-- 0002_core_identity.sql
-- Core identity entities: organizations, parties (users), and memberships.
--
-- MVP scope (PLN-01 §3): self-managing landlords only; property managers
-- (agency_relationship) deferred until counsel posture memo (G-05).
--
-- References: DSN-01 §2 (PARTY, ORGANIZATION, ORG_MEMBERSHIP),
--             ARC-08 §8.1 (identity model), ARC-08 §8.2 (RBAC).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- organizations
-- A legal entity (landlord company, future PM company) that owns properties
-- and under whose umbrella all tenancy data is scoped (org_id RLS key).
-- ---------------------------------------------------------------------------
CREATE TABLE public.organizations (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),

  -- Human-readable display name; not unique to allow DBA corrections.
  name            TEXT        NOT NULL,

  -- Slug used in URLs and log messages; unique across the platform.
  slug            TEXT        NOT NULL UNIQUE,

  -- Processor-connect reference: PayFac partner (Stripe Connect-class)
  -- stores payout KYC on their side; we keep the linked account reference
  -- only (PLN-01 §2 — platform never holds funds).
  processor_account_ref  TEXT,

  -- Lifecycle status; landlords start as 'active' after onboarding.
  -- 'suspended' is set by compliance ops; 'offboarded' is terminal.
  status          TEXT        NOT NULL    DEFAULT 'active'
                  CHECK (status IN ('pending_onboarding', 'active', 'suspended', 'offboarded')),

  -- The single launch state at MVP (ADR-0013); multi-state support grows
  -- from the ruleset engine without schema changes.
  primary_jurisdiction  TEXT,

  CONSTRAINT organizations_name_not_empty CHECK (char_length(trim(name)) > 0),
  CONSTRAINT organizations_slug_format    CHECK (slug ~ '^[a-z0-9-]+$')
);

COMMENT ON TABLE  public.organizations IS
  'Legal entity that owns properties and anchors RLS tenancy. DSN-01 §2 / ARC-08 §8.1.';
COMMENT ON COLUMN public.organizations.processor_account_ref IS
  'PayFac partner linked-account identifier (Stripe Connect-class). '
  'Payout KYC is the processor''s regulated function at MVP (PLN-01 §2).';
COMMENT ON COLUMN public.organizations.primary_jurisdiction IS
  'ISO 3166-2 state code for the launch jurisdiction (e.g. US-WA). '
  'Determines which ruleset is applied by default.';

-- ---------------------------------------------------------------------------
-- parties
-- A verified legal person or entity (landlord, tenant, future property
-- manager, compliance ops staff). Bound 1:1 to a Supabase auth.users row
-- via auth_uid. PII is minimized here — full identity artifacts live at
-- the KYC vendor (DSN-01 §2, ARC-08 §8.1).
-- ---------------------------------------------------------------------------
CREATE TABLE public.parties (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),

  -- Links to Supabase auth.users; enforced at application layer.
  -- NULL only during invite flows before the invitee creates an auth account.
  auth_uid        UUID        UNIQUE,

  -- citext gives case-insensitive lookups for free.
  email           CITEXT      NOT NULL UNIQUE,

  -- Display name only — NOT the legal name (KYC vendors hold that).
  display_name    TEXT        NOT NULL,

  -- FCRA / KYC metadata: we store only the verdict and vendor reference;
  -- raw identity artifacts remain with the vendor (ARC-08 §8.5, DSN-01 §5).
  -- 'unverified' at MVP for landlords whose processor performs payout KYC.
  kyc_status      TEXT        NOT NULL    DEFAULT 'unverified'
                  CHECK (kyc_status IN ('unverified', 'pending', 'verified', 'failed', 'expired')),
  kyc_vendor_ref  TEXT,           -- Opaque vendor case/session ID.
  kyc_verified_at TIMESTAMPTZ,    -- When the verdict was received.

  -- Soft-delete / GDPR erasure: PII fields are NULLed; auth_uid detached;
  -- row is retained for audit chain back-references.
  is_deleted      BOOLEAN     NOT NULL    DEFAULT FALSE,

  CONSTRAINT parties_display_name_not_empty CHECK (char_length(trim(display_name)) > 0)
);

COMMENT ON TABLE  public.parties IS
  'Verified legal person/entity. Bound to Supabase auth.users via auth_uid. '
  'PII is minimized; identity artifacts stay at KYC vendor. DSN-01 §2 / ARC-08 §8.1.';
COMMENT ON COLUMN public.parties.kyc_status IS
  'Verdict from KYC vendor. At MVP, landlords use processor payout KYC; '
  'dedicated KYC vendor integration returns with stablecoin rails (PLN-01 §3).';
COMMENT ON COLUMN public.parties.kyc_vendor_ref IS
  'Opaque KYC vendor case/session reference. Raw artifacts remain vendor-side '
  '(data minimization, DSN-01 §5 class: regulated-identity).';
COMMENT ON COLUMN public.parties.is_deleted IS
  'Soft-delete flag for PII erasure requests. '
  'PII columns are NULLed; row retained for audit chain back-references.';

-- ---------------------------------------------------------------------------
-- org_memberships
-- Maps parties to organizations with a named role.
-- Tenants are parties but NOT org members — they are scoped by transaction
-- participation (DSN-01 §4).
-- ---------------------------------------------------------------------------
CREATE TABLE public.org_memberships (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id          UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  party_id        UUID        NOT NULL REFERENCES public.parties(id)       ON DELETE CASCADE,

  -- ARC-08 §8.2 RBAC roles (MVP roles: owner, staff; others deferred).
  -- 'owner'  — can manage all org settings, properties, and members.
  -- 'staff'  — can manage listings, applications, leases under the org.
  -- 'broker' — deferred: requires agency counsel memo (G-05).
  role            TEXT        NOT NULL
                  CHECK (role IN ('owner', 'staff', 'broker', 'compliance_ops', 'admin')),

  -- Effective date range; NULL upper bound = currently active.
  effective_from  TIMESTAMPTZ NOT NULL    DEFAULT now(),
  effective_until TIMESTAMPTZ,

  -- Membership lifecycle; 'active' is the normal operating state.
  status          TEXT        NOT NULL    DEFAULT 'active'
                  CHECK (status IN ('active', 'suspended', 'revoked')),

  -- Invited by which party (audit trail for membership provisioning).
  invited_by_party_id UUID    REFERENCES public.parties(id),

  CONSTRAINT org_memberships_unique_active
    UNIQUE NULLS NOT DISTINCT (org_id, party_id, effective_until)
);

COMMENT ON TABLE  public.org_memberships IS
  'RBAC membership: party ↔ organization role mapping. '
  'Tenants are not org members; they are scoped by lease participation. DSN-01 §4.';
COMMENT ON COLUMN public.org_memberships.role IS
  'RBAC role per ARC-08 §8.2. MVP roles: owner, staff. '
  'broker / compliance_ops / admin present for schema completeness; '
  'product surfaces for them are post-MVP.';

-- TODO (post-MVP, DSN-01 §2): AGENCY_RELATIONSHIP table.
-- Property manager orgs acting for owner orgs with scoped permissions,
-- actor + principal recording, effective dates. Requires counsel posture
-- memo (G-05) before Marcus persona is enabled.

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_org_memberships_org_id    ON public.org_memberships(org_id);
CREATE INDEX idx_org_memberships_party_id  ON public.org_memberships(party_id);
CREATE INDEX idx_parties_auth_uid          ON public.parties(auth_uid);
CREATE INDEX idx_parties_email             ON public.parties(email);
