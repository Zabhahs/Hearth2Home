-- =============================================================================
-- 0001_extensions.sql
-- Enable required PostgreSQL extensions for Hearth2Home MVP.
--
-- References: DSN-01 §3 (pgvector for match_features embeddings),
--             ADR-0009 (allowlisted feature schema), DSN-01 §5 (UUIDs).
-- =============================================================================

-- pgcrypto: gen_random_uuid() for all primary keys.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- pgvector: embedding columns in the match_features schema (DSN-01 §3).
-- Required for style-descriptor similarity search (Increment 1c path).
CREATE EXTENSION IF NOT EXISTS vector;

-- citext: case-insensitive text type used for email addresses on parties.
CREATE EXTENSION IF NOT EXISTS citext;

-- =============================================================================
-- Schema: match_features
-- Holds ONLY allowlisted, non-protected-class matching attributes per ADR-0009.
--
-- IMPORTANT CONSTRAINT (ADR-0009 §1):
--   No protected-class attribute (race, color, national origin, religion, sex,
--   familial status, disability, or any established proxy thereof) may ever be
--   added as a column to this schema. All additions require a four-eyes
--   compliance review before the column may be created.
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS match_features;

COMMENT ON SCHEMA match_features IS
  'Allowlisted matching feature store (ADR-0009 / DSN-01 §3). '
  'Only lawful, non-protected-class attributes may exist here. '
  'NEVER add protected-class attributes or their proxies to this schema. '
  'Every new column requires four-eyes compliance sign-off.';

-- =============================================================================
-- Schema: audit
-- Holds the append-only, hash-chained audit log (ADR-0012 / ARC-08 §8.3).
-- No application role may UPDATE or DELETE rows in this schema.
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA audit IS
  'Append-only hash-chained audit log (ADR-0012). '
  'No UPDATE or DELETE is permitted on any table in this schema. '
  'Writes go through the append_audit_event() security-definer function only.';
