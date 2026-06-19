-- =============================================================================
-- 0004_applications_screening.sql
-- Tenant application intake, screening reports, match candidates, and
-- the match_features allowlisted feature store.
--
-- MVP scope (PLN-01 §3): conversational AI intake (allowlisted fields),
-- vendor-led FCRA screening, adverse-action trail, rule-based matching.
-- No scoring of protected-class attributes (ADR-0009 hard constraint).
--
-- Data classification: screening_reports → regulated-identity (DSN-01 §5).
-- Retention: FCRA / CRA-mandated; raw report data minimized (DSN-01 §2).
--
-- References: DSN-01 §2 (INTAKE_PROFILE, SCREENING_REPORT, MATCH_CANDIDATE),
--             DSN-01 §3 (match_features schema), ADR-0009, DSN-06 §6.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- intake_profiles
-- A tenant's self-declared rental profile. Allowlisted fields only per
-- ADR-0009: price, dates, lease length, stated income/credit within legal
-- bounds, amenity preferences, location radius, style descriptors.
-- The conversational AI intake extracts into these fields; raw conversation
-- is not stored here (it goes to the audit log as a payload hash + ref).
-- ---------------------------------------------------------------------------
CREATE TABLE public.intake_profiles (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  -- The applicant party.
  party_id            UUID        NOT NULL REFERENCES public.parties(id) ON DELETE RESTRICT,

  -- Lifecycle; 'active' profiles are eligible for matching.
  status              TEXT        NOT NULL    DEFAULT 'draft'
                      CHECK (status IN ('draft', 'active', 'withdrawn', 'expired')),

  -- Allowlisted financial/term preferences.
  max_monthly_rent_cents  BIGINT      CHECK (max_monthly_rent_cents > 0),
  desired_move_in_date    DATE,
  desired_lease_term_months  SMALLINT  CHECK (desired_lease_term_months > 0),

  -- Desired unit characteristics (mirrors units table allowlist).
  min_bedrooms        SMALLINT    CHECK (min_bedrooms >= 0),
  min_bathrooms       NUMERIC(3,1) CHECK (min_bathrooms >= 0),
  desired_amenities   JSONB       NOT NULL    DEFAULT '[]',

  -- Location: stored as a centroid + radius (km). No neighborhood names
  -- that could correlate with protected class (ADR-0009 proxy discipline).
  desired_lat         DOUBLE PRECISION,
  desired_lng         DOUBLE PRECISION,
  desired_radius_km   NUMERIC(6,2) CHECK (desired_radius_km > 0),

  -- Self-declared income/credit within HUD/state legal limits.
  -- These fields are lawful inputs; income-to-rent ratio math is enforced
  -- via ruleset parameters, not hardcoded (ADR-0013).
  gross_monthly_income_cents  BIGINT  CHECK (gross_monthly_income_cents >= 0),
  stated_credit_band  TEXT        CHECK (stated_credit_band IN (
                        'excellent', 'good', 'fair', 'limited', 'unknown'
                      )),

  -- Free-form style preferences are NOT stored here; they are feature-extracted
  -- into match_features.unit_style_profiles by the Guardrail Service (ADR-0009).
  -- The consent record for that extraction is stored below.
  style_extraction_consented_at TIMESTAMPTZ,

  -- Version of the intake form / AI prompt used to gather this profile.
  -- Enables explanation of "why this profile" across prompt-version changes.
  intake_schema_version  TEXT
);

COMMENT ON TABLE  public.intake_profiles IS
  'Tenant rental profile with allowlisted fields only (ADR-0009). '
  'Style descriptors extracted into match_features schema by Guardrail Service. '
  'DSN-01 §2 INTAKE_PROFILE entity.';
COMMENT ON COLUMN public.intake_profiles.desired_lat IS
  'Location centroid latitude. Radius-based only; no neighborhood identifiers '
  'that could proxy for protected class (ADR-0009).';
COMMENT ON COLUMN public.intake_profiles.stated_credit_band IS
  'Broad credit band self-declared by applicant. '
  'Specific score thresholds are ruleset parameters (ADR-0013), not schema constants.';

