# ADR-0011 — Listing/Bid Privacy via Salted Commit-Reveal on the Public L2

**Status:** Proposed — founder decision required (README Open Item 3 / R-02, exposure 16) · 2026-06-11

## Context
Founder direction puts listings and bids on-chain (Module C, both "S"); public chains leak pricing/negotiation data that erodes the AI-matching moat (R-02). README offers two mitigations: permissioned chain or commit-reveal.

## Decision (recommended)
Stay on the public L2 and store **salted commitments only**: `commit = H(payload ‖ salt128)` for listings and bids; full payloads live in PostgreSQL; reveal happens at settlement (or never, for losing bids — their salts are destroyed, permanently unlinking them: crypto-shredding). The on-chain artifact proves existence/ordering/integrity without disclosing content.

## Why over a permissioned chain
- Settlement assets live on the public L2: regulated stablecoins issue there, custody and 4337 infrastructure are there. A permissioned chain would split the system across two chains and forfeit the credibly-neutral timestamping that makes on-chain listings worth anything.
- Commit-reveal preserves the founder's intent (listings/bids are on-chain facts) while neutralizing the leak.

## Consequences
- (+) R-02 mitigated without forking the chain strategy; Q4-2/Q4-3 satisfied.
- (+) Losing bidders' data is never revealed.
- (−) Commitments are opaque to third parties until reveal — "open marketplace on-chain" optics are reduced (this is the point, but it trades against any narrative that raw listings are publicly readable on-chain).
- (−) Salt management becomes critical material (DSN-01 retention class; loss of salt = unprovable commitment).

## Alternatives
Permissioned/consortium chain — rejected as recommendation (above); remains the fallback if the founder wants richer on-chain data visible to permissioned parties. Plain public listings — rejected: R-02 at full exposure.

**Decision gate:** founder sign-off at or before Phase-1 gate; both options are implementable behind the same commitment interface.
