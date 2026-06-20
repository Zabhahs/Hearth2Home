# OPS-04 — Support Runbook (Pilot Playbook)

| | |
|---|---|
| **Doc ID** | OPS-04 |
| **Version** | 0.1.0-draft · 2026-06-19 |
| **Status** | Draft for founder review |
| **Governs** | MVP support workflow; triage; escalation to founder; SLA expectations |
| **Companion files** | [OPS-01](autonomous-operation.md) (operations) · [OPS-03](runbook-incident.md) (incident response) · [OPS-05](status-page.md) (public status) |

## 1. MVP Support Model

At MVP (30-day rental phase), **the founder is the primary support contact.** There is no support team yet. This playbook defines the triage workflow, escalation criteria, and SLA expectations for the founder's 30–60 min/day.

**Support channels:**
- In-app help + FAQ (linked from landlord dashboard and tenant portal)
- Email support: [support email TBD in .env]
- Founder phone/SMS (for S1/S2 only; S3 via email)
- Status page public-facing updates (see [OPS-05](status-page.md))

**Support queue:** A shared inbox (GitHub INBOX.md + email integration) tracks open issues. Each ticket is triaged into:
1. **FAQ / Self-service** — answer from help docs
2. **Bug / Platform issue** — escalate to dev; S3/S2/S1 severity
3. **Operational decision** — founder approval needed (e.g., "Can we unfreeze this account?" — legal/policy call)
4. **Happy path** — user confusion or misclick; reassurance + pointer to docs

---

## 2. Common Issues & Triage

### 2.1 Login & Account Access

**Issue:** "I can't log in" / "I forgot my password" / "I'm locked out"

**Triage steps (1–2 min):**
1. **Is Supabase auth down?** Check status page. If yes, update support ticket with ETA and mark as S2.
2. **Is the user in the database?** Search by email in Supabase dashboard (console → Auth). If not present, they haven't signed up yet.
   - *Action:* Send password-reset link via Supabase auth UI. If still not working, check: (a) email spam filter, (b) user typo on email.
3. **Did they receive the reset email?** Ask them to check spam / promotions folder.
4. **Are they using the right email?** Confirm the email they signed up with (sometimes users have multiple emails).
5. **MFA / 2FA issue?** MVP does not have 2FA on login (deferred); if mentioned, explain it will roll out later.

**Resolution path:**
- **Self-service:** Email the Supabase password-reset link: "Click this link and set a new password." (Link auto-expires in 24h.)
- **If email lost/unavailable:** Founder can manually reset via Supabase console (Auth → Users → find the user → Reset Password). Document this in audit log.
- **Escalate to S2 if:** User locked out after multiple attempts or claims account was compromised.

**SLA:** Response within 1 hour; resolved within 24 hours.

---

### 2.2 Rent Payment Failed

**Issue:** "My rent payment bounced" / "Tenant says they paid but I don't see it" / "Payment is stuck"

**Triage steps (5 min):**
1. **Check processor status** (Stripe, ACH partner). Is there an outage? → Post S2 alert.
2. **For a specific tenant:**
   - Go to dashboard → Leases → select the tenant's lease → view transaction history.
   - Is the transaction present? If yes, what's the status (`pending`, `processing`, `failed`, `succeeded`)?
   - **Pending/Processing:** Wait 1–2 business days (ACH is slow). Update the tenant: "Your payment is processing. You'll see a confirmation email within 2 business days."
   - **Failed:** What's the error? Common reasons: insufficient funds, bank account flagged, account mismatch, network retry limit reached.
3. **Contact the tenant:** Ask for bank confirmation of the transfer attempt (failed transactions usually generate an error from their bank).
4. **Check reconciliation logs:** Go to Observability → Rent Pipeline → last 24h. Are there reconciliation mismatches flagged?

