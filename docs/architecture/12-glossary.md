# ARC-12 — Glossary

| | |
|---|---|
| **Doc ID** | ARC-12 · arc42 §12 |
| **Version** | 0.1.0-draft · 2026-06-11 |

| Term | Meaning here |
|---|---|
| **Path 1 / Path 2** | README §2A: Path 2 (MVP) = platform owns the pipeline, county records the deed; Path 1 (vision) = on-chain records gain recognized legal authority via legislation |
| **GENIUS Act** | Federal framework for payment stablecoins (signed 2025-07-18); basis for using regulated stablecoins as settlement; full regime phases in (C-L3) |
| **CLARITY Act** | Pending market-structure legislation governing token models; its non-passage is why no native token exists in this design |
| **Trust kernel** | The minimal on-chain contract set holding funds and attested events (ADR-0004) |
| **Term-sheet delta** | Structured negotiation message (field changes against a clause library) exchanged between AI agents — never free-form text |
| **Information barrier** | Isolation between the two party agents; analogous to *designated agency* in brokerage, where one firm represents both sides via separated agents |
| **Guardrail proxy** | Deterministic pre/post filter wrapping every model call; enforces the feature allowlist and output bounds (ADR-0009) |
| **Allowlisted feature schema** | The closed set of lawful matching/negotiation features; anything not listed cannot enter scoring (fair-housing firewall) |
| **Paired-profile testing** | Bias audit: synthetic applicants identical except protected attribute; outcome deltas must be below threshold |
| **Commit-reveal** | Publishing a salted hash (commitment) on-chain now, revealing the value at settlement — bid privacy on a public chain (ADR-0011) |
| **Crypto-shredding** | Destroying an off-chain salt/key so an immutable on-chain commitment becomes permanently unlinkable — deletion despite immutability |
| **Session key** | Scoped, time-boxed signing authority on an ERC-4337 smart account (amount/payee/frequency-bounded) used for rent collection (ADR-0017) |
| **ERC-4337 / account abstraction** | Smart-contract wallets enabling custodial UX, sponsored gas (paymaster), and session keys without users handling seed phrases |
| **Paymaster** | Contract sponsoring users' gas so they never hold the chain's native token |
| **Custody Variant A / B** | A = platform custodies user funds (needs licensing analysis); B = licensed partner custodies, platform orchestrates (default) (ADR-0007) |
| **DON** | Decentralized Oracle Network (Chainlink); executes Functions jobs and CCIP messaging |
| **N-of-M attestation** | Milestone accepted only when N of M independent attesters agree; disagreement escalates to humans |
| **Transactional outbox** | Pattern: DB change + outgoing message committed atomically, then dispatched with retries — exactly-once-ish integration |
| **Saga** | Long-running business transaction as a sequence of compensable steps with durable state |
| **Finality policy** | Confirmation depth/state required before funds-bearing logic treats a chain event as real (ARC-08 §8.4) |
| **WORM** | Write-once-read-many storage (S3 Object Lock) for executed documents and evidence |
| **FCRA** | Fair Credit Reporting Act — governs tenant screening reports; triggers adverse-action notice duties |
| **Adverse action** | Declining/raising terms based on a consumer report → mandatory notice with CRA details and dispute rights |
| **RON** | Remote Online Notarization — state-dependent; required for fully-remote closings (Phase 2) |
| **PRIA** | Property Records Industry Association — standards used by e-recording vendors |
| **Good funds** | State rules on which cleared-funds types an escrow may disburse at closing |
| **Broker-of-record** | Licensed real-estate principal supervising regulated platform activity (R-04 control) |
| **Ruleset** | Versioned, attorney-approved per-state compliance parameter pack (ADR-0013) |
| **Connector** | Signed, versioned partner integration artifact executing in the sandboxed host (DSN-03) |
| **Canonical event** | Normalized schema all external events map to before touching business or contract logic |
| **DEFERRED_CHAIN** | Saga state: obligation tracked off-chain while chain settlement is unavailable (Q6-1) |
