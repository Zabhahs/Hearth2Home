/**
 * Unit tests for the Supabase-backed AuditStore wiring.
 *
 * Uses a FAKE structural client (no @supabase/supabase-js, no network, no key)
 * that records the query path and returns canned data. This proves the store
 * builds the correct `audit` query / RPC call and coerces the BIGINT seq —
 * without any live-DB dependency (CLAUDE.md invariant 6).
 */
import { describe, it, expect } from "vitest";

import {
  createSupabaseAuditStore,
  type AuditCapableClient,
} from "@/modules/audit/supabase-store";
import { computeLinkHash } from "@/modules/audit/hash-chain";
import type { AppendAuditEventArgs } from "@/modules/audit/audit-log";

interface HeadRow {
  seq: number | string;
  stream_id: string;
  prev_hash: string;
  payload_hash: string;
}

interface FakeClientOptions {
  headRow?: HeadRow | null;
  headError?: string;
  rpcResult?: unknown;
  rpcError?: string;
}

/** Capture of how the store called the client, for assertions. */
interface CallLog {
  schemaName?: string;
  selectColumns?: string;
  eqColumn?: string;
  eqValue?: string;
  orderColumn?: string;
  orderAscending?: boolean;
  limit?: number;
  rpcFn?: string;
  rpcArgs?: AppendAuditEventArgs;
}

function makeFakeClient(opts: FakeClientOptions): {
  client: AuditCapableClient;
  log: CallLog;
} {
  const log: CallLog = {};
  const client: AuditCapableClient = {
    schema(name) {
      log.schemaName = name;
      return {
        from(table) {
          expect(table).toBe("audit_record");
          return {
            select(columns) {
              log.selectColumns = columns;
              return {
                eq(column, value) {
                  log.eqColumn = column;
                  log.eqValue = value;
                  return {
                    order(orderColumn, orderOpts) {
                      log.orderColumn = orderColumn;
                      log.orderAscending = orderOpts.ascending;
                      return {
                        limit(n) {
                          log.limit = n;
                          return {
                            async maybeSingle() {
                              return {
                                data: (opts.headRow ?? null) as never,
                                error: opts.headError
                                  ? { message: opts.headError }
                                  : null,
                              };
                            },
                          };
                        },
                      };
                    },
                  };
                },
              };
            },
          };
        },
        async rpc(fn, args) {
          log.rpcFn = fn;
          log.rpcArgs = args;
          return {
            data: opts.rpcResult,
            error: opts.rpcError ? { message: opts.rpcError } : null,
          };
        },
      };
    },
  };
  return { client, log };
}

const baseArgs: AppendAuditEventArgs = {
  p_stream_id: "lease:abc",
  p_prev_hash: "p".repeat(64),
  p_payload_hash: "h".repeat(64),
};

describe("createSupabaseAuditStore.getStreamHead", () => {
  it("returns null for an empty stream", async () => {
    const { client, log } = makeFakeClient({ headRow: null });
    const store = createSupabaseAuditStore(client);
    const head = await store.getStreamHead("lease:abc");
    expect(head).toBeNull();
    // Query path assertions.
    expect(log.schemaName).toBe("audit");
    expect(log.eqColumn).toBe("stream_id");
    expect(log.eqValue).toBe("lease:abc");
    expect(log.orderColumn).toBe("seq");
    expect(log.orderAscending).toBe(false);
    expect(log.limit).toBe(1);
  });

  it("computes the head link hash from the latest row", async () => {
    const headRow: HeadRow = {
      seq: 7,
      stream_id: "lease:abc",
      prev_hash: "a".repeat(64),
      payload_hash: "b".repeat(64),
    };
    const { client } = makeFakeClient({ headRow });
    const store = createSupabaseAuditStore(client);
    const head = await store.getStreamHead("lease:abc");
    expect(head).not.toBeNull();
    expect(head!.seq).toBe(7);
    expect(head!.linkHash).toBe(
      computeLinkHash({
        streamId: "lease:abc",
        seq: 7,
        prevHash: "a".repeat(64),
        payloadHash: "b".repeat(64),
      }),
    );
  });

  it("coerces a BIGINT seq returned as a numeric string", async () => {
    const headRow: HeadRow = {
      seq: "42",
      stream_id: "lease:abc",
      prev_hash: "a".repeat(64),
      payload_hash: "b".repeat(64),
    };
    const { client } = makeFakeClient({ headRow });
    const store = createSupabaseAuditStore(client);
    const head = await store.getStreamHead("lease:abc");
    expect(head!.seq).toBe(42);
  });

  it("throws when the head query errors", async () => {
    const { client } = makeFakeClient({ headError: "permission denied" });
    const store = createSupabaseAuditStore(client);
    await expect(store.getStreamHead("lease:abc")).rejects.toThrow(
      /getStreamHead failed: permission denied/,
    );
  });
});

describe("createSupabaseAuditStore.appendAuditEvent", () => {
  it("calls the append_audit_event RPC and returns the assigned seq", async () => {
    const { client, log } = makeFakeClient({ rpcResult: 3 });
    const store = createSupabaseAuditStore(client);
    const seq = await store.appendAuditEvent(baseArgs);
    expect(seq).toBe(3);
    expect(log.schemaName).toBe("audit");
    expect(log.rpcFn).toBe("append_audit_event");
    expect(log.rpcArgs).toEqual(baseArgs);
  });

  it("coerces a BIGINT seq returned as a numeric string", async () => {
    const { client } = makeFakeClient({ rpcResult: "100" });
    const store = createSupabaseAuditStore(client);
    expect(await store.appendAuditEvent(baseArgs)).toBe(100);
  });

  it("throws when the RPC errors", async () => {
    const { client } = makeFakeClient({ rpcError: "deadlock detected" });
    const store = createSupabaseAuditStore(client);
    await expect(store.appendAuditEvent(baseArgs)).rejects.toThrow(
      /append_audit_event failed: deadlock detected/,
    );
  });

  it("throws on an unexpected (non-integer) seq value", async () => {
    const { client } = makeFakeClient({ rpcResult: { not: "a seq" } });
    const store = createSupabaseAuditStore(client);
    await expect(store.appendAuditEvent(baseArgs)).rejects.toThrow(/unexpected seq value/);
  });
});
