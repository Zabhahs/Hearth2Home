# Hearth2Home — Developer Quick-Start

AI-powered leasing and rent automation for self-managing landlords.
See `docs/planning/mvp-30-day.md` (PLN-01) for the full 30-day build plan
and `docs/architecture/05-building-block-view.md` (ARC-05) for module boundaries.

---

## Prerequisites

- **Node.js 24+** — `node --version` should print `v24.x.x`
- **A Supabase project** — free tier is fine for local dev
- npm (bundled with Node)

---

## 1. Install dependencies

```bash
npm install
```

---

## 2. Configure environment variables

```bash
cp .env.example .env.local
```

Open `.env.local` and fill in the four required vars:

| Variable | Where to find it |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase dashboard → Project Settings → API |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Same page — "anon / public" key |
| `SUPABASE_SERVICE_ROLE_KEY` | Same page — "service_role" key (keep secret) |
| `DATABASE_URL` | Supabase dashboard → Project Settings → Database → Connection string |

Optional vars (`ANTHROPIC_API_KEY`, `STRIPE_*`, `SCREENING_VENDOR_API_KEY`,
`ESIGN_VENDOR_API_KEY`) can be left commented out until the relevant
integrations are wired up.

---

## 3. Run the development server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) — you should see the
"Hearth2Home — coming soon" placeholder.

---

## 4. Available scripts

| Script | What it does |
|---|---|
| `npm run dev` | Next.js dev server with hot-reload |
| `npm run build` | Production build |
| `npm start` | Start the production build |
| `npm run lint` | ESLint via `next lint` |
| `npm run typecheck` | `tsc --noEmit` — type-check without emitting files |
| `npm test` | Vitest unit tests (single run) |
| `npm run test:watch` | Vitest in watch mode |
| `npm run format` | Prettier — formats all files in place |

---

## 5. Project structure

```
src/
  app/               # Next.js App Router — pages and layouts
  lib/
    env.ts           # Zod-validated env loader
    supabase/
      client.ts      # Browser Supabase client factory
      server.ts      # Server Supabase client factory (+ service-role)
    __tests__/       # Unit tests
  modules/           # ARC-05 module boundaries (skeleton only at MVP start)
    identity/        # AuthN, RBAC, orgs
    listings/        # Property and unit records
    screening/       # FCRA-compliant tenant screening
    leasing/         # Lease generation, e-sign, WORM archival
    payments/        # ACH rent autopay, deposit documentation
    compliance/      # Per-state rulesets, fair-housing guardrail
    audit/           # Hash-chained audit log
    matching/        # Tenant-side unit matching
docs/                # Architecture and planning docs — do not modify without review
```

---

## 6. Architecture notes

- **No heavy ORM.** Raw SQL migrations live in a separate migrations directory
  (to be created). Supabase's Row-Level Security (RLS) enforces data-access
  rules at the DB layer.
- **Job queue.** Background jobs (audit chain anchoring, rent runs, dunning)
  will use **graphile-worker** (documented dependency, not yet wired up). The
  `DATABASE_URL` env var is the connection it will use.
- **E2E tests.** A `playwright.config.ts` stub exists; run
  `npx playwright install --with-deps` when you're ready to write e2e tests.
  The `e2e/` directory does not exist yet.
- **Chain writes.** The daily Merkle anchor to Base is a platform-signed
  attestation (EAS-class). It involves no user funds and does not trigger
  the smart-contract audit gate (C-T3 / R-06). It is not implemented yet.
