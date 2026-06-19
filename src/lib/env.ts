/**
 * Validated environment loader.
 *
 * - `serverEnv`  — server-only vars (never sent to the browser). Import only
 *   in Server Components, Route Handlers, Server Actions, and lib files that
 *   are exclusively server-side.
 * - `publicEnv`  — NEXT_PUBLIC_* vars (safe for the browser). Can be imported
 *   anywhere.
 *
 * Both objects throw at import time if a required variable is missing or
 * malformed, giving a clear error message instead of a silent `undefined`.
 */
import { z } from "zod";

// ---------------------------------------------------------------------------
// Public schema (NEXT_PUBLIC_* — available in browser bundles)
// ---------------------------------------------------------------------------
const publicSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.string().url({ message: "NEXT_PUBLIC_SUPABASE_URL must be a valid URL" }),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1, { message: "NEXT_PUBLIC_SUPABASE_ANON_KEY is required" }),
});

// ---------------------------------------------------------------------------
// Server schema (never shipped to the browser)
// ---------------------------------------------------------------------------
const serverSchema = publicSchema.extend({
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1, { message: "SUPABASE_SERVICE_ROLE_KEY is required" }),
  DATABASE_URL: z.string().url({ message: "DATABASE_URL must be a valid PostgreSQL connection string" }),
  // Optional vars — present only when the relevant integration is configured.
  ANTHROPIC_API_KEY: z.string().min(1).optional(),
  SCREENING_VENDOR_API_KEY: z.string().min(1).optional(),
  ESIGN_VENDOR_API_KEY: z.string().min(1).optional(),
  STRIPE_SECRET_KEY: z.string().min(1).optional(),
  STRIPE_WEBHOOK_SECRET: z.string().min(1).optional(),
});

// ---------------------------------------------------------------------------
// Parsed exports
// ---------------------------------------------------------------------------

/**
 * Public (NEXT_PUBLIC_*) environment variables, validated.
 * Safe to use in Client Components.
 */
export const publicEnv = publicSchema.parse({
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
});

/**
 * Server-only environment variables, validated.
 * Do NOT import this in Client Components or any file that ships to the browser.
 */
export const serverEnv = serverSchema.parse({
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
  DATABASE_URL: process.env.DATABASE_URL,
  ANTHROPIC_API_KEY: process.env.ANTHROPIC_API_KEY,
  SCREENING_VENDOR_API_KEY: process.env.SCREENING_VENDOR_API_KEY,
  ESIGN_VENDOR_API_KEY: process.env.ESIGN_VENDOR_API_KEY,
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET,
});

export type PublicEnv = z.infer<typeof publicSchema>;
export type ServerEnv = z.infer<typeof serverSchema>;
