-- =============================================================================
-- 0006_payments_ledger.sql
-- Payment obligations, payment events, and deposit documentation.
--
-- MVP scope (PLN-01 §3):
--   - ACH autopay via PayFac partner (processor-held, platform NEVER custodies).
--   - NACHA authorization tracked; retries and dunning owned by Rail Router.
--   - Deposit DOCUMENTED not held: amount, holding location, statutory timers,
--     itemization letter generator.
-- EXCLUDED (per PLN-01 §3): stablecoin escrow, smart accounts, on-chain
-- settlement tables, escrow_agreement — deferred to Increment 1b (O-3/O-5).
--
-- Data classification (DSN-01 §5):
--   payment_obligations → regulated-financial (7 y retention).
--   payment_events      → regulated-financial (7 y retention).
--   deposit_records     → regulated-financial (7 y or per statute).
--
-- References: DSN-01 §2 (PAYMENT_OBLIGATION, PAYMENT_EVENT), ARC-08 §8.4,
--             PLN-01 §2 (processor-rail, never-hold posture), ADR-0018.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- payment_obligations
-- Rail-agnostic ledger entry: what is owed, by whom, to whom, and when.
-- One obligation per scheduled payment event (rent, late fee, etc.).
-- The obligation is created deterministically from the lease + ruleset.
-- ---------------------------------------------------------------------------
CREATE TABLE public.payment_obligations (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id              UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  lease_id            UUID        NOT NULL REFERENCES public.leases(id)        ON DELETE RESTRICT,

  -- Payor and payee party references.
  payor_party_id      UUID        NOT NULL REFERENCES public.parties(id)       ON DELETE RESTRICT,
  payee_party_id      UUID        NOT NULL REFERENCES public.parties(id)       ON DELETE RESTRICT,

  -- Type of obligation.
  obligation_type     TEXT        NOT NULL
                      CHECK (obligation_type IN (
                        'rent', 'late_fee', 'deposit', 'deposit_refund',
                        'utility_reimbursement', 'other'
                      )),

  -- Amount in smallest currency unit (cents for USD).
  amount_cents        BIGINT      NOT NULL CHECK (amount_cents > 0),
  currency_code       TEXT        NOT NULL DEFAULT 'USD',

  -- When this obligation is due; date-only (time is midnight in tenant's TZ).
  due_date            DATE        NOT NULL,

  -- Lifecycle status.
  status              TEXT        NOT NULL DEFAULT 'scheduled'
                      CHECK (status IN (
                        'scheduled', 'pending', 'processing', 'settled',
                        'partially_settled', 'overdue', 'waived', 'cancelled'
                      )),

  -- Amount already settled (for partial payments).
  settled_cents       BIGINT      NOT NULL DEFAULT 0 CHECK (settled_cents >= 0),

  -- Ruleset version used to compute this obligation (late-fee math, etc.).
  ruleset_version_id  UUID,       -- FK added after 0007.

  -- NACHA ACH authorization: landlord must collect signed NACHA authorization
  -- from tenant before initiating debits (PLN-01 §3).
  nacha_authorization_ref TEXT,

  -- Idempotency key for saga / Rail Router retries (ARC-08 §8.4).
  idempotency_key     TEXT        UNIQUE,

  -- When this obligation was first scheduled and when it was last updated.
  settled_at          TIMESTAMPTZ
);

-- DATA CLASSIFICATION: REGULATED-FINANCIAL (DSN-01 §5)
-- Retention: 7 years default (state-configurable); WORM for statements.
COMMENT ON TABLE  public.payment_obligations IS
  'Rail-agnostic scheduled payment obligation (rent, fees, etc.). '
  'DATA CLASS: regulated-financial (DSN-01 §5), 7-year retention. '
  'Amount computed from lease + ruleset_version; reproducible (ADR-0013). '
  'Platform never holds funds — processor-rail model (PLN-01 §2 / ADR-0018).';
COMMENT ON COLUMN public.payment_obligations.nacha_authorization_ref IS
  'Reference to the tenant''s signed NACHA ACH authorization. '
  'Must be set before the Rail Router initiates an ACH debit (PLN-01 §3).';
COMMENT ON COLUMN public.payment_obligations.idempotency_key IS
  'Idempotency key for Rail Router retries. '
  'Prevents duplicate debits on retry (ARC-08 §8.4).';

-- ---------------------------------------------------------------------------
-- payment_events
-- Settlement record on a specific payment rail.
-- One obligation may have multiple events (retries, partial payments).
-- Rail = 'ach' at MVP; additional rails added without schema changes.
-- ---------------------------------------------------------------------------
CREATE TABLE public.payment_events (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL    DEFAULT now(),
  -- No updated_at: events are immutable once created.

  org_id              UUID        NOT NULL REFERENCES public.organizations(id)         ON DELETE RESTRICT,
  obligation_id       UUID        NOT NULL REFERENCES public.payment_obligations(id)   ON DELETE RESTRICT,

  -- Rail used for this settlement attempt.
  -- MVP: 'ach' only (ADR-0018 / PLN-01 §3 "Rail Router with one rail").
  rail                TEXT        NOT NULL DEFAULT 'ach'
                      CHECK (rail IN ('ach', 'wire', 'check', 'stablecoin', 'other')),

  -- Processor-side reference (Stripe charge ID, Dwolla transfer ID, etc.).
  processor_ref       TEXT,

  -- ACH trace number (NACHA ABA+sequence) — the settlement chain trail.
  ach_trace_number    TEXT,

  -- Amount in this event (may be partial).
  amount_cents        BIGINT      NOT NULL CHECK (amount_cents > 0),
  currency_code       TEXT        NOT NULL DEFAULT 'USD',

  -- Event type: 'debit' pulls from tenant; 'credit' pushes to landlord.
  event_type          TEXT        NOT NULL CHECK (event_type IN ('debit', 'credit', 'refund', 'reversal')),

  -- Settlement status per ARC-08 §8.4 finality policy.
  -- 'observed': soft confirmation received.
  -- 'confirmed': business-final per finality policy (ACH: same-day or next-day).
  -- 'failed': terminal failure; obligation may be retried.
  -- 'returned': ACH return code received; triggers dunning workflow.
  finality_status     TEXT        NOT NULL DEFAULT 'observed'
                      CHECK (finality_status IN (
                        'observed', 'confirmed', 'failed', 'returned', 'reversed'
                      )),

  -- ACH return code if returned (e.g. R01, R02).
  ach_return_code     TEXT,

  -- When the event was initiated and when finality was reached.
  initiated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  finalized_at        TIMESTAMPTZ,

  -- Idempotency key for this specific rail operation.
  idempotency_key     TEXT        UNIQUE
);

-- DATA CLASSIFICATION: REGULATED-FINANCIAL (DSN-01 §5)
-- Retention: 7 years default; WORM for periodic statements.
COMMENT ON TABLE  public.payment_events IS
  'Settlement record on a specific payment rail. '
  'DATA CLASS: regulated-financial (DSN-01 §5), 7-year retention. '
  'Immutable once created; retries create new events. '
  'finality_status advances per ARC-08 §8.4 finality policy.';
COMMENT ON COLUMN public.payment_events.rail IS
  'Payment rail. MVP: ach only (ADR-0018). '
  'stablecoin deferred to Increment 1b (O-3/O-5 / PLN-01 §3).';
COMMENT ON COLUMN public.payment_events.finality_status IS
  'ACH finality: observed (initiated) → confirmed (ACH settlement complete) '
  'or returned (R-code from receiving bank, triggers dunning). '
  'ARC-08 §8.4: fund-release sagas advance on confirmed only.';
COMMENT ON COLUMN public.payment_events.ach_trace_number IS
  'NACHA ACH trace number (ABA routing + 7-digit sequence). '
  'The statutory audit trail for ACH transactions.';

-- ---------------------------------------------------------------------------
-- deposit_records
-- Deposit DOCUMENTED not held (PLN-01 §2 G-02).
-- Records amount, holding location (landlord's own account), statutory
-- timers, and supports itemization letter generation.
-- Platform never takes custody of deposit funds.
-- ---------------------------------------------------------------------------
CREATE TABLE public.deposit_records (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL    DEFAULT now(),

  org_id                  UUID        NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  lease_id                UUID        NOT NULL UNIQUE -- one deposit record per lease
                          REFERENCES public.leases(id) ON DELETE RESTRICT,
  landlord_party_id       UUID        NOT NULL REFERENCES public.parties(id)       ON DELETE RESTRICT,
  tenant_party_id         UUID        NOT NULL REFERENCES public.parties(id)       ON DELETE RESTRICT,

  -- Deposit amount and currency.
  amount_cents            BIGINT      NOT NULL CHECK (amount_cents > 0),
  currency_code           TEXT        NOT NULL DEFAULT 'USD',

  -- Holding location: the landlord's own account details.
  -- The platform does not hold these funds (G-02 posture, PLN-01 §2).
  holding_institution     TEXT,       -- Bank name / description.
  holding_account_last4   TEXT,       -- Last 4 digits only (no full account numbers stored here).

  -- Ruleset version: determines deposit cap, return deadline, interest rules.
  ruleset_version_id      UUID,       -- FK added after 0007.

  -- Statutory timers (ADR-0013 / DSN-06 §3): populated from ruleset parameters.
  -- return_deadline_date is computed at lease execution from ruleset + move-out date.
  collected_at            DATE,
  move_out_date           DATE,
  return_deadline_date    DATE,       -- Computed by application from ruleset.

  -- Status lifecycle.
  status                  TEXT        NOT NULL DEFAULT 'collected'
                          CHECK (status IN (
                            'collected', 'partial_deducted', 'itemized',
                            'refunded', 'disputed', 'forfeited'
                          )),

  -- Refund tracking.
  refunded_amount_cents   BIGINT      DEFAULT 0 CHECK (refunded_amount_cents >= 0),
  refunded_at             DATE,

  -- Deductions (JSONB array of itemized deductions).
  -- Each entry: {description, amount_cents, category, evidence_document_id}.
  deductions              JSONB       NOT NULL DEFAULT '[]',

  -- Itemization letter document (generated by the platform).
  itemization_document_id UUID        REFERENCES public.documents(id),

  -- Legal hold suspends any automated timer expiry notifications.
  is_legal_hold           BOOLEAN     NOT NULL DEFAULT FALSE
);

-- DATA CLASSIFICATION: REGULATED-FINANCIAL (DSN-01 §5)
-- Retention: 7 years or per state statute (whichever is longer).
COMMENT ON TABLE  public.deposit_records IS
  'Deposit DOCUMENTED, never held by platform (PLN-01 §2 / G-02 posture). '
  'DATA CLASS: regulated-financial (DSN-01 §5), 7-year minimum retention. '
  'Platform records amount, location, statutory timers, and itemization. '
  'Deposit funds stay in landlord''s own account per state statute.';
COMMENT ON COLUMN public.deposit_records.holding_account_last4 IS
  'Last 4 digits of the holding account for reference only. '
  'Full account numbers are not stored here (minimization, DSN-01 §5).';
COMMENT ON COLUMN public.deposit_records.return_deadline_date IS
  'Statutory return deadline computed from ruleset parameters at move-out. '
  'Platform sends timer notifications; landlord is responsible for compliance.';
COMMENT ON COLUMN public.deposit_records.deductions IS
  'Itemized deductions: [{description, amount_cents, category, evidence_document_id}]. '
  'Supports the itemization letter generator (PLN-01 §3).';

-- TODO (post-MVP, DSN-01 §2 / PLN-01 §3): ESCROW_AGREEMENT table.
-- On-chain or trust-account deposit custody. Deferred pending per-state
-- legality analysis (O-5) and custody partner onboarding (ADR-0007 / O-3).
-- When added, include: vault agreement id, party set (only lawful destinations),
-- amounts, rail, state machine
-- (FUNDED/HELD/RELEASE_PROPOSED/DISPUTED/RELEASED/REFUNDED/FROZEN_LEGAL).

-- TODO (post-MVP, DSN-01 §2): DEPOSIT_DEDUCTION table (child rows of escrow_agreement).
-- Used when on-chain escrow is in custody; replaces deductions JSONB above.

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_payment_obligations_org_id    ON public.payment_obligations(org_id);
CREATE INDEX idx_payment_obligations_lease_id  ON public.payment_obligations(lease_id);
CREATE INDEX idx_payment_obligations_status    ON public.payment_obligations(status);
CREATE INDEX idx_payment_obligations_due_date  ON public.payment_obligations(due_date) WHERE status = 'scheduled';
CREATE INDEX idx_payment_events_org_id         ON public.payment_events(org_id);
CREATE INDEX idx_payment_events_obligation_id  ON public.payment_events(obligation_id);
CREATE INDEX idx_payment_events_finality       ON public.payment_events(finality_status);
CREATE INDEX idx_deposit_records_org_id        ON public.deposit_records(org_id);
CREATE INDEX idx_deposit_records_lease_id      ON public.deposit_records(lease_id);
