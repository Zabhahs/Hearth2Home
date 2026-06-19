# Module: Screening

## Responsibility (ARC-05 §5.2 — KYC & Screening Orchestration)

Orchestrates the FCRA-compliant tenant-screening workflow. The module does not run the consumer report itself; it manages the vendor-led, tenant-initiated flow (SmartMove-class CRA) in which the tenant consents directly with the CRA and the CRA delivers the report. The module stores verdicts (approve / conditional / deny) and the reason codes required for adverse-action notices, but stores raw report data only where strictly unavoidable. It owns the adverse-action letter generation and delivery-tracking workflow (C-L6, ANL-02 G-01).

## MVP Scope (PLN-01 Week 2)

Integration with one FCRA-compliant screening vendor (vendor TBD — account opened Day 1). Tenant-initiated consent flow. Webhook receiver for report-ready events. Adverse-action letter generation from attorney-reviewed template, with delivery tracking. Verdict stored against the application record. KYC vendor integration (Persona/Alloy-class) deferred — processor-connect onboarding covers payout-side identity at MVP.
