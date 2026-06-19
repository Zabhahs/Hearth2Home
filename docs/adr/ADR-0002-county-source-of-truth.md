# ADR-0002 — County Recorder Remains Legal Source of Truth

**Status:** Founder-directed (resolves README R-01) · 2026-06-11

## Context
Raw immutability is a liability in title: fraud must be judicially reversible (README §2A.1). No US state currently makes a chain the legal source of title; Vermont/Arizona/Wyoming/Ohio statutes grant recognition/admissibility only.

## Decision
The county record is authoritative for ownership. On-chain, the platform stores only: (a) a **DeedReference NFT** pointing to the recorded instrument (county ID, instrument number, document hash) and (b) oracle-mirrored county status, labeled non-authoritative. The platform owns the *pipeline*; recording is its automated last step (e-recording via PRIA vendors where available).

## Consequences
- (+) No change of law required; fraud reversibility preserved; R-01 exposure (15) mitigated.
- (+) Clear investor/regulator narrative (Path 2 now, Path 1 as policy program).
- (−) The NFT has no legal force — every UI/document must say so explicitly (disclosure duty, see DSN-06).
- (−) Mirror data can go stale; oracle reads carry freshness metadata and the UI shows "as of" timestamps.

## Alternatives
On-chain title (Path 1) now — rejected: legally impossible today; pursued as legislative program (README §11).
