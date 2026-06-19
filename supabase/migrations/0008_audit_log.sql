-- =============================================================================
-- 0008_audit_log.sql
-- Hash-chained append-only audit log (ADR-0012 / ARC-08 §8.3).
--
-- Design:
--   - ALL writes go through append_audit_event() (security-definer).
--   - NO application role may UPDATE or DELETE rows in audit.audit_record.
--   - Per-stream hash chain: each row links to the previous row in its stream
--     via prev_hash. Sequence numbers are gapless within a stream.
--   - Daily Merkle anchor: a separate daily_anchor row records the Merkle root
--     across all streams for a UTC day, to be written to the on-chain anchor
--     contract (ADR-0012). The anchor itself is recorded as an audit event.
--   - Payload hashes + WORM pointers are stored; blobs are not.
--   - AI events carry model/prompt version and guardrail verdict (ARC-08 §8.3).
--
-- Data classification: AUDIT (DSN-01 §5).
-- Retention: Never deleted within retention horizon; legal-hold capable.
-- Subject identifiers in payload are tokenized for PII erasure compliance.
--
-- References: ADR-0012, ARC-08 §8.3, DSN-01 §2 (AUDIT_RECORD), DSN-01 §5.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- audit.audit_record
-- The append-only hash-chained event log.
--
-- SECURITY NOTE (ADR-0012):
--   UPDATE and DELETE on this table are REVOKED from all application roles.
--   Writes must go through append_audit_event() (security-definer, defined below).
--   This comment is load-bearing: the REVOKE statements are in 0009_rls_policies.sql.
-- ---------------------------------------------------------------------------
CREATE TABLE audit.audit_record (
  -- Monotonically increasing sequence per stream. Gapless within stream.
  seq                 BIGSERIAL   NOT NULL,

  -- Logical stream identifier: one stream per entity type or subsystem.
  -- Examples: 'org:{org_id}', 'lease:{lease_id}', 'platform'.
  stream_id           TEXT        NOT NULL,

  -- Hash chain linkage. The prev_hash of the first event in a stream is
  -- the SHA-256 of the stream_id string (bootstraps the chain).
  prev_hash           TEXT        NOT NULL,

  -- SHA-256 hash of the canonical JSON payload (the integrity commitment).
  payload_hash        TEXT        NOT NULL,

  -- Timestamp: set by append_audit_event(), never by the caller.
  recorded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Actor (the authenticated user who caused this event).
  actor_party_id      UUID        REFERENCES public.parties(id),

  -- Principal (the org/party on whose behalf the actor acted; agency model).
  -- May equal actor_party_id for self-owned actions.
  principal_party_id  UUID        REFERENCES public.parties(id),

  -- Action verb: what happened (e.g. 'lease.executed', 'payment.initiated').
  action              TEXT        NOT NULL,

  -- Entity type and ID that was affected.
  entity_type         TEXT        NOT NULL,
  entity_id           UUID,

  -- Abbreviated payload (non-blob) for quick inspection.
  -- Full payload is reconstructable from payload_hash + WORM store.
  -- PII fields in payload_summary are tokenized (not raw PII).
  payload_summary     JSONB,

  -- WORM storage pointer for the full payload blob (if persisted externally).
  worm_payload_uri    TEXT,

  -- AI event fields (ARC-08 §8.3): populated when action is AI-generated.
  -- NULL for human-initiated events.
  ai_model_id         TEXT,           -- Model identifier (e.g. 'claude-3-5-sonnet-20241022').
  ai_prompt_version   TEXT,           -- Prompt template version.
  ai_input_hash       TEXT,           -- SHA-256 of full model input (stored at worm_payload_uri).
  ai_output_hash      TEXT,           -- SHA-256 of full model output.
  ai_guardrail_verdict JSONB,         -- Guardrail service structured verdict (ADR-0009).

  -- On-chain anchor reference: set when this event is included in a daily anchor.
  chain_anchor_id     UUID,           -- FK to audit.daily_anchor after that table is created.

  -- Primary key is (stream_id, seq) to enforce gaplessness per stream.
  PRIMARY KEY (stream_id, seq)
);

