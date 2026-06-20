/**
 * Audit module public surface (ARC-05 §5.2 — Audit Log Service).
 *
 * - Hash-chain core: pure, DB-free integrity primitives (ARC-08 §8.3).
 * - AuditLog writer: records events via `audit.append_audit_event`, store
 *   injected for testability.
 * - Supabase store: production wiring of the writer to the service client.
 */
export {
  canonicalize,
  hashPayload,
  genesisPrevHash,
  computeLinkHash,
  linkEvent,
  verifyChain,
  merkleRoot,
  type ChainEvent,
  type RecordedEvent,
  type ChainViolation,
  type VerifyResult,
} from "@/modules/audit/hash-chain";

export {
  AuditLog,
  type AuditStore,
  type StreamHead,
  type AppendAuditEventArgs,
  type AuditEventInput,
  type AuditAiContext,
  type AppendResult,
} from "@/modules/audit/audit-log";

export {
  createSupabaseAuditStore,
  type AuditCapableClient,
  type AuditSchemaClient,
} from "@/modules/audit/supabase-store";
