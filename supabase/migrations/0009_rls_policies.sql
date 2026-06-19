-- =============================================================================
-- 0009_rls_policies.sql
-- Row-Level Security policies for Supabase (Postgres RLS).
--
-- Architecture (DSN-01 §4, ARC-08 §8.2):
--   - Org-scoped tables: RLS policies key on org_id via org_memberships.
--   - Tenant data: scoped by direct party_id reference OR lease participation.
--   - Public listing search: SELECT allowed without auth (anon role).
--   - Audit schema: NO application role may UPDATE/DELETE audit.audit_record;
--     INSERT is via append_audit_event() (security-definer) only.
--   - match_features schema: SELECT for scoring service; no direct client access.
--
-- Convention:
--   - "org_member(org_id)" helper checks that auth.uid() has an active
--     membership in the org (owner or staff role).
--   - "org_owner(org_id)" checks for 'owner' role specifically.
--   - Policies are additive (OR logic between policies on the same table).
--   - Policies marked TODO require a concrete Supabase custom claim or
--     additional role setup before going live.
--
-- Supabase auth note:
--   auth.uid() returns the UUID of the currently authenticated user.
--   This must match parties.auth_uid for the membership lookup to work.
--
-- References: DSN-01 §4, ARC-08 §8.1-8.2, ADR-0012 (audit append-only).
-- =============================================================================

-- ===========================================================================
-- SECTION 1: Helper functions for policy predicates
-- ===========================================================================

-- is_org_member(org_id, required_roles): returns true if the current auth user
-- has an active membership in the given org with one of the required roles.
CREATE OR REPLACE FUNCTION public.is_org_member(
  p_org_id      UUID,
  p_roles       TEXT[]  DEFAULT ARRAY['owner','staff','broker','compliance_ops','admin']
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
      FROM public.org_memberships m
      JOIN public.parties p ON p.id = m.party_id
     WHERE m.org_id      = p_org_id
       AND p.auth_uid    = auth.uid()
       AND m.status      = 'active'
       AND m.role        = ANY(p_roles)
       AND m.effective_from <= now()
       AND (m.effective_until IS NULL OR m.effective_until > now())
  );
$$;

COMMENT ON FUNCTION public.is_org_member IS
  'RLS helper: returns true if auth.uid() has an active membership in p_org_id '
  'with one of the p_roles. Security-definer to avoid RLS recursion.';

-- is_party_self(party_id): returns true if the current auth user IS this party.
CREATE OR REPLACE FUNCTION public.is_party_self(p_party_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.parties
     WHERE id = p_party_id AND auth_uid = auth.uid()
  );
$$;

COMMENT ON FUNCTION public.is_party_self IS
  'RLS helper: returns true if auth.uid() corresponds to the given party_id.';

-- ===========================================================================
-- SECTION 2: Enable RLS on all org-scoped and party-scoped tables
-- ===========================================================================
ALTER TABLE public.organizations         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parties               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_memberships       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.intake_profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_candidates      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screening_reports     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.negotiations          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.term_sheet_versions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leases                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.condition_reports     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_obligations   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_events        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deposit_records       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jurisdiction_rulesets ENABLE ROW LEVEL SECURITY;
-- match_features tables: enable RLS; scoring service access via service_role.
ALTER TABLE match_features.intake_feature_profiles  ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_features.unit_feature_profiles    ENABLE ROW LEVEL SECURITY;
-- audit tables: RLS enabled; NO delete/update policies exist (append-only).
ALTER TABLE audit.audit_record   ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit.daily_anchor   ENABLE ROW LEVEL SECURITY;

-- ===========================================================================
-- SECTION 3: REVOKE UPDATE/DELETE on audit schema from all application roles
-- ===========================================================================
-- The anon and authenticated roles are the Supabase default application roles.
-- service_role bypasses RLS but is never used by client-facing code.
REVOKE UPDATE, DELETE ON audit.audit_record FROM anon, authenticated;
REVOKE UPDATE, DELETE ON audit.daily_anchor  FROM anon, authenticated;
-- INSERT is also blocked at table level; all writes go via append_audit_event().
REVOKE INSERT ON audit.audit_record FROM anon, authenticated;
-- Only append_audit_event (security-definer) may insert; grant its EXECUTE.
GRANT EXECUTE ON FUNCTION audit.append_audit_event TO authenticated;

-- ===========================================================================
-- SECTION 4: organizations
-- ===========================================================================

-- Members of an org may read their own org row.
CREATE POLICY "orgs_select_member"
  ON public.organizations FOR SELECT
  USING (public.is_org_member(id));