-- DATA CLASSIFICATION: AUDIT (DSN-01 §5)
-- Retention: never deleted within retention horizon; legal-hold enforced at
-- the daily_anchor / compliance ops layer.
COMMENT ON TABLE  audit.audit_record IS
  'Append-only hash-chained audit log (ADR-0012 / ARC-08 §8.3). '
  'DATA CLASS: audit (DSN-01 §5) — never deleted within retention horizon. '
  'Writes: append_audit_event() security-definer function ONLY. '
  'UPDATE and DELETE are revoked from all application roles (0009_rls_policies.sql). '
  'AI events carry model_id, prompt_version, input/output hashes, guardrail verdict.';
COMMENT ON COLUMN audit.audit_record.stream_id IS
  'Logical chain stream. Hash chain is per-stream (gapless seq). '
  'Convention: "entity_type:entity_id" or "platform" for cross-entity events.';
COMMENT ON COLUMN audit.audit_record.prev_hash IS
  'SHA-256 of the previous row''s canonical JSON in this stream. '
  'Bootstrap value for first event: SHA-256(stream_id). '
  'Chain integrity verified by the public Verification API (ARC-08 §8.3).';
COMMENT ON COLUMN audit.audit_record.payload_summary IS
  'Abbreviated non-PII summary for quick log inspection. '
  'PII field values are tokenized (not raw). '
  'Full payload recoverable from payload_hash + worm_payload_uri.';
COMMENT ON COLUMN audit.audit_record.ai_guardrail_verdict IS
  'Structured output from the Guardrail Service for AI-generated actions. '
  'ADR-0009: guardrail verdict is deterministic and recorded for every AI decision.';