-- ---------------------------------------------------------------------------
-- match_candidates
-- Persisted match score record: intake_profile ↔ listing pair.
-- Stores score, feature-contribution vector, and scoring version for
-- explainability ("why this match", DR-9 / ADR-0009).
-- Scoring features come from match_features schema only (ADR-0009).
-- ---------------------------------------------------------------------------
CREATE TABLE public.match_candidates (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  intake_profile_id   UUID        NOT NULL REFERENCES public.intake_profiles(id) ON DELETE CASCADE,
  listing_id          UUID        NOT NULL REFERENCES public.listings(id)         ON DELETE CASCADE,
  org_id              UUID        NOT NULL REFERENCES public.organizations(id)    ON DELETE RESTRICT,

  -- Score in [0, 1]; deterministic given same feature vector + scoring version.
  score               NUMERIC(5,4) NOT NULL CHECK (score BETWEEN 0 AND 1),

  -- Which scoring version produced this result (ADR-0010 rule-based, Increment 1c ML).
  scoring_version     TEXT        NOT NULL,

  -- Feature contribution vector as JSONB: {feature_name: contribution_value}.
  -- Populated from the allowlisted feature set only — the explainability record.
  -- DSN-01 §2 MATCH_CANDIDATE: "feature-contribution vector + scoring version".
  feature_contributions JSONB     NOT NULL    DEFAULT '{}',

  -- Status in the candidate lifecycle.
  status              TEXT        NOT NULL    DEFAULT 'scored'
                      CHECK (status IN ('scored', 'presented', 'applied', 'withdrawn', 'expired')),

  -- When this candidate was presented to the tenant / landlord.
  presented_at        TIMESTAMPTZ,

  CONSTRAINT match_candidates_unique_pair UNIQUE (intake_profile_id, listing_id)
);

COMMENT ON TABLE  public.match_candidates IS
  'Persisted match score + explainability record for intake_profile ↔ listing pair. '
  'score is deterministic from feature_contributions + scoring_version (ADR-0009/ADR-0010). '
  'All features in feature_contributions must be in the match_features schema. DSN-01 §2.';
COMMENT ON COLUMN public.match_candidates.feature_contributions IS
  'Per-feature contribution map from allowlisted features only (ADR-0009). '
  'Enables "why this match" explanation to tenant (PLN-01 §3).';
COMMENT ON COLUMN public.match_candidates.scoring_version IS
  'Scoring model/rule version identifier. '
  'Required for reproducibility: score is re-derivable from this version + feature vector.';

-- ---------------------------------------------------------------------------
-- match_features.intake_feature_profiles
-- Allowlisted extracted features for an intake_profile.
-- ONLY columns lawful under ADR-0009 may appear here.
-- Protected-class attributes and proxies are NEVER stored in this schema.
-- ---------------------------------------------------------------------------
CREATE TABLE match_features.intake_feature_profiles (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),

  -- Back-reference to the intake profile (public schema).
  intake_profile_id       UUID        NOT NULL UNIQUE
                          REFERENCES public.intake_profiles(id) ON DELETE CASCADE,

  -- Extracted allowlisted style descriptor embedding (pgvector, Increment 1c).
  -- NULL until style extraction is consented and run.
  -- Dimension 1536 matches common embedding model output; adjust if provider changes.
  style_embedding         VECTOR(1536),

  -- Extracted preference scores for specific amenity categories (allowlisted).
  -- Stored as JSONB: {amenity_category: weight_0_to_1}
  amenity_weights         JSONB       NOT NULL    DEFAULT '{}',

  -- Normalized price sensitivity score (0=insensitive, 1=maximum).
  price_sensitivity       NUMERIC(4,3) CHECK (price_sensitivity BETWEEN 0 AND 1),

  -- Lease term flexibility score (0=inflexible, 1=fully flexible).
  term_flexibility        NUMERIC(4,3) CHECK (term_flexibility BETWEEN 0 AND 1),

  -- Version of the feature extractor that produced this row.
  extractor_version       TEXT        NOT NULL
);

COMMENT ON TABLE  match_features.intake_feature_profiles IS
  'Allowlisted extracted matching features for a tenant intake profile. '
  'ONLY lawful, non-protected-class attributes. ADR-0009 / DSN-01 §3. '
  'Do NOT add protected-class attributes or proxies to this table.';
COMMENT ON COLUMN match_features.intake_feature_profiles.style_embedding IS
  'pgvector embedding of allowlisted style descriptors (Increment 1c / DSN-01 §3). '
  'Consent timestamp on intake_profiles.style_extraction_consented_at must be set '
  'before this column is populated.';

-- ---------------------------------------------------------------------------
-- match_features.unit_feature_profiles
-- Allowlisted extracted features for a listing/unit combination.
-- ---------------------------------------------------------------------------
CREATE TABLE match_features.unit_feature_profiles (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),

  listing_id              UUID        NOT NULL UNIQUE
                          REFERENCES public.listings(id) ON DELETE CASCADE,

  -- Style embedding of the unit (amenities, listing copy descriptors).
  style_embedding         VECTOR(1536),

  -- Normalized amenity presence scores.
  amenity_scores          JSONB       NOT NULL    DEFAULT '{}',

  -- Price tier relative to market (0=below, 0.5=at, 1=above).
  price_tier              NUMERIC(4,3) CHECK (price_tier BETWEEN 0 AND 1),

  extractor_version       TEXT        NOT NULL
);