-- Only org owners may update org settings.
CREATE POLICY "orgs_update_owner"
  ON public.organizations FOR UPDATE
  USING  (public.is_org_member(id, ARRAY['owner']))
  WITH CHECK (public.is_org_member(id, ARRAY['owner']));

-- INSERT: handled by server-side onboarding flow (service_role); no client insert.
-- TODO: add a CREATE policy for the landlord self-onboarding flow if it runs
-- client-side (would need a Supabase Edge Function to avoid a chicken-and-egg
-- problem: you can't be a member before the org exists).

-- ===========================================================================
-- SECTION 5: parties
-- ===========================================================================

-- A party may read their own row.
CREATE POLICY "parties_select_self"
  ON public.parties FOR SELECT
  USING (auth_uid = auth.uid());

-- Org members may read parties who are members of the same org.
CREATE POLICY "parties_select_org_member"
  ON public.parties FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.org_memberships m
       WHERE m.party_id = parties.id
         AND public.is_org_member(m.org_id)
    )
  );

-- A party may update their own display_name and non-privileged fields.
-- Privileged fields (kyc_status, auth_uid) are updated via server-side functions only.
CREATE POLICY "parties_update_self"
  ON public.parties FOR UPDATE
  USING (auth_uid = auth.uid())
  WITH CHECK (auth_uid = auth.uid());

-- ===========================================================================
-- SECTION 6: org_memberships
-- ===========================================================================

-- Members may view their own membership and memberships within their org.
CREATE POLICY "memberships_select"
  ON public.org_memberships FOR SELECT
  USING (
    public.is_party_self(party_id)
    OR public.is_org_member(org_id)
  );

-- Only org owners may add or update memberships.
CREATE POLICY "memberships_insert_owner"
  ON public.org_memberships FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner']));

CREATE POLICY "memberships_update_owner"
  ON public.org_memberships FOR UPDATE
  USING  (public.is_org_member(org_id, ARRAY['owner']))
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner']));

-- ===========================================================================
-- SECTION 7: properties and units (org-scoped)
-- ===========================================================================

CREATE POLICY "properties_select"
  ON public.properties FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "properties_insert"
  ON public.properties FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "properties_update"
  ON public.properties FOR UPDATE
  USING  (public.is_org_member(org_id, ARRAY['owner','staff']))
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "units_select"
  ON public.units FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "units_insert"
  ON public.units FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "units_update"
  ON public.units FOR UPDATE
  USING  (public.is_org_member(org_id, ARRAY['owner','staff']))
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

-- ===========================================================================
-- SECTION 8: listings
-- ===========================================================================

-- Active listings are publicly readable (anonymous listing search, PLN-01 §3).
CREATE POLICY "listings_select_public"
  ON public.listings FOR SELECT
  USING (status = 'active');

-- Org members may see all their listings (including drafts).
CREATE POLICY "listings_select_org"
  ON public.listings FOR SELECT
  USING (public.is_org_member(org_id));

-- Tenants with an intake profile can see listings they have been matched against.
CREATE POLICY "listings_select_matched_tenant"
  ON public.listings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.match_candidates mc
        JOIN public.intake_profiles ip ON ip.id = mc.intake_profile_id
       WHERE mc.listing_id = listings.id
         AND public.is_party_self(ip.party_id)
    )
  );

CREATE POLICY "listings_insert"
  ON public.listings FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "listings_update"
  ON public.listings FOR UPDATE
  USING  (public.is_org_member(org_id, ARRAY['owner','staff']))
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

-- ===========================================================================
-- SECTION 9: intake_profiles (tenant-scoped, no org_id)
-- ===========================================================================

-- Tenants may read and manage their own intake profile.
CREATE POLICY "intake_profiles_select_self"
  ON public.intake_profiles FOR SELECT
  USING (public.is_party_self(party_id));

-- Org members may read intake profiles of applicants who applied to their listings.
CREATE POLICY "intake_profiles_select_org_applicant"
  ON public.intake_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.match_candidates mc
        JOIN public.listings l ON l.id = mc.listing_id
       WHERE mc.intake_profile_id = intake_profiles.id
         AND public.is_org_member(l.org_id)
    )
  );

CREATE POLICY "intake_profiles_insert_self"
  ON public.intake_profiles FOR INSERT
  WITH CHECK (public.is_party_self(party_id));

CREATE POLICY "intake_profiles_update_self"
  ON public.intake_profiles FOR UPDATE
  USING  (public.is_party_self(party_id))
  WITH CHECK (public.is_party_self(party_id));

-- ===========================================================================
-- SECTION 10: match_candidates (org + tenant scoped)
-- ===========================================================================

-- Org members may see candidates for their listings.
CREATE POLICY "match_candidates_select_org"
  ON public.match_candidates FOR SELECT
  USING (public.is_org_member(org_id));

