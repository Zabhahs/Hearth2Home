export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      condition_reports: {
        Row: {
          created_at: string
          document_id: string | null
          id: string
          landlord_acknowledged_at: string | null
          landlord_party_id: string | null
          lease_id: string
          observations: Json
          org_id: string
          report_type: string
          status: string
          tenant_acknowledged_at: string | null
          tenant_party_id: string | null
          unit_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          document_id?: string | null
          id?: string
          landlord_acknowledged_at?: string | null
          landlord_party_id?: string | null
          lease_id: string
          observations?: Json
          org_id: string
          report_type: string
          status?: string
          tenant_acknowledged_at?: string | null
          tenant_party_id?: string | null
          unit_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          document_id?: string | null
          id?: string
          landlord_acknowledged_at?: string | null
          landlord_party_id?: string | null
          lease_id?: string
          observations?: Json
          org_id?: string
          report_type?: string
          status?: string
          tenant_acknowledged_at?: string | null
          tenant_party_id?: string | null
          unit_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "condition_reports_document_id_fkey"
            columns: ["document_id"]
            isOneToOne: false
            referencedRelation: "documents"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "condition_reports_landlord_party_id_fkey"
            columns: ["landlord_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "condition_reports_lease_id_fkey"
            columns: ["lease_id"]
            isOneToOne: false
            referencedRelation: "leases"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "condition_reports_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "condition_reports_tenant_party_id_fkey"
            columns: ["tenant_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "condition_reports_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units"
            referencedColumns: ["id"]
          },
        ]
      }
      deposit_records: {
        Row: {
          amount_cents: number
          collected_at: string | null
          created_at: string
          currency_code: string
          deductions: Json
          holding_account_last4: string | null
          holding_institution: string | null
          id: string
          is_legal_hold: boolean
          itemization_document_id: string | null
          landlord_party_id: string
          lease_id: string
          move_out_date: string | null
          org_id: string
          refunded_amount_cents: number | null
          refunded_at: string | null
          return_deadline_date: string | null
          ruleset_version_id: string | null
          status: string
          tenant_party_id: string
          updated_at: string
        }
        Insert: {
          amount_cents: number
          collected_at?: string | null
          created_at?: string
          currency_code?: string
          deductions?: Json
          holding_account_last4?: string | null
          holding_institution?: string | null
          id?: string
          is_legal_hold?: boolean
          itemization_document_id?: string | null
          landlord_party_id: string
          lease_id: string
          move_out_date?: string | null
          org_id: string
          refunded_amount_cents?: number | null
          refunded_at?: string | null
          return_deadline_date?: string | null
          ruleset_version_id?: string | null
          status?: string
          tenant_party_id: string
          updated_at?: string
        }
        Update: {
          amount_cents?: number
          collected_at?: string | null
          created_at?: string
          currency_code?: string
          deductions?: Json
          holding_account_last4?: string | null
          holding_institution?: string | null
          id?: string
          is_legal_hold?: boolean
          itemization_document_id?: string | null
          landlord_party_id?: string
          lease_id?: string
          move_out_date?: string | null
          org_id?: string
          refunded_amount_cents?: number | null
          refunded_at?: string | null
          return_deadline_date?: string | null
          ruleset_version_id?: string | null
          status?: string
          tenant_party_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "deposit_records_itemization_document_id_fkey"
            columns: ["itemization_document_id"]
            isOneToOne: false
            referencedRelation: "documents"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "deposit_records_landlord_party_id_fkey"
            columns: ["landlord_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "deposit_records_lease_id_fkey"
            columns: ["lease_id"]
            isOneToOne: true
            referencedRelation: "leases"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "deposit_records_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "deposit_records_tenant_party_id_fkey"
            columns: ["tenant_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_deposit_records_ruleset_version"
            columns: ["ruleset_version_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
        ]
      }
      documents: {
        Row: {
          content_sha256: string
          created_at: string
          created_by_party_id: string | null
          doc_type: string
          esign_evidence_ref: string | null
          file_size_bytes: number | null
          id: string
          is_legal_hold: boolean
          lease_id: string | null
          mime_type: string
          org_id: string
          retain_until: string | null
          ruleset_version_id: string | null
          template_version: string | null
          worm_storage_uri: string
        }
        Insert: {
          content_sha256: string
          created_at?: string
          created_by_party_id?: string | null
          doc_type: string
          esign_evidence_ref?: string | null
          file_size_bytes?: number | null
          id?: string
          is_legal_hold?: boolean
          lease_id?: string | null
          mime_type?: string
          org_id: string
          retain_until?: string | null
          ruleset_version_id?: string | null
          template_version?: string | null
          worm_storage_uri: string
        }
        Update: {
          content_sha256?: string
          created_at?: string
          created_by_party_id?: string | null
          doc_type?: string
          esign_evidence_ref?: string | null
          file_size_bytes?: number | null
          id?: string
          is_legal_hold?: boolean
          lease_id?: string | null
          mime_type?: string
          org_id?: string
          retain_until?: string | null
          ruleset_version_id?: string | null
          template_version?: string | null
          worm_storage_uri?: string
        }
        Relationships: [
          {
            foreignKeyName: "documents_created_by_party_id_fkey"
            columns: ["created_by_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documents_lease_id_fkey"
            columns: ["lease_id"]
            isOneToOne: false
            referencedRelation: "leases"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documents_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_documents_ruleset_version"
            columns: ["ruleset_version_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
        ]
      }
      intake_profiles: {
        Row: {
          created_at: string
          desired_amenities: Json
          desired_lat: number | null
          desired_lease_term_months: number | null
          desired_lng: number | null
          desired_move_in_date: string | null
          desired_radius_km: number | null
          gross_monthly_income_cents: number | null
          id: string
          intake_schema_version: string | null
          max_monthly_rent_cents: number | null
          min_bathrooms: number | null
          min_bedrooms: number | null
          party_id: string
          stated_credit_band: string | null
          status: string
          style_extraction_consented_at: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          desired_amenities?: Json
          desired_lat?: number | null
          desired_lease_term_months?: number | null
          desired_lng?: number | null
          desired_move_in_date?: string | null
          desired_radius_km?: number | null
          gross_monthly_income_cents?: number | null
          id?: string
          intake_schema_version?: string | null
          max_monthly_rent_cents?: number | null
          min_bathrooms?: number | null
          min_bedrooms?: number | null
          party_id: string
          stated_credit_band?: string | null
          status?: string
          style_extraction_consented_at?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          desired_amenities?: Json
          desired_lat?: number | null
          desired_lease_term_months?: number | null
          desired_lng?: number | null
          desired_move_in_date?: string | null
          desired_radius_km?: number | null
          gross_monthly_income_cents?: number | null
          id?: string
          intake_schema_version?: string | null
          max_monthly_rent_cents?: number | null
          min_bathrooms?: number | null
          min_bedrooms?: number | null
          party_id?: string
          stated_credit_band?: string | null
          status?: string
          style_extraction_consented_at?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "intake_profiles_party_id_fkey"
            columns: ["party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
        ]
      }
      jurisdiction_rulesets: {
        Row: {
          attorney_party_id: string | null
          attorney_sign_off_at: string | null
          attorney_sign_off_notes: string | null
          change_summary: string | null
          created_at: string
          effective_from: string
          effective_until: string | null
          id: string
          jurisdiction_code: string
          jurisdiction_name: string
          jurisdiction_type: string
          overlay_for_ruleset_id: string | null
          parameters: Json
          ruleset_version: string
          updated_at: string
          workflow_status: string
        }
        Insert: {
          attorney_party_id?: string | null
          attorney_sign_off_at?: string | null
          attorney_sign_off_notes?: string | null
          change_summary?: string | null
          created_at?: string
          effective_from: string
          effective_until?: string | null
          id?: string
          jurisdiction_code: string
          jurisdiction_name: string
          jurisdiction_type: string
          overlay_for_ruleset_id?: string | null
          parameters?: Json
          ruleset_version: string
          updated_at?: string
          workflow_status?: string
        }
        Update: {
          attorney_party_id?: string | null
          attorney_sign_off_at?: string | null
          attorney_sign_off_notes?: string | null
          change_summary?: string | null
          created_at?: string
          effective_from?: string
          effective_until?: string | null
          id?: string
          jurisdiction_code?: string
          jurisdiction_name?: string
          jurisdiction_type?: string
          overlay_for_ruleset_id?: string | null
          parameters?: Json
          ruleset_version?: string
          updated_at?: string
          workflow_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "jurisdiction_rulesets_attorney_party_id_fkey"
            columns: ["attorney_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "jurisdiction_rulesets_overlay_for_ruleset_id_fkey"
            columns: ["overlay_for_ruleset_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
        ]
      }
      leases: {
        Row: {
          created_at: string
          currency_code: string
          deposit_amount_cents: number | null
          esign_envelope_ref: string | null
          executed_at: string | null
          executed_document_id: string | null
          id: string
          landlord_party_id: string
          lease_end_date: string
          lease_start_date: string
          lease_term_months: number
          monthly_rent_cents: number
          negotiation_id: string | null
          org_id: string
          ruleset_version_id: string | null
          status: string
          tenant_party_id: string
          unit_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency_code?: string
          deposit_amount_cents?: number | null
          esign_envelope_ref?: string | null
          executed_at?: string | null
          executed_document_id?: string | null
          id?: string
          landlord_party_id: string
          lease_end_date: string
          lease_start_date: string
          lease_term_months: number
          monthly_rent_cents: number
          negotiation_id?: string | null
          org_id: string
          ruleset_version_id?: string | null
          status?: string
          tenant_party_id: string
          unit_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency_code?: string
          deposit_amount_cents?: number | null
          esign_envelope_ref?: string | null
          executed_at?: string | null
          executed_document_id?: string | null
          id?: string
          landlord_party_id?: string
          lease_end_date?: string
          lease_start_date?: string
          lease_term_months?: number
          monthly_rent_cents?: number
          negotiation_id?: string | null
          org_id?: string
          ruleset_version_id?: string | null
          status?: string
          tenant_party_id?: string
          unit_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_leases_executed_document"
            columns: ["executed_document_id"]
            isOneToOne: false
            referencedRelation: "documents"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_leases_ruleset_version"
            columns: ["ruleset_version_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leases_landlord_party_id_fkey"
            columns: ["landlord_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leases_negotiation_id_fkey"
            columns: ["negotiation_id"]
            isOneToOne: false
            referencedRelation: "negotiations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leases_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leases_tenant_party_id_fkey"
            columns: ["tenant_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leases_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units"
            referencedColumns: ["id"]
          },
        ]
      }
      listings: {
        Row: {
          available_date: string
          closed_at: string | null
          created_at: string
          currency_code: string
          deposit_amount_cents: number | null
          id: string
          is_deleted: boolean
          lease_term_months: number
          listing_copy_body: string | null
          listing_copy_title: string | null
          monthly_rent_cents: number
          org_id: string
          photos: Json
          published_at: string | null
          ruleset_version_id: string | null
          status: string
          unit_id: string
          updated_at: string
        }
        Insert: {
          available_date: string
          closed_at?: string | null
          created_at?: string
          currency_code?: string
          deposit_amount_cents?: number | null
          id?: string
          is_deleted?: boolean
          lease_term_months: number
          listing_copy_body?: string | null
          listing_copy_title?: string | null
          monthly_rent_cents: number
          org_id: string
          photos?: Json
          published_at?: string | null
          ruleset_version_id?: string | null
          status?: string
          unit_id: string
          updated_at?: string
        }
        Update: {
          available_date?: string
          closed_at?: string | null
          created_at?: string
          currency_code?: string
          deposit_amount_cents?: number | null
          id?: string
          is_deleted?: boolean
          lease_term_months?: number
          listing_copy_body?: string | null
          listing_copy_title?: string | null
          monthly_rent_cents?: number
          org_id?: string
          photos?: Json
          published_at?: string | null
          ruleset_version_id?: string | null
          status?: string
          unit_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_listings_ruleset_version"
            columns: ["ruleset_version_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units"
            referencedColumns: ["id"]
          },
        ]
      }
      match_candidates: {
        Row: {
          created_at: string
          feature_contributions: Json
          id: string
          intake_profile_id: string
          listing_id: string
          org_id: string
          presented_at: string | null
          score: number
          scoring_version: string
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          feature_contributions?: Json
          id?: string
          intake_profile_id: string
          listing_id: string
          org_id: string
          presented_at?: string | null
          score: number
          scoring_version: string
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          feature_contributions?: Json
          id?: string
          intake_profile_id?: string
          listing_id?: string
          org_id?: string
          presented_at?: string | null
          score?: number
          scoring_version?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "match_candidates_intake_profile_id_fkey"
            columns: ["intake_profile_id"]
            isOneToOne: false
            referencedRelation: "intake_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "match_candidates_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "match_candidates_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      negotiations: {
        Row: {
          closed_at: string | null
          created_at: string
          id: string
          landlord_party_id: string
          listing_id: string
          match_candidate_id: string
          opened_at: string
          org_id: string
          ruleset_version_id: string | null
          status: string
          tenant_party_id: string
          updated_at: string
        }
        Insert: {
          closed_at?: string | null
          created_at?: string
          id?: string
          landlord_party_id: string
          listing_id: string
          match_candidate_id: string
          opened_at?: string
          org_id: string
          ruleset_version_id?: string | null
          status?: string
          tenant_party_id: string
          updated_at?: string
        }
        Update: {
          closed_at?: string | null
          created_at?: string
          id?: string
          landlord_party_id?: string
          listing_id?: string
          match_candidate_id?: string
          opened_at?: string
          org_id?: string
          ruleset_version_id?: string | null
          status?: string
          tenant_party_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_negotiations_ruleset_version"
            columns: ["ruleset_version_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "negotiations_landlord_party_id_fkey"
            columns: ["landlord_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "negotiations_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "negotiations_match_candidate_id_fkey"
            columns: ["match_candidate_id"]
            isOneToOne: false
            referencedRelation: "match_candidates"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "negotiations_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "negotiations_tenant_party_id_fkey"
            columns: ["tenant_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
        ]
      }
      org_memberships: {
        Row: {
          created_at: string
          effective_from: string
          effective_until: string | null
          id: string
          invited_by_party_id: string | null
          org_id: string
          party_id: string
          role: string
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          effective_from?: string
          effective_until?: string | null
          id?: string
          invited_by_party_id?: string | null
          org_id: string
          party_id: string
          role: string
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          effective_from?: string
          effective_until?: string | null
          id?: string
          invited_by_party_id?: string | null
          org_id?: string
          party_id?: string
          role?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "org_memberships_invited_by_party_id_fkey"
            columns: ["invited_by_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "org_memberships_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "org_memberships_party_id_fkey"
            columns: ["party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
        ]
      }
      organizations: {
        Row: {
          created_at: string
          id: string
          name: string
          primary_jurisdiction: string | null
          processor_account_ref: string | null
          slug: string
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
          primary_jurisdiction?: string | null
          processor_account_ref?: string | null
          slug: string
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
          primary_jurisdiction?: string | null
          processor_account_ref?: string | null
          slug?: string
          status?: string
          updated_at?: string
        }
        Relationships: []
      }
      parties: {
        Row: {
          auth_uid: string | null
          created_at: string
          display_name: string
          email: string
          id: string
          is_deleted: boolean
          kyc_status: string
          kyc_vendor_ref: string | null
          kyc_verified_at: string | null
          updated_at: string
        }
        Insert: {
          auth_uid?: string | null
          created_at?: string
          display_name: string
          email: string
          id?: string
          is_deleted?: boolean
          kyc_status?: string
          kyc_vendor_ref?: string | null
          kyc_verified_at?: string | null
          updated_at?: string
        }
        Update: {
          auth_uid?: string | null
          created_at?: string
          display_name?: string
          email?: string
          id?: string
          is_deleted?: boolean
          kyc_status?: string
          kyc_vendor_ref?: string | null
          kyc_verified_at?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      payment_events: {
        Row: {
          ach_return_code: string | null
          ach_trace_number: string | null
          amount_cents: number
          created_at: string
          currency_code: string
          event_type: string
          finality_status: string
          finalized_at: string | null
          id: string
          idempotency_key: string | null
          initiated_at: string
          obligation_id: string
          org_id: string
          processor_ref: string | null
          rail: string
        }
        Insert: {
          ach_return_code?: string | null
          ach_trace_number?: string | null
          amount_cents: number
          created_at?: string
          currency_code?: string
          event_type: string
          finality_status?: string
          finalized_at?: string | null
          id?: string
          idempotency_key?: string | null
          initiated_at?: string
          obligation_id: string
          org_id: string
          processor_ref?: string | null
          rail?: string
        }
        Update: {
          ach_return_code?: string | null
          ach_trace_number?: string | null
          amount_cents?: number
          created_at?: string
          currency_code?: string
          event_type?: string
          finality_status?: string
          finalized_at?: string | null
          id?: string
          idempotency_key?: string | null
          initiated_at?: string
          obligation_id?: string
          org_id?: string
          processor_ref?: string | null
          rail?: string
        }
        Relationships: [
          {
            foreignKeyName: "payment_events_obligation_id_fkey"
            columns: ["obligation_id"]
            isOneToOne: false
            referencedRelation: "payment_obligations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_events_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      payment_obligations: {
        Row: {
          amount_cents: number
          created_at: string
          currency_code: string
          due_date: string
          id: string
          idempotency_key: string | null
          lease_id: string
          nacha_authorization_ref: string | null
          obligation_type: string
          org_id: string
          payee_party_id: string
          payor_party_id: string
          ruleset_version_id: string | null
          settled_at: string | null
          settled_cents: number
          status: string
          updated_at: string
        }
        Insert: {
          amount_cents: number
          created_at?: string
          currency_code?: string
          due_date: string
          id?: string
          idempotency_key?: string | null
          lease_id: string
          nacha_authorization_ref?: string | null
          obligation_type: string
          org_id: string
          payee_party_id: string
          payor_party_id: string
          ruleset_version_id?: string | null
          settled_at?: string | null
          settled_cents?: number
          status?: string
          updated_at?: string
        }
        Update: {
          amount_cents?: number
          created_at?: string
          currency_code?: string
          due_date?: string
          id?: string
          idempotency_key?: string | null
          lease_id?: string
          nacha_authorization_ref?: string | null
          obligation_type?: string
          org_id?: string
          payee_party_id?: string
          payor_party_id?: string
          ruleset_version_id?: string | null
          settled_at?: string | null
          settled_cents?: number
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_payment_obligations_ruleset_version"
            columns: ["ruleset_version_id"]
            isOneToOne: false
            referencedRelation: "jurisdiction_rulesets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_obligations_lease_id_fkey"
            columns: ["lease_id"]
            isOneToOne: false
            referencedRelation: "leases"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_obligations_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_obligations_payee_party_id_fkey"
            columns: ["payee_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_obligations_payor_party_id_fkey"
            columns: ["payor_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
        ]
      }
      properties: {
        Row: {
          address_line1: string
          address_line2: string | null
          apn: string | null
          city: string
          country_code: string
          created_at: string
          id: string
          is_deleted: boolean
          org_id: string
          postal_code: string
          property_type: string
          state_code: string
          updated_at: string
        }
        Insert: {
          address_line1: string
          address_line2?: string | null
          apn?: string | null
          city: string
          country_code?: string
          created_at?: string
          id?: string
          is_deleted?: boolean
          org_id: string
          postal_code: string
          property_type: string
          state_code: string
          updated_at?: string
        }
        Update: {
          address_line1?: string
          address_line2?: string | null
          apn?: string | null
          city?: string
          country_code?: string
          created_at?: string
          id?: string
          is_deleted?: boolean
          org_id?: string
          postal_code?: string
          property_type?: string
          state_code?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "properties_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      screening_reports: {
        Row: {
          adverse_action_trail: Json | null
          consent_document_id: string | null
          cra_report_ref: string
          cra_vendor: string
          created_at: string
          destruction_due_at: string | null
          id: string
          is_legal_hold: boolean
          listing_id: string
          org_id: string
          permissible_purpose: Json
          report_expires_at: string | null
          subject_party_id: string
          updated_at: string
          verdict: string
        }
        Insert: {
          adverse_action_trail?: Json | null
          consent_document_id?: string | null
          cra_report_ref: string
          cra_vendor: string
          created_at?: string
          destruction_due_at?: string | null
          id?: string
          is_legal_hold?: boolean
          listing_id: string
          org_id: string
          permissible_purpose: Json
          report_expires_at?: string | null
          subject_party_id: string
          updated_at?: string
          verdict: string
        }
        Update: {
          adverse_action_trail?: Json | null
          consent_document_id?: string | null
          cra_report_ref?: string
          cra_vendor?: string
          created_at?: string
          destruction_due_at?: string | null
          id?: string
          is_legal_hold?: boolean
          listing_id?: string
          org_id?: string
          permissible_purpose?: Json
          report_expires_at?: string | null
          subject_party_id?: string
          updated_at?: string
          verdict?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_screening_consent_document"
            columns: ["consent_document_id"]
            isOneToOne: false
            referencedRelation: "documents"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "screening_reports_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "screening_reports_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "screening_reports_subject_party_id_fkey"
            columns: ["subject_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
        ]
      }
      term_sheet_versions: {
        Row: {
          additional_terms: Json
          agent_context_id: string | null
          created_at: string
          deposit_amount_cents: number | null
          guardrail_verdict: Json | null
          id: string
          lease_end_date: string
          lease_start_date: string
          lease_term_months: number
          model_version: string | null
          monthly_rent_cents: number
          negotiation_id: string
          org_id: string
          proposed_by_party_id: string
          responded_at: string | null
          responded_by_party_id: string | null
          response: string | null
          version_number: number
        }
        Insert: {
          additional_terms?: Json
          agent_context_id?: string | null
          created_at?: string
          deposit_amount_cents?: number | null
          guardrail_verdict?: Json | null
          id?: string
          lease_end_date: string
          lease_start_date: string
          lease_term_months: number
          model_version?: string | null
          monthly_rent_cents: number
          negotiation_id: string
          org_id: string
          proposed_by_party_id: string
          responded_at?: string | null
          responded_by_party_id?: string | null
          response?: string | null
          version_number: number
        }
        Update: {
          additional_terms?: Json
          agent_context_id?: string | null
          created_at?: string
          deposit_amount_cents?: number | null
          guardrail_verdict?: Json | null
          id?: string
          lease_end_date?: string
          lease_start_date?: string
          lease_term_months?: number
          model_version?: string | null
          monthly_rent_cents?: number
          negotiation_id?: string
          org_id?: string
          proposed_by_party_id?: string
          responded_at?: string | null
          responded_by_party_id?: string | null
          response?: string | null
          version_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "term_sheet_versions_negotiation_id_fkey"
            columns: ["negotiation_id"]
            isOneToOne: false
            referencedRelation: "negotiations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "term_sheet_versions_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "term_sheet_versions_proposed_by_party_id_fkey"
            columns: ["proposed_by_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "term_sheet_versions_responded_by_party_id_fkey"
            columns: ["responded_by_party_id"]
            isOneToOne: false
            referencedRelation: "parties"
            referencedColumns: ["id"]
          },
        ]
      }
      units: {
        Row: {
          amenities: Json
          bathrooms: number
          bedrooms: number
          created_at: string
          id: string
          is_deleted: boolean
          org_id: string
          property_id: string
          square_feet: number | null
          status: string
          unit_number: string
          updated_at: string
        }
        Insert: {
          amenities?: Json
          bathrooms: number
          bedrooms: number
          created_at?: string
          id?: string
          is_deleted?: boolean
          org_id: string
          property_id: string
          square_feet?: number | null
          status?: string
          unit_number: string
          updated_at?: string
        }
        Update: {
          amenities?: Json
          bathrooms?: number
          bedrooms?: number
          created_at?: string
          id?: string
          is_deleted?: boolean
          org_id?: string
          property_id?: string
          square_feet?: number | null
          status?: string
          unit_number?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "units_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "units_property_id_fkey"
            columns: ["property_id"]
            isOneToOne: false
            referencedRelation: "properties"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      is_org_member: {
        Args: { p_org_id: string; p_roles?: string[] }
        Returns: boolean
      }
      is_party_self: { Args: { p_party_id: string }; Returns: boolean }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