**Resolution path:**
- **Insufficient funds:** Tenant needs to re-attempt with available funds. Explain dunning retry logic ("We'll retry on [date] and [date]").
- **Account mismatch (e.g., name not matching):** Tenant must update their bank account info or contact their bank to update the receiving account. Founder can help re-route if the account is in the system but misconfigured.
- **Processor-side issue:** If recurring failure across multiple tenants, escalate to S2 (processor outage). If single tenant + suspicious pattern, escalate to S1 (security).
- **If customer paid but system didn't record it:** Ask for proof (bank statement, receipt). Founder manually reconciles in the database + audit log. This is a **Disagreement** class error; founders document it carefully (see [OPS-03 §3.2](runbook-incident.md#32-data-breach-s1--with-wa-breach-notification-obligations)).

**SLA:** Response within 2 hours; escalation to processor (if needed) within 4 hours.

---

### 2.3 Application Status / "Where's my application?"

**Issue:** "I submitted an application but haven't heard back" / "Landlord says it didn't arrive" / "What's my status?"

**Triage steps (2 min):**
1. **Check if the application is in the database:**
   - Go to dashboard → Applications → search by tenant email.
   - Is it there? If yes, what's the status? (`submitted`, `screening_in_progress`, `screening_complete`, `approved`, `rejected`, `withdrawn`)
2. **If missing entirely:**
   - Did the tenant actually submit? Ask them for a screenshot or confirmation email. (Application confirmation is a TODO feature at MVP.)
   - If they submitted, but it didn't arrive: possible UI bug. Escalate to S2 + developer review.
3. **If pending screening:** How long? (Screening vendor usually takes 24–48h.)
   - If >48h, check vendor status. Is the CRA down? Escalate to OPS-03 §3.3 (vendor outage).
