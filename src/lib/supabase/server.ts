/**
 * Supabase server client factory.
 *
 * Use this in Server Components, Route Handlers, and Server Actions.
 * Reads and writes auth cookies via the Next.js `cookies()` API so that the
 * user's session is available server-side without a full-page reload.
 *
 * @see https://supabase.com/docs/guides/auth/server-side/nextjs
 */
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { serverEnv } from "@/lib/env";

export async function createSupabaseServerClient() {
  const cookieStore = await cookies();

  return createServerClient(serverEnv.NEXT_PUBLIC_SUPABASE_URL, serverEnv.NEXT_PUBLIC_SUPABASE_ANON_KEY, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options),
          );
        } catch {
          // setAll called from a Server Component — cookies are read-only there.
          // Auth middleware handles refresh in that case.
        }
      },
    },
  });
}

/** Service-role client for privileged server-side operations.
 *  NEVER expose or use in client code. Bypasses RLS. */
export async function createSupabaseServiceClient() {
  const cookieStore = await cookies();

  return createServerClient(
    serverEnv.NEXT_PUBLIC_SUPABASE_URL,
    serverEnv.SUPABASE_SERVICE_ROLE_KEY,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // read-only context — see above
          }
        },
      },
    },
  );
}
