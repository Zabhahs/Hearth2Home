-- =============================================================================
-- 0005_leasing_documents.sql
-- Structured offer rails, leases, and document archive.
--
-- MVP scope (PLN-01 §3): structured offer/counter forms (human-driven),
-- lease generation + e-sign, WORM document archive (hash + pointer).
-- AI agents plug into term_sheet_versions later without schema changes
-- (PLN-01 §7 / DSN-04 §2 — schema designed for agent attachment).
--
-- Data classification: documents → legal-document (DSN-01 §5).
-- Retention: ≥ 7 years, ruleset-configurable (C-L12).
--
-- References: DSN-01 §2 (NEGOTIATION, TERM_SHEET_VERSION, APPROVAL, LEASE,
--             DOCUMENT), ADR-0013 (ruleset versioning), DSN-06 §5.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- negotiations
-- A negotiation instance tied to a match candidate.
-- At MVP: human-driven offer/counter cycle.
-- Post-MVP: dual-agent AI negotiation attaches here (DSN-04 §2).
-- ---------------------------------------------------------------------------
CREATE TABLE public.negotiations (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id              UUID        NOT NULL REFERENCES public.organizations(id)    ON DELETE RESTRICT,
  match_candidate_id  UUID        NOT NULL REFERENCES public.match_candidates(id) ON DELETE RESTRICT,
  listing_id          UUID        NOT NULL REFERENCES public.listings(id)         ON DELETE RESTRICT,

  -- Both parties in the negotiation.
  landlord_party_id   UUID        NOT NULL REFERENCES public.parties(id)          ON DELETE RESTRICT,
  tenant_party_id     UUID        NOT NULL REFERENCES public.parties(id)          ON DELETE RESTRICT,

  status              TEXT        NOT NULL    DEFAULT 'open'
                      CHECK (status IN ('open', 'accepted', 'withdrawn', 'expired', 'cancelled')),

  -- Ruleset version governing this negotiation's computations (ADR-0013).
  ruleset_version_id  UUID,       -- FK added after 0007 ruleset table exists.

  opened_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  closed_at           TIMESTAMPTZ
);

COMMENT ON TABLE  public.negotiations IS
  'Offer/counter negotiation between landlord and tenant. '
  'Human-driven at MVP; dual-agent AI attaches post-MVP via DSN-04 §2 '
  'without schema changes (PLN-01 §7).';

-- ---------------------------------------------------------------------------
-- term_sheet_versions
-- Each round of the offer cycle: proposed terms, who proposed them,
-- and the result. Designed so agent context can attach post-MVP.
-- DSN-01 §2: "every delta (proposer, agent context id, model+prompt version,
-- guardrail verdict) — full round history".
-- ---------------------------------------------------------------------------
CREATE TABLE public.term_sheet_versions (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  negotiation_id      UUID        NOT NULL REFERENCES public.negotiations(id)  ON DELETE RESTRICT,
  org_id              UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,

  -- Monotonically increasing round number within a negotiation.
  version_number      INTEGER     NOT NULL CHECK (version_number > 0),

  -- Which party proposed this version.
  proposed_by_party_id UUID       NOT NULL REFERENCES public.parties(id) ON DELETE RESTRICT,

  -- Proposed lease terms (structured, schema-enforced).
  monthly_rent_cents  BIGINT      NOT NULL CHECK (monthly_rent_cents > 0),
  lease_start_date    DATE        NOT NULL,
  lease_end_date      DATE        NOT NULL CHECK (lease_end_date > lease_start_date),
  deposit_amount_cents BIGINT     CHECK (deposit_amount_cents >= 0),
  lease_term_months   SMALLINT    NOT NULL CHECK (lease_term_months > 0),

  -- Additional structured terms as JSONB (pet policy, late fee terms, etc.).
  -- All values must comply with the active ruleset (ADR-0013).
  additional_terms    JSONB       NOT NULL    DEFAULT '{}',

  -- Response from the other party.
  response            TEXT        CHECK (response IN ('accepted', 'countered', 'rejected', 'expired')),
  responded_by_party_id UUID      REFERENCES public.parties(id),
  responded_at        TIMESTAMPTZ,

  -- Post-MVP agent attachment columns (NULL at MVP, reserved for DSN-04 §2).
  -- agent_context_id: the AI agent session that proposed this version.
  -- model_version:    the LLM model + prompt version used.
  -- guardrail_verdict: the guardrail service verdict on this proposal.
  agent_context_id    TEXT,       -- TODO (post-MVP, DSN-04 §2): populate when dual-agent enabled.
  model_version       TEXT,       -- TODO (post-MVP, DSN-04 §2): LLM model+prompt version identifier.
  guardrail_verdict   JSONB,      -- TODO (post-MVP, DSN-04 §2): structured guardrail output.

  CONSTRAINT term_sheet_versions_unique_round UNIQUE (negotiation_id, version_number)
);

