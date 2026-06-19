# ADR-0014 — Immutable EscrowVault; Upgradeable Periphery Behind Timelock + Multisig

**Status:** Proposed (refines README §6.2 "upgradeable proxy pattern with timelock") · 2026-06-11

## Context
The scope prescribes upgradeable proxies with timelock for contracts generally. But an upgradeable contract that *holds funds* concentrates custody risk in the upgrade key: whoever can upgrade the vault can, after the timelock, redirect everyone's escrow. For a platform whose #2 quality goal is fund safety and whose pitch is trust-through-transparency, that is the wrong default.

## Decision
- **EscrowVault: immutable.** Minimal logic: hold ERC-20 balances per agreement; release only to the agreement's predefined party set per authorized instructions; pause stops new operations but never blocks party-withdrawal paths (Q2-3). If vault logic must change, deploy V2 and migrate agreements opt-in/at-renewal.
- **Periphery (LeaseRegistry, MilestoneRegistry, PaymentRouter, governance hooks): upgradeable** behind a 3-of-5 multisig + ≥ 48 h public timelock, with monitored upgrade announcements (Q2-5).
- The vault's authorization surface (which periphery may instruct it) is set at agreement creation and bounded — a periphery upgrade cannot retroactively widen an existing agreement's destination set.

## Consequences
- (+) "Even we can't redirect your escrow" is provable — strongest possible trust statement; smaller audit scope on the kernel.
- (−) Vault bugs require migration, not patching — hence the heaviest fuzzing/invariant/audit investment lands exactly there (ARC-08 §8.8).
- (−) Slightly more complex periphery↔vault interface (explicit authorization binding per agreement).

## Alternatives
Everything upgradeable (scope's default) — rejected for the vault: converts a code-risk into a custody-risk. Everything immutable — rejected: periphery iterates with product (jurisdiction logic, issuer lists).