-- ---------------------------------------------------------------------------
-- audit.daily_anchor
-- Records the daily Merkle root across all audit streams for on-chain anchoring.
-- One row per UTC day; the on-chain tx ref is set after the anchor tx confirms.
-- ---------------------------------------------------------------------------
CREATE TABLE audit.daily_anchor (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  anchor_date         DATE        NOT NULL UNIQUE,

  -- Merkle root of all stream-head hashes at end of UTC day.
  merkle_root         TEXT        NOT NULL,

  -- On-chain reference: EAS attestation UID or equivalent (ADR-0012).
  -- NULL until the anchor transaction confirms on-chain.
  chain_tx_ref        TEXT,
  chain_network       TEXT        DEFAULT 'base',   -- 'base' at MVP; 'base_sepolia' in staging.
  anchored_at         TIMESTAMPTZ,

  -- Who initiated the anchor (platform anchor key, not a user party).
  initiated_by        TEXT,

  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE  audit.daily_anchor IS
  'Daily Merkle root across all audit streams, anchored on-chain (ADR-0012). '
  'One row per UTC day. chain_tx_ref set after on-chain confirmation. '
  'Enables third-party tamper-evidence verification (ARC-08 §8.3).';
COMMENT ON COLUMN audit.daily_anchor.merkle_root IS
  'Merkle root of all stream-head hashes at end-of-day snapshot. '
  'Computed by the daily anchor job; written here before chain submission.';
COMMENT ON COLUMN audit.daily_anchor.chain_tx_ref IS
  'EAS attestation UID (or equivalent attestation contract ref) on Base. '
  'NULL until anchor transaction is confirmed. '
  'The platform-only anchor tx carries zero fund risk (R-06 / PLN-01 §2).';

-- ---------------------------------------------------------------------------
-- FK: audit_record.chain_anchor_id → audit.daily_anchor
-- ---------------------------------------------------------------------------
ALTER TABLE audit.audit_record
  ADD CONSTRAINT fk_audit_record_daily_anchor
  FOREIGN KEY (chain_anchor_id) REFERENCES audit.daily_anchor(id);

-- ---------------------------------------------------------------------------
-- append_audit_event()
-- Security-definer function: the ONLY path for inserting into audit.audit_record.
-- Callers supply the logical fields; this function:
--   1. Resolves the current stream head (latest seq + prev_hash for stream_id).
--   2. Computes seq = max(seq)+1 for the stream (advisory lock prevents races).
--   3. Sets recorded_at = now() (caller cannot supply a fake timestamp).
--   4. Inserts the row.
--
-- STUB: full cryptographic hash-chain wiring is implemented in the application
-- layer (Supabase Edge Function or server-side API) which calls this function
-- with the pre-computed payload_hash and resolved prev_hash.
-- The function here enforces the insert-only contract and timestamp integrity.
--
-- IMPORTANT: This function runs as SECURITY DEFINER (owner = postgres / supabase
-- superuser). Application roles are granted EXECUTE on this function but have
-- NO direct INSERT/UPDATE/DELETE on audit.audit_record.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit.append_audit_event(
  p_stream_id         TEXT,
  p_prev_hash         TEXT,
  p_payload_hash      TEXT,
  p_actor_party_id    UUID        DEFAULT NULL,
  p_principal_party_id UUID       DEFAULT NULL,
  p_action            TEXT        DEFAULT NULL,
  p_entity_type       TEXT        DEFAULT NULL,
  p_entity_id         UUID        DEFAULT NULL,
  p_payload_summary   JSONB       DEFAULT NULL,
  p_worm_payload_uri  TEXT        DEFAULT NULL,
  p_ai_model_id       TEXT        DEFAULT NULL,
  p_ai_prompt_version TEXT        DEFAULT NULL,
  p_ai_input_hash     TEXT        DEFAULT NULL,
  p_ai_output_hash    TEXT        DEFAULT NULL,
  p_ai_guardrail_verdict JSONB    DEFAULT NULL
)
RETURNS BIGINT   -- Returns the assigned seq number.
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = audit, public
AS $$
DECLARE
  v_seq BIGINT;
BEGIN
  -- Advisory lock on the stream to serialize inserts and prevent seq gaps.
  -- Using hashtext to convert stream_id to a lock key.
  PERFORM pg_advisory_xact_lock(hashtext(p_stream_id));

  -- Determine the next sequence number for this stream.
  SELECT COALESCE(MAX(seq), 0) + 1
    INTO v_seq
    FROM audit.audit_record
   WHERE stream_id = p_stream_id;

  -- Insert the event. recorded_at is set by the DB (not the caller).
  INSERT INTO audit.audit_record (
    seq, stream_id, prev_hash, payload_hash, recorded_at,
    actor_party_id, principal_party_id, action,
    entity_type, entity_id,
    payload_summary, worm_payload_uri,
    ai_model_id, ai_prompt_version, ai_input_hash, ai_output_hash,
    ai_guardrail_verdict
  ) VALUES (
    v_seq, p_stream_id, p_prev_hash, p_payload_hash, now(),
    p_actor_party_id, p_principal_party_id, p_action,
    p_entity_type, p_entity_id,
    p_payload_summary, p_worm_payload_uri,
    p_ai_model_id, p_ai_prompt_version, p_ai_input_hash, p_ai_output_hash,
    p_ai_guardrail_verdict
  );

  RETURN v_seq;
END;
$$;

COMMENT ON FUNCTION audit.append_audit_event IS
  'SECURITY DEFINER insert function for audit.audit_record. '
  'The ONLY authorized write path (ADR-0012). '
  'Serializes inserts per stream with advisory lock to ensure gapless seq. '
  'Application roles have EXECUTE on this function; '
  'no direct INSERT/UPDATE/DELETE on audit.audit_record. '
  'prev_hash and payload_hash computed by caller (application layer); '
  'recorded_at is set here and cannot be overridden.';

-- ---------------------------------------------------------------------------
-- Indexes on audit.audit_record
-- ---------------------------------------------------------------------------
-- Stream + seq: primary key covers this.
-- By entity: for looking up all events affecting a given entity.
CREATE INDEX idx_audit_record_entity
  ON audit.audit_record(entity_type, entity_id);

-- By actor: for actor activity timelines.
CREATE INDEX idx_audit_record_actor
  ON audit.audit_record(actor_party_id, recorded_at DESC);

-- By recorded_at for time-range queries in the Verification API.
CREATE INDEX idx_audit_record_recorded_at
  ON audit.audit_record(recorded_at DESC);

-- By anchor: for finding all events included in a given daily anchor.
CREATE INDEX idx_audit_record_chain_anchor
  ON audit.audit_record(chain_anchor_id)
  WHERE chain_anchor_id IS NOT NULL;