COMMENT ON TABLE  match_features.unit_feature_profiles IS
  'Allowlisted extracted matching features for a listing/unit. '
  'ONLY lawful, non-protected-class attributes. ADR-0009 / DSN-01 §3.';

-- ---------------------------------------------------------------------------
-- screening_reports
-- FCRA artifact per DSN-01 §2 and DSN-06 §6.
-- Data classification: REGULATED-IDENTITY (DSN-01 §5).
-- Retention: CRA-mandated; raw report data minimized — we store verdict,
-- vendor reference, permissible-purpose record, and adverse-action trail.
-- Raw report content stays with the CRA vendor.
--
-- Vendor-led, tenant-initiated model (PLN-01 §2 G-01): the CRA runs
-- consent and report delivery; we supply adverse-action workflow.
-- ---------------------------------------------------------------------------
CREATE TABLE public.screening_reports (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id              UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,

  -- The subject of the report (the applicant party).
  subject_party_id    UUID        NOT NULL REFERENCES public.parties(id)       ON DELETE RESTRICT,

  -- The listing this report was ordered in connection with.
  listing_id          UUID        NOT NULL REFERENCES public.listings(id)      ON DELETE RESTRICT,

  -- CRA vendor name (SmartMove-class) and their internal report reference.
  -- Raw report content is NOT stored here; it remains with the vendor.
  cra_vendor          TEXT        NOT NULL,
  cra_report_ref      TEXT        NOT NULL,

  -- Permissible-purpose record: what purpose was stated, by whom, when.
  -- Required by FCRA §604. Stored as JSONB for extensibility.
  permissible_purpose JSONB       NOT NULL,

  -- Consent record reference. Actual consent artifact stored at CRA or
  -- in the documents table (WORM) after e-sign.
  consent_document_id UUID,       -- FK added after 0005 documents table exists.

  -- Summary verdict only — no raw scores or full data points.
  -- Raw scoring data remains vendor-side per FCRA data minimization.
  verdict             TEXT        NOT NULL
                      CHECK (verdict IN ('approved', 'conditionally_approved', 'declined', 'pending', 'error')),

  -- Structured adverse-action trail (DSN-06 §6):
  -- If a decline/conditional approval is based on this report, adverse-action
  -- notice must be sent. This JSONB records: reasons (coded per FCRA §615),
  -- notice template version, delivery status, and timestamp.
  adverse_action_trail JSONB,

  -- Date the report expires (CRA-specified).
  report_expires_at   TIMESTAMPTZ,

  -- Date destruction is due (FCRA retention schedule).
  destruction_due_at  TIMESTAMPTZ,

  -- Legal hold prevents destruction; set by compliance ops.
  is_legal_hold       BOOLEAN     NOT NULL DEFAULT FALSE
);

-- DATA CLASSIFICATION: REGULATED-IDENTITY (DSN-01 §5)
-- Retention: CRA-mandated per FCRA. Raw report content not stored here;
-- only verdict, vendor ref, permissible purpose, and adverse-action trail.
-- Destruction schedule tracked in destruction_due_at. Legal hold via is_legal_hold.
COMMENT ON TABLE  public.screening_reports IS
  'FCRA artifact: verdict + adverse-action trail only. '
  'DATA CLASS: regulated-identity (DSN-01 §5). '
  'Raw report content stays with CRA vendor (data minimization). '
  'Tenant-initiated, vendor-led model (PLN-01 §2 / DSN-06 §6).';
COMMENT ON COLUMN public.screening_reports.permissible_purpose IS
  'FCRA §604 permissible-purpose record: purpose stated, requestor, timestamp.';
COMMENT ON COLUMN public.screening_reports.adverse_action_trail IS
  'FCRA §615 adverse-action notice trail: coded reason factors, template version, '
  'delivery channel, delivery status, timestamp. '
  'Populated whenever verdict is declined or conditionally_approved.';
COMMENT ON COLUMN public.screening_reports.destruction_due_at IS
  'CRA-mandated destruction date. '
  'Destruction job checks is_legal_hold before purging.';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_intake_profiles_party_id    ON public.intake_profiles(party_id);
CREATE INDEX idx_intake_profiles_status      ON public.intake_profiles(status);
CREATE INDEX idx_match_candidates_listing    ON public.match_candidates(listing_id);
CREATE INDEX idx_match_candidates_intake     ON public.match_candidates(intake_profile_id);
CREATE INDEX idx_match_candidates_status     ON public.match_candidates(status);
CREATE INDEX idx_screening_reports_org       ON public.screening_reports(org_id);
CREATE INDEX idx_screening_reports_subject   ON public.screening_reports(subject_party_id);
CREATE INDEX idx_screening_reports_listing   ON public.screening_reports(listing_id);
