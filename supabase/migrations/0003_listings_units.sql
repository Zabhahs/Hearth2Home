-- =============================================================================
-- 0003_listings_units.sql
-- Properties, units, and listings (the inventory side of the platform).
--
-- MVP scope (PLN-01 §3): landlord onboarding, property/unit models,
-- listings with hosted page, AI listing-copy (stored here, lint enforced
-- at application layer per ADR-0009).
--
-- References: DSN-01 §2 (ORGANIZATION, UNIT, LISTING),
--             ADR-0011 (listing commitments — post-MVP, noted below),
--             ADR-0013 (ruleset versioning stamps on listings).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- properties
-- A real-estate parcel. One organization may own many properties.
-- The county public record is authoritative for title (ADR-0002);
-- we store what is operationally necessary.
-- ---------------------------------------------------------------------------
CREATE TABLE public.properties (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id          UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,

  -- Street address components stored separately for structured lookups.
  address_line1   TEXT        NOT NULL,
  address_line2   TEXT,
  city            TEXT        NOT NULL,
  state_code      TEXT        NOT NULL,   -- ISO 3166-2 subdivision (e.g. 'WA').
  postal_code     TEXT        NOT NULL,
  country_code    TEXT        NOT NULL    DEFAULT 'US',

  -- County assessor parcel identifier for cross-reference (ADR-0002).
  apn             TEXT,

  -- Property type drives allowed unit configurations.
  property_type   TEXT        NOT NULL
                  CHECK (property_type IN (
                    'single_family', 'multi_family', 'condo', 'townhouse', 'other'
                  )),

  is_deleted      BOOLEAN     NOT NULL    DEFAULT FALSE
);

COMMENT ON TABLE  public.properties IS
  'Real-estate parcel owned by an organization. '
  'County public record is authoritative for title (ADR-0002). DSN-01 §2.';
COMMENT ON COLUMN public.properties.apn IS
  'Assessor Parcel Number from county records (ADR-0002). '
  'Used for cross-reference; platform record is not authoritative for title.';

-- ---------------------------------------------------------------------------
-- units
-- A leasable unit within a property (e.g., Apt 3B, or the whole SFH).
-- ---------------------------------------------------------------------------
CREATE TABLE public.units (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id          UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  property_id     UUID        NOT NULL REFERENCES public.properties(id)    ON DELETE RESTRICT,

  -- Unit designator (e.g., '3B', 'Main Floor', '1').
  unit_number     TEXT        NOT NULL,

  -- Physical characteristics used in matching (allowlisted per ADR-0009).
  bedrooms        SMALLINT    NOT NULL CHECK (bedrooms >= 0),
  bathrooms       NUMERIC(3,1) NOT NULL CHECK (bathrooms >= 0),
  square_feet     INTEGER     CHECK (square_feet > 0),

  -- Amenities stored as a JSONB array of allowlisted descriptor strings.
  -- Free-text amenities are feature-extracted at the app layer before storage.
  amenities       JSONB       NOT NULL    DEFAULT '[]',

  -- Lifecycle; 'vacant' units may be listed.
  status          TEXT        NOT NULL    DEFAULT 'vacant'
                  CHECK (status IN ('vacant', 'occupied', 'maintenance', 'inactive')),

  is_deleted      BOOLEAN     NOT NULL    DEFAULT FALSE,

  CONSTRAINT units_unique_in_property UNIQUE (property_id, unit_number)
);

COMMENT ON TABLE  public.units IS
  'Leasable unit within a property. Physical characteristics are '
  'allowlisted matching inputs (ADR-0009). DSN-01 §2 UNIT entity.';
COMMENT ON COLUMN public.units.amenities IS
  'JSONB array of allowlisted amenity descriptor strings (ADR-0009). '
  'Free-text is feature-extracted before storage — raw text never feeds scoring.';

-- ---------------------------------------------------------------------------
-- listings
-- An active or historical market listing for a unit.
-- One unit may have multiple listings over time (sequential, not concurrent).
-- ---------------------------------------------------------------------------
CREATE TABLE public.listings (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id          UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  unit_id         UUID        NOT NULL REFERENCES public.units(id)         ON DELETE RESTRICT,

  -- Listing status lifecycle.
  status          TEXT        NOT NULL    DEFAULT 'draft'
                  CHECK (status IN (
                    'draft', 'pending_review', 'active', 'under_application',
                    'leased', 'withdrawn', 'expired'
                  )),

  -- Financial terms (authoritative in the listing; copied to term_sheet at offer time).
  monthly_rent_cents     BIGINT  NOT NULL CHECK (monthly_rent_cents > 0),
  deposit_amount_cents   BIGINT  CHECK (deposit_amount_cents >= 0),
  currency_code          TEXT    NOT NULL DEFAULT 'USD',

  -- Lease term preferences.
  lease_term_months      SMALLINT NOT NULL CHECK (lease_term_months > 0),
  available_date         DATE    NOT NULL,

  -- AI-generated listing copy; deterministic HUD word-list lint enforced at
  -- application layer before this field is written (PLN-01 §3, ADR-0009).
  listing_copy_title     TEXT,
  listing_copy_body      TEXT,

  -- Photos stored as ordered JSONB array of {url, caption, order_index}.
  -- URLs point to application storage; not WORM at listing stage.
  photos                 JSONB   NOT NULL DEFAULT '[]',

  -- Ruleset version stamped at listing creation (ADR-0013).
  -- Ensures late-fee math, disclosures, etc. are reproducible.
  ruleset_version_id     UUID,   -- FK added after 0007 table exists.

  -- Date range this listing was/is visible publicly.
  published_at           TIMESTAMPTZ,
  closed_at              TIMESTAMPTZ,

  is_deleted             BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE  public.listings IS
  'Market listing for a leasable unit. AI copy is lint-checked at app layer '
  '(HUD word list, ADR-0009). Ruleset version stamped for reproducibility. DSN-01 §2.';
COMMENT ON COLUMN public.listings.listing_copy_body IS
  'AI-generated listing description. Deterministic fair-housing ad-lint '
  '(HUD word list) enforced before write; raw AI output is not stored here.';
COMMENT ON COLUMN public.listings.ruleset_version_id IS
  'Version of jurisdiction_ruleset active when this listing was created. '
  'Ensures all downstream computations (late fees, disclosures) are reproducible '
  'under the rules in effect at listing time (ADR-0013).';

-- TODO (post-MVP, DSN-01 §2 / ADR-0011): LISTING_COMMITMENT table.
-- Salted hash + on-chain tx ref for bid-privacy commit-reveal.
-- Deferred pending founder decision O-4 (Phase-1 gate).
-- See ADR-0011 and DSN-01 §2 (LISTING vs LISTING_COMMITMENT note).

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_properties_org_id     ON public.properties(org_id);
CREATE INDEX idx_units_org_id          ON public.units(org_id);
CREATE INDEX idx_units_property_id     ON public.units(property_id);
CREATE INDEX idx_listings_org_id       ON public.listings(org_id);
CREATE INDEX idx_listings_unit_id      ON public.listings(unit_id);
CREATE INDEX idx_listings_status       ON public.listings(status);
CREATE INDEX idx_listings_available    ON public.listings(available_date) WHERE status = 'active';