4. **If approved:** Congratulations email should have been sent automatically. Check spam folder.
5. **If rejected:** A written adverse-action letter must be sent per [OPS-03 §3.2](runbook-incident.md#32-data-breach-s1--with-wa-breach-notification-obligations) + [ARC-08 §8.6](../architecture/08-crosscutting-concepts.md#86-error-handling--escalation-taxonomy). Founder verifies it was sent and resends if needed.

**Resolution path:**
- **Status is clear, just needs an update:** Send the tenant a dashboard link showing their status. "Your application is [status]. We'll notify you by [date]."
- **Missing application:** Have the tenant re-submit via the dashboard link. If the same issue happens again, escalate to S2.
- **Stuck in "screening_in_progress" for >72h:** Manually trigger a re-check with the vendor. Log the action in audit.

**SLA:** Response within 4 hours; resolution or clear ETA within 24 hours.

---

### 2.4 Document Access & Visibility

**Issue:** "I can't see my lease" / "Where do I download the signed lease?" / "The landlord/tenant can't see my documents"

**Triage steps (3 min):**
1. **Check document storage:** Go to Supabase console → Storage → Executed Docs → search by lease ID.
   - Is the document present? (File should be named `lease_[lease_id]_[date].pdf`.)
2. **Check RLS permissions:** Does the user own this lease (are they the landlord or tenant)?
   - If yes: they should have read access. If not: they should not.
   - Use Supabase RLS policy tester: query the `leases` table with the user's token. If the row is returned, permissions are correct.
3. **If the document doesn't exist:**
   - Was the lease signed yet? If not, there's no executed doc to download. (Unsigned draft is a TODO feature at MVP.)
   - If it should have been signed: check the e-sign adapter logs. Did the e-sign flow complete? Check status: `pending_signature`, `signed`, `failed`.
4. **If the document exists but isn't shown in the UI:**
   - Check the browser console for JavaScript errors (support can ask the user).
   - Check the backend logs: is the API call returning the document URL? (Observability → API Logs → filter by user + endpoint `/documents`.)

**Resolution path:**
- **User doesn't own the lease:** Explain: "You don't have access to this lease. Only the landlord/tenant can view it." Suggest they contact the counterparty.
- **Document not yet generated:** "Your lease is still being prepared. You'll receive a link to download it by [date]."
- **Document exists, UI bug:** Backend should return the URL. Escalate to S2 (UI bug). Workaround: founder can directly share the S3 presigned URL via email.
- **E-sign flow incomplete:** Check with tenant: "Did you click the e-sign link in your email?" If yes but not signed, check e-sign vendor status. If vendor is down, escalate to S2 (see OPS-03 §3.3).

**SLA:** Response within 2 hours; resolution or workaround within 4 hours.

---

## 3. Triage Matrix

Quickly classify incoming support requests:

| Issue | Severity | Tier | Owner | SLA |
|---|---|---|---|---|
| Login / password reset | S3–S2 | 1st | FAQ auto-response → founder (if persistent) | 1 h / 24 h |
| Rent payment failed | S3–S1 | 2nd | Support triage → founder (if system error) | 2 h / 4 h |
| App not submitted / stuck | S3–S2 | 1st | Support triage → dev (if bug) | 4 h / 24 h |
| Can't access documents | S3–S2 | 1st | Support triage → dev (if RLS/storage issue) | 2 h / 4 h |
| Lease terms question | S4 | FAQ | Self-service (plain-language guide) | N/A |
| Late fee calculation dispute | S3 | 2nd | Support triage → founder (policy call) | 24 h |
| Landlord/tenant verification claim | S2 | 2nd | Support triage → founder (legal/audit) | 4 h |
| Data deletion request (privacy) | S2 | 2nd | Support triage → founder (counsel + GDPR/CA) | 5 days |
| Suspicious account activity | S1 | 3rd | Support triage → founder (security) | 15 min |

---

## 4. Escalation to Founder

**The founder is escalated when:**

1. **S1 or S2 severity** — See [OPS-03 §2](runbook-incident.md#2-severity-levels--paging-policy) for severity definitions.
2. **Unclear policy call** — "Should I refund this tenant?" "Can the landlord change the rent amount after signing?" → Founder decides.
3. **Legal/compliance question** — "What do I tell the tenant about their deposit?" → Founder consults counsel if needed.
4. **Repeated issue** — Same bug from multiple users. Escalate to dev with reproduction steps.
5. **User requesting exception** — "Can you let me sign the lease without screening?" → Founder approves or denies.

**Escalation format (in INBOX.md):**

```markdown
| Item | Priority | For | Details |
|---|---|---|---|
| SUPPORT-001 | S2 | Founder | Rent payment stuck for tenant [email]; processor returned error [code]; last attempt [timestamp]; needs decision: retry / refund / hold |
| SUPPORT-002 | S3 | Founder | Lease download broken for 3 users this week; same issue: 404 on document URL. Dev investigation needed. |
```

---

## 5. SLA Expectations & Response Windows

At MVP, the founder is the primary support agent. **Response window = time to acknowledge the issue and begin work.**

| Severity | Response SLA | Resolution Target | Owner |
|---|---|---|---|
| S1 (Critical) | 15 min | 2 hours | Founder + on-call dev |
| S2 (High) | 1 hour | 4 hours (or clear workaround) | Founder |
| S3 (Medium) | 4 hours | 24 hours (or schedule for next sprint) | Founder / backlog |
| S4 (Low) | No SLA | Next sprint | Backlog |

**Workaround = acceptable temporary solution** (e.g., founder manually sends a presigned S3 URL if document download is broken; escalate to dev for permanent fix next sprint).

---

## 6. Common Responses & Templates

### Login Issue Template

```
Hi [Name],

We've reset your password. Please click the link below to set a new one:

[Password reset link from Supabase]

This link expires in 24 hours. If it doesn't work:
1. Check your spam folder.
2. Try again from an incognito/private browser window.
3. Reply here and we'll help.

Thanks,
[Support]
```

### Rent Payment Delay Template

```
Hi [Tenant/Landlord],

We've received your ACH payment request for $[amount] on [date].
ACH transfers typically take 1–2 business days.

Expected arrival: [date range]

You'll receive a confirmation email once the payment clears.

Questions? Reply here.

Thanks,
[Support]
```

### Application Status Template

```
Hi [Tenant],

Your application was submitted on [date]. Here's where we are:

Current status: [screening_in_progress / pending_landlord_review / approved / etc.]

Next step: [Details]

Expected decision by: [date]

View your full application: [Dashboard link]

Questions? Reply here.

Thanks,
[Support]
```

### Adverse-Action / Rejection Template

```
Hi [Tenant],

Thank you for applying to [Property]. After careful review, we are unable to move forward at this time.

This decision was based on [screening results / credit report / criminal history check / etc.].

Per the Fair Housing Act, you have the right to receive details about why you were not approved and to dispute the information.
For full details, see your adverse-action letter below:

[Attached: adverse-action letter PDF]

TODO(counsel: LGL-01) — finalize template language

If you believe this decision was made in error or in violation of fair housing law, you may:
1. Contact the screening vendor directly: [Vendor name + contact]
2. File a complaint with HUD: [HUD contact info]

Questions? Reply here.

Thanks,
[Support]
```

---

## 7. Privacy & Data Subject Requests

**Data Subject Requests (DSR):** If a tenant or landlord asks to access, download, or delete their data (common under GDPR, CCPA, Washington My Health My Data Act), this is an S2 escalation.

**Process:**
1. **Confirm identity:** Verify they own the account (match email to our records).
2. **Determine request type:**
   - **Access/Download:** "Provide all data you have on me."
   - **Correction:** "Fix my incorrect phone number."
   - **Deletion:** "Delete my account and all records."
3. **Timeline:** GDPR = 30 days; CCPA = 45 days; WA = 45 days (varies by state).
4. **Escalate to founder:** Founder coordinates with counsel to ensure compliance + prepares the export.
5. **Deliver the response:** Send the data export (or deletion confirmation) within the required timeline.

**Deletions are tricky:** Some data must be retained (e.g., executed leases for audit, dispute resolution). Founder + counsel determine what can be deleted vs. anonymized. Do not auto-delete without approval.

---

## 8. Abuse & Fraud Triage

**If a support ticket suggests fraud or abuse** (e.g., "The landlord stole my deposit," "The tenant created a fake application,"), escalate to S1:

1. **Do not make a judgment call.** Gather facts and escalate to founder.
2. **Preserve evidence:** Screenshot the claim, the user's account, transaction history, timestamps.
3. **Freeze the entity** (if possible without alerting): Mark the account as `under_review` in the database.
4. **Notify founder immediately:** "Potential fraud: [description]. Evidence: [links to audit logs/screenshots]."
5. **Founder + counsel decide:** Is this a civil dispute (tenant sues landlord) or platform fraud (account compromise, collusion)? Different escalation paths.

---

## 9. Post-MVP Support Roadmap

The following are deferred beyond MVP and planned for Phase 1a / Phase 2:

- **Ticketing system** (e.g., Zendesk, Linear): Formal ticket tracking, priority queues, customer-facing status.
- **Support team hiring** (Phase 1a, ~3–5 people): First-line triage, escalation to founder/eng.
- **Chatbot / AI support assistant** (Phase 2): Auto-answer FAQs, route to human for escalations.
- **Dispute resolution workflow** (Phase 1a): Formal process for tenant ↔ landlord disputes over deposits, late fees, conditions. (Currently, founder decides case-by-case.)
- **SLA enforcement & metrics** (Phase 1a): Track response times, resolution times, customer satisfaction surveys.
- **Help center / knowledge base** (Phase 1a): Self-service FAQs, video tutorials, runbooks for common flows.

---

## 10. References

- [OPS-01 §6](autonomous-operation.md#6-escalation--daily-digest-the-phone-interface) — Escalation & Daily Digest
- [OPS-03 §2](runbook-incident.md#2-severity-levels--paging-policy) — Severity Levels & Paging Policy
- [ARC-08 §8.6](../architecture/08-crosscutting-concepts.md#86-error-handling--escalation-taxonomy) — Error Handling & Escalation Taxonomy
- [CLAUDE.md](../../CLAUDE.md) — Hard Invariants

---

**Status:** This is a draft playbook for the 30-day MVP with a founder-driven support model. It will evolve as the team grows. Founder, please add your phone/email contact info and preferred escalation channels to this doc in your first update.