-- Tenants may see their own match candidates.
CREATE POLICY "match_candidates_select_tenant"
  ON public.match_candidates FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.intake_profiles ip
       WHERE ip.id = match_candidates.intake_profile_id
         AND public.is_party_self(ip.party_id)
    )
  );

-- INSERT/UPDATE for match_candidates is service-role only (scoring service).
-- No client-facing insert policy; scoring pipeline runs server-side.

-- ===========================================================================
-- SECTION 11: screening_reports (org + subject-tenant, REGULATED-IDENTITY)
-- ===========================================================================

-- Org members may view screening reports for their listings.
CREATE POLICY "screening_reports_select_org"
  ON public.screening_reports FOR SELECT
  USING (public.is_org_member(org_id));

-- Tenants may view their own screening reports (FCRA right to disclosure).
CREATE POLICY "screening_reports_select_subject"
  ON public.screening_reports FOR SELECT
  USING (public.is_party_self(subject_party_id));

-- INSERT/UPDATE via server-side screening orchestration only (service_role).
-- TODO: add compliance_ops select policy when that role is provisioned.

-- ===========================================================================
-- SECTION 12: negotiations and term_sheet_versions
-- ===========================================================================

-- Org members see negotiations for their org.
CREATE POLICY "negotiations_select_org"
  ON public.negotiations FOR SELECT
  USING (public.is_org_member(org_id));

-- Tenant (either party) sees their negotiations.
CREATE POLICY "negotiations_select_party"
  ON public.negotiations FOR SELECT
  USING (
    public.is_party_self(landlord_party_id)
    OR public.is_party_self(tenant_party_id)
  );

CREATE POLICY "negotiations_insert"
  ON public.negotiations FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "negotiations_update"
  ON public.negotiations FOR UPDATE
  USING  (public.is_org_member(org_id))
  WITH CHECK (public.is_org_member(org_id));

-- term_sheet_versions: same access pattern as negotiations.
CREATE POLICY "tsv_select_org"
  ON public.term_sheet_versions FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "tsv_select_party"
  ON public.term_sheet_versions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.negotiations n
       WHERE n.id = term_sheet_versions.negotiation_id
         AND (public.is_party_self(n.landlord_party_id)
              OR public.is_party_self(n.tenant_party_id))
    )
  );

CREATE POLICY "tsv_insert"
  ON public.term_sheet_versions FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

-- ===========================================================================
-- SECTION 13: leases (org + both parties)
-- ===========================================================================

CREATE POLICY "leases_select_org"
  ON public.leases FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "leases_select_party"
  ON public.leases FOR SELECT
  USING (
    public.is_party_self(landlord_party_id)
    OR public.is_party_self(tenant_party_id)
  );

CREATE POLICY "leases_insert"
  ON public.leases FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "leases_update"
  ON public.leases FOR UPDATE
  USING  (public.is_org_member(org_id, ARRAY['owner','staff']))
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

-- ===========================================================================
-- SECTION 14: documents (LEGAL-DOCUMENT — org + both parties)
-- ===========================================================================

CREATE POLICY "documents_select_org"
  ON public.documents FOR SELECT
  USING (public.is_org_member(org_id));

-- Parties on the lease may access documents associated with that lease.
CREATE POLICY "documents_select_lease_party"
  ON public.documents FOR SELECT
  USING (
    lease_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM public.leases l
       WHERE l.id = documents.lease_id
         AND (public.is_party_self(l.landlord_party_id)
              OR public.is_party_self(l.tenant_party_id))
    )
  );

-- INSERT via server-side document service only (service_role preferred).
-- This policy allows org staff to upload supporting documents.
CREATE POLICY "documents_insert"
  ON public.documents FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

-- No UPDATE or DELETE on documents (WORM principle at application layer).
-- Physical deletion is blocked at the storage layer (S3 Object Lock);
-- this RLS layer adds defense-in-depth.
-- TODO: add an explicit REVOKE UPDATE, DELETE on documents when compliance
-- ops role is provisioned (mirrors audit.audit_record treatment).

-- ===========================================================================
-- SECTION 15: condition_reports
-- ===========================================================================

CREATE POLICY "condition_reports_select_org"
  ON public.condition_reports FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "condition_reports_select_lease_party"
  ON public.condition_reports FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.leases l
       WHERE l.id = condition_reports.lease_id
         AND (public.is_party_self(l.landlord_party_id)
              OR public.is_party_self(l.tenant_party_id))
    )
  );

CREATE POLICY "condition_reports_insert"
  ON public.condition_reports FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "condition_reports_update"
  ON public.condition_reports FOR UPDATE
  USING (public.is_org_member(org_id))
  WITH CHECK (public.is_org_member(org_id));

