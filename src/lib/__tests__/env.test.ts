/**
 * Smoke test: env module shape.
 *
 * Validates that `publicEnv` and `serverEnv` parse correctly when all
 * required environment variables are present, and that the exported types
 * have the expected keys.
 */
import { describe, it, expect, beforeAll, vi } from "vitest";

const VALID_SUPABASE_URL = "https://test.supabase.co";
const VALID_ANON_KEY = "anon-key-placeholder";
const VALID_SERVICE_ROLE_KEY = "service-role-key-placeholder";
const VALID_DATABASE_URL = "postgresql://user:pass@localhost:5432/db";

beforeAll(() => {
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", VALID_SUPABASE_URL);
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY", VALID_ANON_KEY);
  vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", VALID_SERVICE_ROLE_KEY);
  vi.stubEnv("DATABASE_URL", VALID_DATABASE_URL);
});

describe("env module", () => {
  it("publicEnv exposes NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY", async () => {
    // Dynamic import so stubEnv takes effect before the module parses
    const { publicEnv } = await import("@/lib/env");
    expect(publicEnv).toHaveProperty("NEXT_PUBLIC_SUPABASE_URL");
    expect(publicEnv).toHaveProperty("NEXT_PUBLIC_SUPABASE_ANON_KEY");
    expect(typeof publicEnv.NEXT_PUBLIC_SUPABASE_URL).toBe("string");
    expect(typeof publicEnv.NEXT_PUBLIC_SUPABASE_ANON_KEY).toBe("string");
  });

  it("serverEnv exposes all required server-only keys", async () => {
    const { serverEnv } = await import("@/lib/env");
    expect(serverEnv).toHaveProperty("SUPABASE_SERVICE_ROLE_KEY");
    expect(serverEnv).toHaveProperty("DATABASE_URL");
    expect(serverEnv).toHaveProperty("NEXT_PUBLIC_SUPABASE_URL");
    expect(serverEnv).toHaveProperty("NEXT_PUBLIC_SUPABASE_ANON_KEY");
  });

  it("serverEnv optional keys are undefined when not set", async () => {
    const { serverEnv } = await import("@/lib/env");
    // None of the optional keys were stubbed, so they should be undefined
    expect(serverEnv.ANTHROPIC_API_KEY).toBeUndefined();
    expect(serverEnv.STRIPE_SECRET_KEY).toBeUndefined();
    expect(serverEnv.STRIPE_WEBHOOK_SECRET).toBeUndefined();
    expect(serverEnv.SCREENING_VENDOR_API_KEY).toBeUndefined();
    expect(serverEnv.ESIGN_VENDOR_API_KEY).toBeUndefined();
  });
});
