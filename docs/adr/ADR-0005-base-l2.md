# ADR-0005 — Base (EVM L2) for Settlement; Base Sepolia for Development

**Status:** Proposed · 2026-06-11

## Context
Scope directs an EVM L2 (Base/Arbitrum) for low fees + tooling, testnet-first (README §6.2). Settlement needs: cheap recurring transfers (rent), strong USDC-class stablecoin liquidity, mature 4337 infrastructure, credible operator.

## Decision
Base mainnet for production settlement; Base Sepolia for dev/staging. Contracts written chain-agnostically (no Base-specific opcodes/precompiles) so migration or multi-chain via CCIP remains open.

## Consequences
- (+) Deep native stablecoin liquidity and first-class paymaster/4337 support; lowest-friction fiat on-ramp ecosystem; Coinbase-adjacent regulatory posture is congruent with this product's compliance-first stance.
- (−) **Centralized sequencer** today: outages and censorship are real risks (TR-08). Mitigations: obligations never legally depend on chain liveness (Q6-1), L1 force-inclusion exists as slow escape hatch, DEFERRED_CHAIN saga states, dual rails (ADR-0018).
- (−) Single-chain concentration — acceptable at MVP; CCIP keeps the exit open.

## Alternatives
Arbitrum — close second (more decentralization progress, similar tooling); revisit trigger: Base sequencer-decentralization roadmap slippage or fee regime change. Permissioned chain — addressed separately in ADR-0011 (it solves privacy, not settlement, and sacrifices stablecoin liquidity — a regulated stablecoin on a private chain has no native issuance there).