COMMENT ON TABLE  public.term_sheet_versions IS
  'One round of an offer/counter cycle. Full history retained. '
  'Agent attachment columns (agent_context_id, model_version, guardrail_verdict) '
  'are NULL at MVP; populated when dual-agent is enabled (DSN-04 §2 / PLN-01 §7).';
COMMENT ON COLUMN public.term_sheet_versions.additional_terms IS
  'Structured additional lease terms (JSONB). '
  'Values must comply with active jurisdiction_ruleset (ADR-0013).';

-- TODO (post-MVP, DSN-01 §2): APPROVAL table.
-- Human gate record: who, what version, channel, timestamp.
-- Broker approvals (BROKER_CASE reference) are a Q1-2 requirement.
-- Deferred pending broker/PM product surface (G-05 counsel memo).

-- ---------------------------------------------------------------------------
-- leases
-- The executed lease record. The legal document is authoritative (WORM ref);
-- this row is the operational mirror and status tracker.
-- Ruleset version stamped for reproducibility (ADR-0013).
-- ---------------------------------------------------------------------------
CREATE TABLE public.leases (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id              UUID        NOT NULL REFERENCES public.organizations(id)    ON DELETE RESTRICT,
  unit_id             UUID        NOT NULL REFERENCES public.units(id)            ON DELETE RESTRICT,
  negotiation_id      UUID        REFERENCES public.negotiations(id)              ON DELETE RESTRICT,

  landlord_party_id   UUID        NOT NULL REFERENCES public.parties(id)         ON DELETE RESTRICT,
  tenant_party_id     UUID        NOT NULL REFERENCES public.parties(id)         ON DELETE RESTRICT,

  -- Mirrors saga state; lease is not fully executed until 'executed'.
  status              TEXT        NOT NULL    DEFAULT 'draft'
                      CHECK (status IN (
                        'draft', 'pending_signature', 'executed',
                        'active', 'expired', 'terminated', 'cancelled'
                      )),

  -- Core financial terms (settled at execution; authoritative in the executed document).
  monthly_rent_cents  BIGINT      NOT NULL CHECK (monthly_rent_cents > 0),
  deposit_amount_cents BIGINT     CHECK (deposit_amount_cents >= 0),
  currency_code       TEXT        NOT NULL    DEFAULT 'USD',

  -- Lease period.
  lease_start_date    DATE        NOT NULL,
  lease_end_date      DATE        NOT NULL CHECK (lease_end_date > lease_start_date),
  lease_term_months   SMALLINT    NOT NULL CHECK (lease_term_months > 0),

  -- Ruleset version that parameterized this lease (ADR-0013).
  -- Locks in the rules for the entire lease lifecycle.
  ruleset_version_id  UUID,       -- FK added after 0007 ruleset table exists.

  -- E-sign ceremony identifiers (vendor reference, e.g. DocuSign envelope ID).
  esign_envelope_ref  TEXT,
  executed_at         TIMESTAMPTZ,

  -- WORM document archive reference (see documents table below).
  executed_document_id UUID       -- FK added after documents table below.
);

