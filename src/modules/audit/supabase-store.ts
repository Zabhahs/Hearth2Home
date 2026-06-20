/**
 * Supabase-backed {@link AuditStore} (production wiring for ARC-08 §8.3).
 *
 * Wraps a Supabase service-role client so the {@link AuditLog} writer can:
 *   1. read the current stream head from `audit.audit_record`, and
 *   2. append via the security-definer `audit.append_audit_event` function.
 *
 * The `audit` schema is NOT part of the generated `Database` type in
 * src/lib/supabase/database.types.ts, so we depend only on the minimal
 * structural surface of the client we actually use ({@link AuditCapableClient}).
 * This keeps the writer's tests free of any Supabase import and lets the real
 * client (which bypasses RLS as service_role) satisfy the interface at the call
 * site.
 *
 * NOTE: This module is the only piece that talks to Supabase. It is deliberately
 * thin and is exercised end-to-end against the live DB, not in unit tests (the
 * service-role key is a placeholder in CI — see CLAUDE.md invariant 6). The
 * writer logic and chain core are fully unit-tested via a fake store.
 */
import type { AppendAuditEventArgs, AuditStore, StreamHead } from "@/modules/audit/audit-log";
import { computeLinkHash } from "@/modules/audit/hash-chain";

/**
 * A single row shape we read back when resolving a stream head. Only the chain
 * fields are needed to recompute the head's link hash.
 */
interface StreamHeadRow {
  seq: number;
  stream_id: string;
  prev_hash: string;
  payload_hash: string;
}

/**
 * The minimal structural surface of a Supabase client this store relies on.
 *
 * Both `@supabase/supabase-js`'s `SupabaseClient` and the SSR server client
 * satisfy this. We keep it structural (rather than importing `SupabaseClient`)
 * so callers can pass either, and so the `audit` schema — absent from the
 * generated types — does not force `any` casts at the boundary.
 */
export interface AuditSchemaClient {
  from(table: "audit_record"): {
    select(columns: string): {
      eq(
        column: "stream_id",
        value: string,
      ): {
        order(
          column: "seq",
          opts: { ascending: boolean },
        ): {
          limit(n: number): {
            maybeSingle(): Promise<{
              data: StreamHeadRow | null;
              error: { message: string } | null;
            }>;
          };
        };
      };
    };
  };
  rpc(
    fn: "append_audit_event",
    args: AppendAuditEventArgs,
  ): Promise<{ data: unknown; error: { message: string } | null }>;
}

export interface AuditCapableClient {
  schema(name: "audit"): AuditSchemaClient;
}

/**
 * Coerce the DB's BIGINT seq (which supabase-js may surface as a number or a
 * numeric string) into a safe integer.
 */
function toSeq(value: unknown): number {
  if (typeof value === "number" && Number.isInteger(value)) {
    return value;
  }
  if (typeof value === "string" && /^\d+$/.test(value)) {
    const n = Number(value);
    if (Number.isSafeInteger(n)) {
      return n;
    }
  }
  throw new TypeError(`audit append: unexpected seq value from DB: ${JSON.stringify(value)}`);
}

/**
 * Build an {@link AuditStore} backed by a Supabase service-role client.
 *
 * The RPC targets the `append_audit_event` function in the `audit` schema; the
 * service client is configured for that schema at the call boundary (or the
 * function is exposed via the default schema search path). Errors from either
 * call are thrown so the writer treats them as a failed append.
 */
export function createSupabaseAuditStore(client: AuditCapableClient): AuditStore {
  return {
    async getStreamHead(streamId: string): Promise<StreamHead | null> {
      const { data, error } = await client
        .schema("audit")
        .from("audit_record")
        .select("seq, stream_id, prev_hash, payload_hash")
        .eq("stream_id", streamId)
        .order("seq", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (error) {
        throw new Error(`audit getStreamHead failed: ${error.message}`);
      }
      if (!data) {
        return null;
      }

      const linkHash = computeLinkHash({
        streamId: data.stream_id,
        seq: toSeq(data.seq),
        prevHash: data.prev_hash,
        payloadHash: data.payload_hash,
      });
      return { seq: toSeq(data.seq), linkHash };
    },

    async appendAuditEvent(args: AppendAuditEventArgs): Promise<number> {
      const { data, error } = await client.schema("audit").rpc("append_audit_event", args);
      if (error) {
        throw new Error(`audit append_audit_event failed: ${error.message}`);
      }
      return toSeq(data);
    },
  };
}