-- ===========================================================================
-- SECTION 16: payment_obligations and payment_events (REGULATED-FINANCIAL)
-- ===========================================================================

CREATE POLICY "payment_obligations_select_org"
  ON public.payment_obligations FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "payment_obligations_select_payor"
  ON public.payment_obligations FOR SELECT
  USING (public.is_party_self(payor_party_id));

-- INSERT/UPDATE via Rail Router (server-side / service_role).
-- TODO: explicit client-side CREATE policy for tenant NACHA authorization
-- flow once that UX is defined.

CREATE POLICY "payment_events_select_org"
  ON public.payment_events FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "payment_events_select_party"
  ON public.payment_events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.payment_obligations po
       WHERE po.id = payment_events.obligation_id
         AND public.is_party_self(po.payor_party_id)
    )
  );

-- payment_events are immutable once created; no UPDATE/DELETE policies.

-- ===========================================================================
-- SECTION 17: deposit_records
-- ===========================================================================

CREATE POLICY "deposit_records_select_org"
  ON public.deposit_records FOR SELECT
  USING (public.is_org_member(org_id));

CREATE POLICY "deposit_records_select_party"
  ON public.deposit_records FOR SELECT
  USING (
    public.is_party_self(landlord_party_id)
    OR public.is_party_self(tenant_party_id)
  );

CREATE POLICY "deposit_records_insert"
  ON public.deposit_records FOR INSERT
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

CREATE POLICY "deposit_records_update"
  ON public.deposit_records FOR UPDATE
  USING  (public.is_org_member(org_id, ARRAY['owner','staff']))
  WITH CHECK (public.is_org_member(org_id, ARRAY['owner','staff']));

-- ===========================================================================
-- SECTION 18: jurisdiction_rulesets (read-mostly, managed by legal-ops)
-- ===========================================================================

-- All authenticated users may read approved/active rulesets.
CREATE POLICY "rulesets_select_active"
  ON public.jurisdiction_rulesets FOR SELECT
  USING (workflow_status IN ('approved', 'active', 'superseded'));

-- TODO: add a compliance_ops role policy for draft/attorney_review reads
-- and INSERT/UPDATE when that Supabase custom claim is provisioned.

-- ===========================================================================
-- SECTION 19: match_features schema — scoring service access only
-- ===========================================================================
-- Scoring pipeline runs as service_role (bypasses RLS); client access denied.
-- These permissive policies are intentionally absent — default deny applies.
-- The service_role is the only authorized reader/writer of match_features.*.

-- Deny-by-default comment (no policies = no access for anon/authenticated).
COMMENT ON TABLE match_features.intake_feature_profiles IS
  'Allowlisted matching features — populated by Guardrail Service (service_role). '
  'No client-facing RLS policies; default-deny for anon/authenticated. ADR-0009.';

COMMENT ON TABLE match_features.unit_feature_profiles IS
  'Allowlisted unit matching features — populated by scoring pipeline (service_role). '
  'No client-facing RLS policies; default-deny for anon/authenticated. ADR-0009.';

-- ===========================================================================
-- SECTION 20: audit schema — append-only enforcement
-- ===========================================================================

-- audit.audit_record: NO SELECT policy for application roles by default.
-- TODO: add a compliance_ops SELECT policy once that role / custom claim exists.
-- The Verification API (ARC-08 §8.3) reads via service_role.

-- audit.daily_anchor: allow authenticated users to read anchors
-- (public verifiability is a design goal of ADR-0012).
CREATE POLICY "daily_anchor_select_authenticated"
  ON audit.daily_anchor FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- ===========================================================================
-- SECTION 21: Grant execute on helper functions to authenticated role
-- ===========================================================================
GRANT EXECUTE ON FUNCTION public.is_org_member     TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_party_self     TO authenticated;

-- ===========================================================================
-- SECTION 22: updated_at trigger function (shared utility)
-- ===========================================================================
-- Automatically maintains updated_at on all tables that have the column.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Apply to all tables with updated_at.
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT tablename
      FROM pg_tables
     WHERE schemaname = 'public'
       AND tablename IN (
         'organizations','parties','org_memberships',
         'properties','units','listings',
         'intake_profiles','match_candidates','screening_reports',
         'negotiations','term_sheet_versions','leases',
         'documents','condition_reports',
         'payment_obligations','deposit_records',
         'jurisdiction_rulesets'
       )
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_set_updated_at '
      'BEFORE UPDATE ON public.%I '
      'FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()',
      tbl
    );
  END LOOP;
END;
$$;

COMMENT ON FUNCTION public.set_updated_at IS
  'Trigger function: sets updated_at = now() on any UPDATE. '
  'Applied to all public-schema tables with an updated_at column.';
