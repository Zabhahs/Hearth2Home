# Module: Payments

## Responsibility (ARC-05 §5.2 — Payments & Escrow Orchestrator)

Saga manager for the full payment lifecycle: ACH rent autopay authorisation, monthly rent runs, deposit documentation (amount / holding-location / statutory timers), disbursement, dunning, and late-fee computation. The Rail Router chooses between ACH and (future) stablecoin rails per state ruleset; it never silently switches rails mid-obligation. An internal double-entry ledger is the platform's accounting truth. The module operates on a PayFac-partner model (Stripe Connect-class): tenant ACH debits settle directly to the landlord's connected account — the platform never holds funds (PLN-01 §2, TR-03 / G-03 avoidance). Deposit amounts and locations are recorded here; deposits are never held by the platform (G-02 avoidance).

## MVP Scope (PLN-01 Week 3–4)

NACHA ACH authorisation UX (Reg E mandate). Rent-schedule creation tied to a signed lease. Monthly rent-run saga with retry and dunning. Jurisdiction-aware late-fee math via Compliance module. Statutory-notice generation for late payment. Deposit documentation (amount, landlord-held location, move-out deadline). Move-in condition report photo upload with both-party acknowledgment. Stablecoin rail, earnest-money escrow, and on-chain LeaseRegistry deferred to Increment 1b.
