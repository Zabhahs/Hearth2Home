# OPS-03 — Incident Response Runbook

| | |
|---|---|
| **Doc ID** | OPS-03 |
| **Version** | 0.1.0-draft · 2026-06-19 |
| **Status** | Draft for founder review |
| **Governs** | Emergency response procedures; error taxonomy; escalation paths |
| **Companion files** | [OPS-01](autonomous-operation.md) (fleet operations) · [OPS-04](runbook-support.md) (support triage) · [OPS-05](status-page.md) (public status) · [DSN-05](../design/security-threat-model.md) (threat model) |

## 1. Error & Escalation Taxonomy

Every error falling into the categories below triggers specific actions. **Do not auto-retry across class boundaries.** The taxonomy maps to [ARC-08 §8.6](../architecture/08-crosscutting-concepts.md#86-error-handling--escalation-taxonomy).

| Class | Definition | Examples | Immediate Action | Escalation |
|---|---|---|---|---|
| **Retryable-Technical** | Transient infrastructure fault; system will likely self-heal | RPC timeout, payment processor 5xx, database connection reset, vendor API 502 | Exponential backoff with jitter (2s, 4s, 8s, 16s); max 5 retries. Saga state machine stays in the current step. | If exhausted: escalate to **Disagreement** (reconcile actual vs. expected state) |
| **Business-Rejection** | Request valid but violates business rule (guardrail, compliance, schema) | Tenant fails screening threshold, rent amount exceeds jurisdiction cap, application missing required field, offer price below landlord minimum | Return machine-readable error + detailed reason to initiator; log the decision; **do not retry**. | Log to audit trail. Notify tenant/landlord via UI. No escalation unless pattern emerges (see anomaly). |
| **Disagreement** | Observable state contradicts expected state; requires human judgment | Oracle sources disagree on property value, reconciliation finds ledger ↔ processor mismatch, blockchain reorg detected, tenant claims vs. landlord claims on condition report | **Halt the saga immediately.** Post to [INBOX.md](#inbox-escalation) with the specific discrepancy, block further automation on that entity. | Founder reviews and decides: accept one source, request third party, retry. Document the decision in audit log. |
| **Legal-Hold** | Regulatory or court action; jurisdiction or compliance requirement | Court-ordered fund freeze, issuer declares the stablecoin out of compliance, jurisdiction files a lien, licensing authority suspends the platform | **Immediately freeze all transactions involving affected parties/assets.** Notify legal counsel + founder. Enter case-management mode: no automated releases until hold lifted. | Requires counsel + founder sign-off to unfreeze. Document every action. |
| **Security** | Attack surface or trust-boundary violation detected | Failed attestation signature, unauthorized key use, anomalous rate spike (DoS indicator), webhook signature mismatch, prompt-injection pattern in user input | **Circuit-break the affected surface immediately.** Disable the exposed capability (e.g., pause e-sign, block AI agent, restrict API). Page founder. Log full context (IP, user, payload) to audit. | Founder + security checklist (§4 below). Re-enable only after root cause confirmed and fix deployed. |

---

## 2. Severity Levels & Paging Policy

**S1 (Critical)** — Platform or funds at immediate risk; service down or compromise confirmed
- *Triggers:* Active key compromise, funds moved without authorization, multi-tenant database breach, RPC/payment processor down for >30 min, contract paused/halted on-chain
- *Action:* Page founder immediately (phone + SMS + in-app). Engage on-call security (if staffed). Halt all transactions in affected scope.
- *SLA:* Founder acknowledgment within 5 min; mitigation plan within 15 min.

**S2 (High)** — Significant feature outage or data inconsistency
- *Triggers:* Rent payment pipeline failing for >10% of active tenants, audit log discrepancy, login failures for >30 min, screening/adverse-action workflow broken, lease document generation failing
- *Action:* Send digest notification. Document in [INBOX.md](#inbox-escalation). Workaround if available; escalate if none.
- *SLA:* Founder review within 1 hour; decision (fix / accept / mitigate) within 4 hours.

**S3 (Medium)** — Single-tenant or non-critical-path issue; workaround exists or impact is low
- *Triggers:* One tenant's photo upload failing, non-critical field validation error, support ticket on a closed lease, dashboard performance degraded
- *Action:* Log to [support queue](#support-triage-escalation). Document in status page under "Investigating."
- *SLA:* Founder review within 24 hours.

**S4 (Low)** — Cosmetic or documentation issue; no user impact
- *Triggers:* Typo in error message, dashboard button label unclear, outdated help text
- *Action:* File as a backlog item for the next sprint if valuable; otherwise close.
- *SLA:* No SLA.

---

## 3. Incident Runbooks

### 3.1 Key Compromise (S1)

**Scenario:** A signing key (attestation, governance multisig, audit anchor, or custody-provider signer) is suspected leaked, stolen, or misused.

**Immediate (0–5 min):**
1. **Assess scope:** Which key? When? Who has it? (Check logs, access audits.)
2. **Page founder immediately** with the key type, suspected time, and affected parties.
3. **Freeze the key's capability:** Remove from active rotation. If a governance multisig, post a pause-transaction to the contract (requires the other signers — founder coordinates).
4. **Preserve evidence:** Export all access logs, signing events, and timestamps for that key. Do not alter.

**Mitigation (5–60 min, founder-driven):**
1. **Initiate key rotation ceremony:** Generate new keys (see [ARC-07 §7.3](../architecture/07-deployment-view.md#73-key--signer-topology-highest-sensitivity-assets), post-MVP deliverable: key ceremony doc). Notify hardware wallet holders if it's a multisig.
2. **Audit all transactions signed by the compromised key** since the suspected compromise time. Flag any that were unauthorized.
3. **Notify affected counterparties:** If a lease was signed or a fund was moved with the compromised key, notify the tenant/landlord in writing that an attestation integrity issue occurred (do not admit fault yet — this is informing, not apologizing).
4. **Legal counsel:** Notify counsel immediately. Determine if disclosure to regulators or affected parties is required (varies by jurisdiction and asset type).

**Post-incident (after fix, 2–72 hours):**
1. **Root-cause analysis:** How did the key leak? Access control failure? Phishing? Unencrypted storage? (See §5 below.)
2. **Validation:** Retest the signing surface after rotation. Run security checklist (§4 below).
3. **Disclosure plan:** If required by law (e.g., data breach notification in WA requires notice within 30 days), draft and send notices to affected parties.
4. **Document all findings in the audit log** — this incident is a key audit event.

---

### 3.2 Data Breach (S1) — with WA Breach-Notification Obligations

**Scenario:** Unauthorized access to PII, KYC data, FCRA reports, or financial records is confirmed or suspected.

**Immediate (0–5 min):**
1. **Confirm breach:** Check access logs, database audit trails, S3 access logs, API call logs. What data was accessed? By whom? When?
2. **Isolate affected systems:** If still compromised, disconnect the affected service or database (but do not lose evidence).
3. **Page founder + legal counsel.** This is a disclosure event.

**Containment (5–30 min):**
1. **Revoke suspect credentials:** Reset passwords for any accounts that could have accessed the data.
2. **Review recent access:** Export all audit logs for the breach window. Identify what was accessed.
3. **Scope:** How many users affected? What data? (PII = name/address/SSN. KYC = identity docs. FCRA = credit/tenant history. Financial = ACH, deposit details.)

**WA Breach-Notification Law (RCW 19.255):**
- **Trigger:** Unauthorized access to PII of WA residents; "personal information" includes name + SSN, driver license, financial account, or FCRA report.
- **Timeline:** Notify affected residents **"without unreasonable delay"** — standard interpretation is **30 days**.
- **Content:** Notification must include (1) description of breach, (2) types of data compromised, (3) recommended steps (e.g., credit freeze), (4) your contact info.
- **Also notify:** Attorney General (if >500 WA residents affected or if media coverage likely).

**Founder-driven disclosure (30 min – 2 hours):**
1. **Draft breach notice** (plain language, honest, no legal-speak that obscures facts). Template outline:
   ```
   Subject: Notice of Data Breach

   [Company name] is notifying you of a security incident affecting your account.

   WHAT HAPPENED:
   On [date], we discovered unauthorized access to our systems.
   We have confirmed that the following information was accessed:
   - [List: name, email, SSN, property address, etc.]

   WHAT WE ARE DOING:
   - We immediately contained the access.
   - We are working with [law enforcement / cybersecurity firm] to investigate.
   - We are implementing [specific controls, e.g., stronger encryption, IP whitelisting].

   WHAT YOU SHOULD DO:
   - Monitor your credit. Consider a free credit freeze via [Equifax/Experian/TransUnion].
   - Watch for phishing and unusual account activity.
   - Contact us at [email] or [phone] with questions.

   MORE INFORMATION:
   Our full breach-disclosure FAQ is at [docs/legal/breach-faq.md (TODO: counsel)].
   ```
   (TODO(counsel: LGL-02) — finalize template language with legal review.)

2. **Coordinate with counsel:** Counsel may advise specific wording to manage liability. Founder approves final text.
3. **Notify via all channels:** Email to all affected residents, phone call for high-value accounts (landlords with large deposits), and post a status-page alert.
4. **File AG notice** (if triggered): Send letter to Washington AG + AG offices for any other states where affected residents live.
5. **Preserve for regulators:** Save all breach evidence, investigation, and response timeline in a secure folder. Regulators may request it.

**Post-incident:**
1. **Forensic investigation:** Hire third-party incident-response firm (deferred until budget; mock at MVP for tabletop).
2. **Root cause:** How did the access happen? Unpatched service? Phishing? Stolen creds?
3. **Remediation:** Patch, rotate credentials, enable 2FA, restrict access, add monitoring.
4. **Validation:** Penetration test or security audit to confirm the fix.
5. **Update threat model** (DSN-05) with the new attack vector.

---

### 3.3 Vendor or Processor Outage (S2, sometimes S1)

**Scenario:** A critical third-party service (e.g., Stripe for ACH, screening CRA, e-sign vendor, RPC provider) is down or severely degraded.

**Immediate (0–10 min):**
1. **Confirm the outage:** Check the vendor's status page. Run a test transaction. Verify it's not a local config issue.
2. **Assess impact:** Can payments be processed? Can leases be signed? Can tenant screening proceed? For how many hours?
3. **Classify:**
   - If *payment processing* is down for >30 min: **S1** — page founder.
   - If *screening* is down: **S2** — applications can proceed without screening (with founder approval) or pause (notify landlords).
   - If *e-sign* is down: **S2** — leases can be held for signature, or fallback to countersigned PDFs (founder call).
   - If *RPC provider* is down: **S2** → **S1** if it's the only provider; failover to backup if configured.

**Mitigation path (founder-decided):**
1. **Wait for recovery** if ETA <2 hours and impact is low (S2).
2. **Activate fallback** if impact is high:
   - Payment: ACH fallback via a second processor (if configured; see [ARC-07 §7.4](../architecture/07-deployment-view.md#74-availability-dr--bcp)).
   - Screening: Proceed with application (note: "Screening data not available; applicant may provide references or prior lease history" — founder approval required).
   - E-sign: Fallback to countersigned PDF + manual countersign by landlord (slower but valid under UETA).
   - RPC: Automatic failover to secondary provider (if implemented; otherwise manual switchover).
3. **Notify affected users:** Push notification + email explaining the delay and ETA. Update status page.
4. **Set a 4-hour timeout:** If vendor still down after 4 hours, escalate to founder for a vendor-switch decision.

**Recovery & communication:**
- Once vendor recovers, validate that queued transactions processed correctly.
- Post a post-mortem to status page: what was affected, how long, what we did, what we'll do to prevent it.

---

### 3.4 Chain / On-Chain Settlement Incident (S2–S1) — POST-MVP

**Scenario:** Base L2 is congested, finality is delayed, a contract is paused, or an oracle is misbehaving. Marked POST-MVP because rent is not yet on-chain at MVP.

**Immediate:**
1. **Assess:** Is it a network delay (finality just slower) or a hard failure (contract halted)?
2. **Check DSN-05 §3 risk register** for chain-side risks and mitigations.
3. **For network delay:** Rent payment logic waits; no hard stop (DEFERRED_CHAIN saga states are in place per [ARC-08 §8.4](../architecture/08-crosscutting-concepts.md#84-on-chain--off-chain-consistency)).
4. **For contract pause:** This is intentional (governance or emergency); founders are alerted. Funds are frozen pending human decision to resume or invoke a fallback.

**Mitigation:**
- Activate ACH / off-chain fallback rail for time-critical obligations.
- Notify tenants/landlords: "Rent payment processing is slightly delayed due to network conditions. Your payment will clear by [date]. No action needed."

See post-MVP runbooks for full orchestration (tracked in ANL-04 as a pre-mainnet deliverable).

---

## 4. Security Checklist (after S1 incident)

After any **Security**-class incident (key compromise, breach, anomaly), follow this checklist before resuming normal operations:

- [ ] **Root cause identified and documented.** Do not re-enable until you know how it happened.
- [ ] **Fix deployed and tested.** Code change, configuration change, or manual control (e.g., IP whitelist, MFA override) applied and verified in staging.
- [ ] **Credentials rotated.** All secrets, API keys, signing keys, and passwords involved in the incident regenerated.
- [ ] **Access logs reviewed.** Confirm no other suspicious activity in the last 30 days. Flag anomalies for investigation.
- [ ] **Audit log entry created.** "Incident [ID]: [description]; root cause [X]; fix [Y]; rotated [secrets]; status: closed."
- [ ] **Monitoring/alerting added.** If the incident could happen again, did we add an alert? (e.g., "multiple failed login attempts" → page founder after 10 consecutive failures from the same IP.)
- [ ] **Test passed.** Reproduce the scenario in staging and confirm the fix prevents it.
- [ ] **Team notified.** Founder, on-call security, and any affected team members acknowledge the incident and the fix.
- [ ] **Rate-limited post-mortem scheduled.** (Post-MVP: blameless postmortem meeting within 5 working days; outcomes recorded in a postmortem document under `sprint/incidents/`.)

---

## 5. Error Taxonomy in Code

[ARC-08 §8.6](../architecture/08-crosscutting-concepts.md#86-error-handling--escalation-taxonomy) defines the error classes. Implementation:

- Every API error response includes a `code` field and a `class` field (one of `retryable_technical`, `business_rejection`, `disagreement`, `legal_hold`, `security`).
- Every error that escalates to human action appends to `INBOX.md` with a structured entry.
- Observability metrics track error rates by class (see [OPS-01 §6](autonomous-operation.md#6-escalation--daily-digest-the-phone-interface)).

Example error response:
```json
{
  "error": {
    "code": "screening_not_available",
    "class": "retryable_technical",
    "message": "Screening vendor is temporarily unavailable.",
    "retry_after_seconds": 3600,
    "user_guidance": "Please try again in 1 hour, or contact support."
  }
}
```

---

## 6. Contact & Escalation Paths

**Founder (all S1, some S2):**
- Phone: [TODO: phone number in .env]
- Email: [founder email]
- In-app: Notification via Claude mobile app (the alert pings the founder with incident details)

**On-Call Security (S1 security incidents, post-MVP):**
- [TODO: on-call rotation schedule, if staffed]

**Legal Counsel (S1 security/legal/compliance):**
- [TODO: counsel contact info, retained as of LGL-01 engagement]

**Vendors (coordinated via founder):**
- Stripe: support@stripe.com
- Screening CRA: [vendor contact, from .env.local]
- E-sign provider: [vendor contact, from .env.local]

---

## 7. Post-MVP Roadmap

The following are deferred beyond the 30-day MVP but are release-blocking for Phase 1a (public beta):

- **Key ceremony document** (ARC-07 §7.3): Multisig key ceremony, hardware wallet setup, signing procedures, loss/rotation runbooks. (Tracked in ANL-04.)
- **Tabletop exercises:** Simulate key compromise, data breach, and processor outage with the full team. (Scheduled pre-Phase-1a.)
- **Vendor SLA agreements:** Formalize RTO/RPO with each vendor (payment processor, screening, e-sign, RPC).
- **Insurance & claims process:** Cyber liability + E&O insurance; incident claims procedure.
- **Regulatory incident reporting:** If triggered (breach, fund loss), escalate to regulators; finalize state AG notification templates.
- **Third-party incident response:** Pre-contract a forensic investigation firm for breach response.
- **Status page automation:** Auto-detect outages and post real-time status updates (see [OPS-05](status-page.md)).

---

## 8. Appendix — Incident Log Template

Every incident is logged in `sprint/incidents/YYYY-MM-DD-incident-ID.md`:

```markdown
# Incident Report: [Short Title]

| Field | Value |
|---|---|
| **ID** | INC-YYYYMMDD-001 |
| **Date/Time** | 2026-06-19 14:32 UTC |
| **Severity** | S1 / S2 / S3 / S4 |
| **Class** | retryable_technical / business_rejection / disagreement / legal_hold / security |
| **Status** | Resolved / In Progress / Escalated |
| **Affected Users** | [N users, N transactions, N landlords, etc.] |
| **Root Cause** | [What happened] |
| **Detection** | [How was it found] |
| **Time to Detect** | [Duration from occurrence to finding] |
| **Time to Resolve** | [Duration from finding to mitigation] |
| **Mitigation** | [Steps taken] |
| **Prevention** | [What was added to prevent recurrence] |

[Detailed narrative of the incident, timeline, actions taken, and learnings.]
```

---

## 9. References

- [ARC-08 §8.6](../architecture/08-crosscutting-concepts.md#86-error-handling--escalation-taxonomy) — Error Handling & Escalation Taxonomy
- [DSN-05 §5](../design/security-threat-model.md#5-security-engineering-baseline) — Security Engineering Baseline
- [ARC-07 §7.3](../architecture/07-deployment-view.md#73-key--signer-topology-highest-sensitivity-assets) — Key & Signer Topology
- [ARC-07 §7.4](../architecture/07-deployment-view.md#74-availability-dr--bcp) — Availability, DR & BCP
- [OPS-01 §6](autonomous-operation.md#6-escalation--daily-digest-the-phone-interface) — Escalation & Daily Digest
- [CLAUDE.md](../../CLAUDE.md) — Hard Invariants

---

**Status:** This is a draft runbook for the 30-day MVP. All operational procedures are subject to change as the platform matures. Send updates to [founder email] or file a task in the sprint backlog.
