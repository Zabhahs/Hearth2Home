/**
 * Supabase browser client factory.
 *
 * Use this in Client Components ("use client").
 * Creates a singleton per browser tab that stores the session in cookies so
 * Server Components can read it without a round-trip.
 *
 * @see https://supabase.com/docs/guides/auth/server-side/nextjs
 */
"use client";

import { createBrowserClient } from "@supabase/ssr";

export function createSupabaseBrowserClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