COMMENT ON TABLE  public.leases IS
  'Executed lease operational record. Legal document is authoritative (WORM). '
  'Ruleset version locked at execution for reproducibility (ADR-0013). DSN-01 §2.';
COMMENT ON COLUMN public.leases.ruleset_version_id IS
  'Jurisdiction ruleset version that parameterized this lease (ADR-0013). '
  'All automated computations (late fees, notices, deposit math) reference '
  'this version for the life of the lease.';
COMMENT ON COLUMN public.leases.esign_envelope_ref IS
  'Vendor e-sign envelope identifier (DocuSign-class). '
  'E-sign evidence package archived in documents table (WORM) at execution.';

-- ---------------------------------------------------------------------------
-- documents
-- WORM document archive: hash + external WORM storage pointer + e-sign evidence.
-- Blobs live in S3 Object Lock; this row is the pointer + integrity record.
-- Data classification: LEGAL-DOCUMENT (DSN-01 §5).
-- Retention: ≥ 7 years, ruleset-configurable (C-L12).
-- ---------------------------------------------------------------------------
CREATE TABLE public.documents (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  -- No updated_at: documents are append-only once finalized.

  org_id              UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,

  -- Associated entity (typically a lease, but open for other doc types).
  lease_id            UUID        REFERENCES public.leases(id)                 ON DELETE RESTRICT,

  -- Document classification.
  doc_type            TEXT        NOT NULL
                      CHECK (doc_type IN (
                        'lease', 'lease_addendum', 'disclosure', 'adverse_action_notice',
                        'deposit_itemization', 'condition_report', 'esign_evidence',
                        'screening_consent', 'notice', 'other'
                      )),

  -- Content hash (SHA-256) of the document bytes for integrity verification.
  content_sha256      TEXT        NOT NULL,

  -- WORM storage pointer (S3 Object Lock URI or equivalent).
  worm_storage_uri    TEXT        NOT NULL,

  -- MIME type of the stored document.
  mime_type           TEXT        NOT NULL    DEFAULT 'application/pdf',

  -- File size in bytes.
  file_size_bytes     BIGINT,

  -- E-sign evidence reference: vendor's tamper-sealed certificate.
  -- This is the primary evidentiary artifact at MVP (PLN-01 §4).
  esign_evidence_ref  TEXT,

  -- Template version used to generate this document (for reproducibility).
  template_version    TEXT,

  -- Ruleset version in effect when this document was generated (ADR-0013).
  ruleset_version_id  UUID,       -- FK added after 0007 ruleset table exists.

  -- Retention schedule.
  retain_until        TIMESTAMPTZ,
  is_legal_hold       BOOLEAN     NOT NULL DEFAULT FALSE,

  -- Who uploaded / which service generated this document.
  created_by_party_id UUID        REFERENCES public.parties(id)
);

-- DATA CLASSIFICATION: LEGAL-DOCUMENT (DSN-01 §5)
-- Retention: ≥ 7 years, ruleset-configurable per C-L12.
-- WORM enforced at storage layer (S3 Object Lock); this row is the pointer.
-- Legal hold via is_legal_hold suspends any automated retention expiry.
COMMENT ON TABLE  public.documents IS
  'WORM document archive: hash pointer + e-sign evidence. '
  'DATA CLASS: legal-document (DSN-01 §5). '
  'Blobs stored in S3 Object Lock; this row provides integrity + retention tracking. '
  'Retention ≥ 7 years, ruleset-configurable (C-L12 / ADR-0013).';
COMMENT ON COLUMN public.documents.content_sha256 IS
  'SHA-256 hash of the document file bytes. '
  'Used for integrity verification by the public Verification API (ARC-08 §8.3).';
COMMENT ON COLUMN public.documents.worm_storage_uri IS
  'S3 Object Lock (or equivalent WORM) URI. '
  'The blob at this URI is the authoritative legal artifact.';
