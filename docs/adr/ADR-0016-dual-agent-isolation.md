# ADR-0016 — Dual-Agent Information Barrier ("Designated Agency" Analogue)

**Status:** Accepted · 2026-06-11

## Context
Both negotiating AI agents are operated by the same platform (README §3.1). In brokerage terms this resembles **designated agency** — one firm, two designated agents, mandatory information barriers. Without architectural isolation: (a) one party's confidential limits (max budget, reservation rent) could leak into the other agent's context — a fiduciary breach and product-killing trust failure; (b) a prompt-injection by one party could steer the other party's agent (TR-01).

## Decision
- One **isolated agent context per party per transaction**: separate conversation state, separate memory, no shared scratchpads.
- **Per-party secret vaults** (budgets, guardrails, strategies) readable only by that party's agent runtime; access logged.
- Cross-agent communication happens **only via the Negotiation Orchestrator** as schema-validated term-sheet deltas; free-form text never crosses the barrier; counterparty-authored content is sanitized and wrapped as data.
- The platform discloses the dual-representation model to both parties (consistent with designated-agency disclosure norms; broker-of-record supervises both sides).

## Consequences
- (+) Leakage is structurally prevented, not policy-prevented; the disclosure story is legible to regulators and users.
- (+) Injection blast radius is contained to the attacker's own agent (TR-01 mitigation).
- (−) Agents negotiate with less context than a human dual agent would have — acceptable; that is what the human approval gates are for.
- (−) Two model contexts per negotiation ≈ 2× inference cost — negligible per ARC-10 cost envelope.

## Alternatives
Single mediator agent representing both sides — rejected: irreducible conflict of interest, no clean fiduciary story, single injection surface affecting both parties.
