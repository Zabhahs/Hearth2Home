-- =============================================================================
-- 0007_compliance_rulesets.sql
-- Versioned per-jurisdiction compliance rulesets (ADR-0013).
--
-- MVP scope (PLN-01 §3): one launch state, attorney-reviewed template,
-- ruleset-parameterized. Every generated document and automated computation
-- stamps the ruleset version used (ADR-0013).
--
-- Also: back-fill FK constraints on ruleset_version_id columns added in
-- prior migrations with deferred references.
--
-- References: DSN-01 §2 (JURISDICTION_RULESET), ADR-0013, DSN-06 §3.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- jurisdiction_rulesets
-- A versioned, effective-dated parameter pack per jurisdiction.
-- Workflow: draft → attorney_review → approved → active.
-- Each state has exactly one 'active' ruleset at a given time.
-- County/city overlays are separate rows with overlay_for_ruleset_id set.
-- ---------------------------------------------------------------------------
CREATE TABLE public.jurisdiction_rulesets (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),

  -- Jurisdiction identifiers (ISO 3166-2 for state; FIPS or custom for county/city).
  jurisdiction_type       TEXT        NOT NULL
                          CHECK (jurisdiction_type IN ('state', 'county', 'city')),
  jurisdiction_code       TEXT        NOT NULL,   -- e.g. 'US-WA', 'WA-KING', 'WA-SEATTLE'.
  jurisdiction_name       TEXT        NOT NULL,   -- Human-readable name.

  -- If this ruleset is a county/city overlay, references the parent state ruleset.
  overlay_for_ruleset_id  UUID        REFERENCES public.jurisdiction_rulesets(id),

  -- Semver-style version identifier.
  ruleset_version         TEXT        NOT NULL,

  -- Effective date range; NULL effective_until = currently active.
  effective_from          DATE        NOT NULL,
  effective_until         DATE,

  -- Workflow status per ADR-0013.
  workflow_status         TEXT        NOT NULL DEFAULT 'draft'
                          CHECK (workflow_status IN (
                            'draft', 'attorney_review', 'approved', 'active', 'superseded', 'withdrawn'
                          )),

  -- Attorney sign-off record (ADR-0013 requirement: attorney review before activation).
  attorney_sign_off_at    TIMESTAMPTZ,
  attorney_party_id       UUID        REFERENCES public.parties(id),
  attorney_sign_off_notes TEXT,

  -- The parameter pack: deposit, fee, notice, screening, and disclosure rules.
  -- Structured JSONB; schema documented in docs/design/compliance-and-audit.md §3.
  --
  -- Deposit parameters:
  --   deposit_cap_multiplier: max deposit as multiple of monthly rent (e.g. 2.0 = 2x rent cap).
  --   deposit_return_days: statutory return deadline in days after move-out.
  --   deposit_interest_required: boolean.
  --   deposit_segregation_required: boolean.
  --
  -- Fee parameters:
  --   late_fee_grace_period_days: number of days grace before late fee applies.
  --   late_fee_type: 'flat' | 'percentage'.
  --   late_fee_cap_cents: maximum late fee in cents (if flat).
  --   late_fee_cap_pct: maximum late fee as % of rent (if percentage).
  --
  -- Notice parameters (days required):
  --   notice_rent_increase_days, notice_entry_days, notice_termination_days,
  --   notice_nonpayment_days.
  --
  -- Screening parameters:
  --   portable_screening_accepted: boolean.
  --   fair_chance_restricted: boolean (fair-chance ordinance).
  --   first_in_time_required: boolean (Seattle-style first-come ordering).
  --
  -- Disclosure requirements: JSONB array of required disclosure identifiers.
  --
  -- Execution requirements: RON availability, witness count, notary requirement.

  parameters              JSONB       NOT NULL DEFAULT '{}',

  -- Change log: why this version was created / what changed.
  change_summary          TEXT,

  CONSTRAINT jrulesets_unique_active_version
    UNIQUE NULLS NOT DISTINCT (jurisdiction_code, ruleset_version, effective_until)
);

COMMENT ON TABLE  public.jurisdiction_rulesets IS
  'Versioned, attorney-reviewed jurisdiction parameter pack (ADR-0013). '
  'All automated computations (late fees, deposit math, notices) stamp '
  'and reference this version for reproducibility. DSN-01 §2.';
COMMENT ON COLUMN public.jurisdiction_rulesets.parameters IS
  'Structured parameter pack: deposit (cap, return deadline, interest, segregation), '
  'fees (late-fee grace, cap), notices (required days per event type), '
  'screening restrictions (fair-chance, first-in-time), disclosure requirements, '
  'execution requirements (RON, witness). DSN-06 §3 / ADR-0013.';
COMMENT ON COLUMN public.jurisdiction_rulesets.attorney_sign_off_at IS
  'Timestamp of attorney sign-off. Required before workflow_status can be set to '
  'approved or active (ADR-0013 hard gate — no client-facing lease without counsel review).';
COMMENT ON COLUMN public.jurisdiction_rulesets.overlay_for_ruleset_id IS
  'For county/city overlays (e.g. Seattle first-in-time rule). '
  'References the parent state ruleset this overlay supplements.';

-- ---------------------------------------------------------------------------
-- Back-fill FK constraints: ruleset_version_id on all prior tables.
-- These columns were created without FKs because this table did not
-- exist yet at migration time.
-- ---------------------------------------------------------------------------

ALTER TABLE public.listings
  ADD CONSTRAINT fk_listings_ruleset_version
  FOREIGN KEY (ruleset_version_id) REFERENCES public.jurisdiction_rulesets(id);

ALTER TABLE public.negotiations
  ADD CONSTRAINT fk_negotiations_ruleset_version
  FOREIGN KEY (ruleset_version_id) REFERENCES public.jurisdiction_rulesets(id);

ALTER TABLE public.leases
  ADD CONSTRAINT fk_leases_ruleset_version
  FOREIGN KEY (ruleset_version_id) REFERENCES public.jurisdiction_rulesets(id);

ALTER TABLE public.documents
  ADD CONSTRAINT fk_documents_ruleset_version
  FOREIGN KEY (ruleset_version_id) REFERENCES public.jurisdiction_rulesets(id);

ALTER TABLE public.payment_obligations
  ADD CONSTRAINT fk_payment_obligations_ruleset_version
  FOREIGN KEY (ruleset_version_id) REFERENCES public.jurisdiction_rulesets(id);

ALTER TABLE public.deposit_records
  ADD CONSTRAINT fk_deposit_records_ruleset_version
  FOREIGN KEY (ruleset_version_id) REFERENCES public.jurisdiction_rulesets(id);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_jurisdiction_rulesets_code_status
  ON public.jurisdiction_rulesets(jurisdiction_code, workflow_status);

CREATE INDEX idx_jurisdiction_rulesets_active
  ON public.jurisdiction_rulesets(jurisdiction_code, effective_from)
  WHERE workflow_status = 'active';