COMMENT ON COLUMN public.documents.esign_evidence_ref IS
  'E-sign vendor tamper-sealed evidence package reference (e.g. DocuSign certificate). '
  'Primary evidentiary artifact per ESIGN/UETA (PLN-01 §4 / ARC-08 §8.1).';

-- ---------------------------------------------------------------------------
-- Back-fill FK on leases.executed_document_id now that documents exists.
-- ---------------------------------------------------------------------------
ALTER TABLE public.leases
  ADD CONSTRAINT fk_leases_executed_document
  FOREIGN KEY (executed_document_id) REFERENCES public.documents(id);

-- ---------------------------------------------------------------------------
-- Back-fill FK on screening_reports.consent_document_id now that documents exists.
-- ---------------------------------------------------------------------------
ALTER TABLE public.screening_reports
  ADD CONSTRAINT fk_screening_consent_document
  FOREIGN KEY (consent_document_id) REFERENCES public.documents(id);

-- ---------------------------------------------------------------------------
-- condition_reports
-- Move-in / move-out property condition documentation.
-- Both-party acknowledgment; photo evidence stored via documents table.
-- Geo-attested walkthrough is deferred to Increment 1c (PLN-01 §3).
-- ---------------------------------------------------------------------------
CREATE TABLE public.condition_reports (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id              UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  lease_id            UUID        NOT NULL REFERENCES public.leases(id)        ON DELETE RESTRICT,
  unit_id             UUID        NOT NULL REFERENCES public.units(id)         ON DELETE RESTRICT,

  report_type         TEXT        NOT NULL CHECK (report_type IN ('move_in', 'move_out')),

  -- Condition observations as structured JSONB array of room/area entries.
  -- Each entry: {room, condition, notes, photo_document_ids: [uuid...]}.
  observations        JSONB       NOT NULL    DEFAULT '[]',

  -- Acknowledgment by both parties (required for deposit dispute defense).
  landlord_acknowledged_at  TIMESTAMPTZ,
  landlord_party_id         UUID   REFERENCES public.parties(id),
  tenant_acknowledged_at    TIMESTAMPTZ,
  tenant_party_id           UUID   REFERENCES public.parties(id),

  -- Linked document (the compiled PDF report stored in WORM).
  document_id         UUID        REFERENCES public.documents(id),

  status              TEXT        NOT NULL    DEFAULT 'draft'
                      CHECK (status IN ('draft', 'pending_acknowledgment', 'acknowledged', 'disputed'))

  -- TODO (post-MVP, PLN-01 §3): geo-attested mobile walkthrough.
  -- Add geo_attestation_ref column when Increment 1c mobile app ships.
);

COMMENT ON TABLE  public.condition_reports IS
  'Move-in / move-out condition documentation with both-party acknowledgment. '
  'Photos stored in documents table. '
  'Geo-attested walkthrough deferred to Increment 1c (PLN-01 §3).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_negotiations_org_id         ON public.negotiations(org_id);
CREATE INDEX idx_negotiations_listing_id     ON public.negotiations(listing_id);
CREATE INDEX idx_negotiations_tenant_party   ON public.negotiations(tenant_party_id);
CREATE INDEX idx_term_sheet_versions_neg_id  ON public.term_sheet_versions(negotiation_id);
CREATE INDEX idx_leases_org_id              ON public.leases(org_id);
CREATE INDEX idx_leases_unit_id             ON public.leases(unit_id);
CREATE INDEX idx_leases_tenant_party_id     ON public.leases(tenant_party_id);
CREATE INDEX idx_leases_status              ON public.leases(status);
CREATE INDEX idx_documents_org_id           ON public.documents(org_id);
CREATE INDEX idx_documents_lease_id         ON public.documents(lease_id);
CREATE INDEX idx_documents_doc_type         ON public.documents(doc_type);
CREATE INDEX idx_condition_reports_lease_id ON public.condition_reports(lease_id);
