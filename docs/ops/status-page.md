# OPS-05 — Status Page (Stub Specification)

| | |
|---|---|
| **Doc ID** | OPS-05 |
| **Version** | 0.1.0-draft · 2026-06-19 |
| **Status** | Draft for founder review; stub specification only (not implemented at MVP) |
| **Governs** | Public communication of platform status; uptime/incident transparency; user-facing SLAs |
| **Companion files** | [OPS-01](autonomous-operation.md) (operations) · [OPS-03](runbook-incident.md) (incident response) · [OPS-04](runbook-support.md) (support) |

---

## STUB DISCLAIMER

**This document is a specification stub. It defines what a status page should contain and how it will be used. Implementation (hosting, automation, UI) is deferred and tracked in ANL-04 as a Phase 1a deliverable.**

At MVP (30-day rental phase), status updates are communicated via:
- In-app notifications (landlord dashboard, tenant portal)
- Email alerts (for S1/S2 issues)
- GitHub INBOX.md + sprint digest (founder-facing)
- Manual posts to a holding URL (e.g., `[statuspage_placeholder].md` in the repo)

Post-MVP, a proper status page (hosted on Statuspage.io, Atlassian Status, or custom) will automate these notifications.

---

## 1. Status Page Purpose

A public, real-time dashboard showing:
- **System availability** — "Is the platform up?"
- **Component health** — "Which parts are working?"
- **Incident history** — "What broke recently? When? How long?"
- **Estimated downtime** — "When will [feature] be back?"

**Audience:** Landlords (property managers, owners) and tenants. They want assurance that rent payment, lease signing, and application submission will not randomly fail.

**SLA commitment (post-MVP):** We commit to 99.9% availability (8.76 hours of downtime per year, or ~43 minutes/month) for the critical path:
- Login
- Rent payment processing
- Lease document signing
- Application submission

---

## 2. System Components

Each component has a status that updates in real-time:

| Component | What It Is | Status Page Shows | User Impact If Down |
|---|---|---|---|
| **App (Web/Mobile)** | Next.js frontend + API | "Operational" / "Degraded" / "Down" | Users can't log in or use dashboard |
| **Database (PostgreSQL)** | Supabase RDS | "Operational" / "Degraded" / "Down" | All features blocked; data not persisted |
| **Rent Processing** | ACH + processor integration | "Operational" / "Degraded" / "Down" | Rent payments fail or are delayed; escalates to S1 |
| **Lease Signing (E-sign)** | E-sign vendor + document storage | "Operational" / "Degraded" / "Down" | Leases can't be signed; fallback to countersigned PDF (slower) |
| **Tenant Screening** | CRA integration | "Operational" / "Degraded" / "Down" | Applications proceed without screening data (founder approval needed) |
| **Email / Notifications** | Transactional email + push | "Operational" / "Degraded" / "Down" | Users don't receive confirmations, but transactions may still succeed (async) |
| **File Storage (S3)** | Document archival | "Operational" / "Degraded" / "Down" | Executed leases can't be downloaded; mitigation: presigned URL shared via email |

---

## 3. Status States

Each component can be in one of these states:

| State | Definition | Action | Example |
|---|---|---|---|
| **Operational** | All systems nominal; no known issues | Continue normal operations | Rent processing is running normally; 0 errors in last hour |
| **Degraded Performance** | System is up but slower than expected or partially unavailable | Notify users of potential delays; offer workarounds | Database response times >2s (normal is <200ms); 5% of payment retries are triggering |
| **Partial Outage** | One component or region is down; others work | Notify affected users; provide ETA and fallback | E-sign vendor is down (lease signing paused); application submission still works |
| **Major Outage** | Multiple components or critical path is down | S1 incident; page founder immediately; activate fallback rails | Database is unreachable; all features blocked |
| **Maintenance** | Intentional downtime for updates; scheduled in advance | Announce 48h before; provide ETA; offer workarounds | "Scheduled maintenance 2026-06-21 22:00 UTC for 2 hours" |

---

## 4. Status Page Layout (Wireframe)

```
┌─────────────────────────────────────────────────────────────┐
│                  Hearth2Home Platform Status                │
│                                                               │
│ Last updated: 2026-06-19 16:30 UTC                           │
│ Uptime (30 days): 99.94% (1 incident, 33 min downtime)      │
└─────────────────────────────────────────────────────────────┘

CURRENT STATUS
├─ App & Services ............................ ✓ Operational
├─ Database ................................. ✓ Operational
├─ Rent Processing .......................... ✓ Operational (avg 1.2s)
├─ Lease Signing ............................ ✓ Operational
├─ Tenant Screening ......................... ⚠ Degraded (CRA API slow)
├─ Email & Notifications ................... ✓ Operational
└─ File Storage ............................. ✓ Operational

INCIDENTS & MAINTENANCE
┌─ 2026-06-18 14:20 UTC — Payment Processing Delay [RESOLVED]
│  Duration: 33 min | Severity: High
│  Details: Stripe API timeouts caused rent payment retries.
│  Action: We manually processed queued payments by 15:00 UTC.
│  Follow-up: Adding secondary payment processor (see roadmap).

┌─ Scheduled Maintenance [UPCOMING]
│  Date: 2026-06-21 22:00 UTC | Duration: ~2 hours
│  Impact: Lease signing will be unavailable. Other features normal.
│  Details: Upgrading e-sign integration to support bulk operations.

RECENT UPTIME (30 days)
  Week 1 (Jun 9–15):   99.98%  [1 brief outage Jun 10]
  Week 2 (Jun 16–19):  99.87%  [1 incident Jun 18, ongoing]
  Overall:             99.94%

ROADMAP
✓ Multi-region failover (Phase 1a)
✓ Payment processor redundancy (Phase 1a)
  Advanced monitoring & auto-remediation (Phase 2)
  SLA insurance & credits (Phase 2)
```

---

## 5. Update Cadence

**At MVP:** Manual updates in INBOX.md and posted to a status page stub (markdown or HTML).

**Phase 1a:** Automated:
- **Real-time health checks** (every 30s) — API health endpoint, database ping, processor test transaction.
- **Auto-status updates** — If health check fails, auto-post to status page and page founder.
- **Incident lifecycle management** — Auto-transition from "Investigating" → "Identified" → "Monitoring" → "Resolved"; track time in each state.
- **Uptime metrics** — Daily calculation of uptime %, incidents count, MTTR (mean time to resolve), MTBF (mean time between failures).

**Communication triggers:**
- **S1 incident:** Status page immediately shows "Major Outage" + ETA. Founder sends push notification.
- **S2 incident:** Status page shows "Partial Outage" or "Degraded" + ETA. Email to affected users.
- **S3 issue:** Status page shows under "Recent Issues" (informational). No immediate notification.
- **Resolved:** Auto-update status + add incident to history + send "All Clear" email.

---

## 6. Data to Track (Phase 1a+)

For each incident/maintenance window:

```json
{
  "id": "INC-20260619-001",
  "title": "Payment Processing Delay",
  "component": "Rent Processing",
  "severity": "S2",
  "status": "resolved",
  "start_time": "2026-06-18T14:20:00Z",
  "end_time": "2026-06-18T14:53:00Z",
  "duration_minutes": 33,
  "affected_users_estimated": 47,
  "root_cause": "Stripe API timeout cascade",
  "mitigation": "Manual payment processing; vendor fallover to backup processor",
  "follow_up_action": "Implement dual-processor routing (T-### backlog task)",
  "public_summary": "Stripe experienced temporary API slowness affecting 47 active rent payments. All payments were manually processed by 15:00 UTC.",
  "internal_notes": "[Detailed postmortem link]"
}
```

---

## 7. Availability Targets (Aspirational; Phase 1a+)

| Component | MVP Target | Phase 1a Target | Phase 2 Target |
|---|---|---|---|
| App (web/API) | 99.5% | 99.9% | 99.99% |
| Database | 99.5% | 99.9% | 99.99% |
| Rent Processing | 99.0% (due to processor dependency) | 99.5% (dual processor) | 99.9% (3+ rails) |
| Lease Signing | 99.5% (vendor dependency) | 99.9% (fallback to PDF) | 99.95% |
| Email | 99.5% (async; eventual delivery OK) | 99.9% | 99.95% |

**Notes:**
- MVP targets are aspirational; actual performance will be monitored and published at Phase 1a.
- Processors and vendors have their own SLAs (usually 99.5–99.9%). We are dependent on them.
- "Eventual consistency" features (email, notifications, audit log anchoring) can tolerate occasional delays (async retries are built in).
- Fund-related operations (rent payment, deposit release) require higher reliability and must be dual-railed.

---

## 8. Incident Response & Status Page Updates

**When an incident is detected:**

1. **Classify** (S1/S2/S3; see [OPS-03 §2](runbook-incident.md#2-severity-levels--paging-policy))
2. **Post initial status** — "Investigating: [Component] may be experiencing delays. We're looking into it."
3. **Page founder** (if S1/S2) — Founder confirms receipt and provides an ETA for next update.
4. **Post updates every 30 min** (if S1) or every 2 hours (if S2) — "Still investigating; new ETA [time]" or "Issue identified; workaround available."
5. **Post resolution** — "Issue resolved at [time]. Here's what happened and what we're doing to prevent it."
6. **Post-mortem** — 24–48 hours later, publish a brief summary (public) + detailed incident report (internal, link from status page).

**Status page message examples:**

```
INVESTIGATING
Rent Processing may be experiencing delays. We're looking into it. Last update: 14:25 UTC.
ETA: 15:00 UTC

---

IDENTIFIED
We've identified that our payment processor is experiencing API timeouts.
We're routing new payments through a backup processor.
Existing queued payments will be processed manually by 15:00 UTC.
ETA: 15:00 UTC

---

MONITORING
Payment processing is now functioning normally via our backup processor.
We're monitoring to ensure all queued payments clear by end of day.
ETA: 17:00 UTC for all payments to complete

---

RESOLVED
Payment processing is fully operational. All affected payments have been successfully processed.
We'll provide a detailed post-mortem within 24 hours.
```

---

## 9. Hosting & Architecture (Phase 1a Deliverable)

**Options (not yet decided):**

1. **Statuspage.io** (easiest; ~$30–100/mo)
   - Pre-built status page SaaS; API to auto-post incidents.
   - Integrates with monitoring tools (Datadog, New Relic).
   - Pros: Fast, professional, no hosting overhead.
   - Cons: Third-party dependency; cost scales with components.

2. **Atlassian Status** (if using Jira)
   - Integrated into the Jira/Confluence ecosystem.
   - Pros: One vendor, easy integration with incident tracking.
   - Cons: Limited customization; pricey at scale.

3. **Custom (Open-Source Cachethq or Upup)**
   - Deploy to Vercel or AWS.
   - Pros: Full control; can integrate with internal systems.
   - Cons: More maintenance; need to build automation.

4. **Simple GitHub-hosted Markdown** (MVP approach)
   - Status pinned in `docs/status-page-live.md` (public GitHub).
   - Pros: No cost; already in the repo.
   - Cons: Not real-time; no API integration; ugly UI.

**Recommendation:** Start with Statuspage.io at Phase 1a; integrate health-check automation and incident webhook. Migrate to custom if needed at Phase 2.

---

## 10. Historical Incident Archive

All resolved incidents are logged in `sprint/incidents/` and linked from the status page:

```
RECENT INCIDENTS (Last 90 Days)
  2026-06-18 | Payment Processing Delay | 33 min | S2
  2026-06-10 | Database Connection Spike | 12 min | S2
  2026-05-28 | E-sign Vendor Outage | 2 h 15 min | S2 [Vendor SLA: they paid $500 credit]
```

Each incident links to a full report (see [OPS-03 §8](runbook-incident.md#8-appendix--incident-log-template)).

---

## 11. Privacy & Data Minimization

**On the status page, do not:**
- List specific user counts affected ("47 users") — say "Small number of users" or "~5% of active users."
- Publish exact error rates ("5.3% of transactions failed") — say "Elevated error rates observed."
- Reveal PII or business metrics (highest-impact user, largest transaction, etc.).
- Disclose technical details that could aid attacks ("Our API key was exposed" → "We identified and remediated an access control issue").

**Do publish:**
- Component status (yes/no/degraded).
- Duration of incident.
- Root cause (at a high level; technical details in internal postmortem).
- Steps we took to fix it.
- What we're doing to prevent recurrence.

---

## 12. Post-MVP Roadmap

**Phase 1a (public beta, ~3 months post-MVP):**
- [ ] Deploy to Statuspage.io or custom host.
- [ ] Integrate health-check automation (every 30s ping; auto-post on failure).
- [ ] Build incident lifecycle workflow (Investigating → Identified → Monitoring → Resolved).
- [ ] Create public incident history (last 90 days, exportable).
- [ ] Set up SLA dashboard (uptime %, MTTR, MTBF by component).
- [ ] Draft SLA policy + incident communication templates.

**Phase 2 (production, ~6 months post-MVP):**
- [ ] Add advanced monitoring (Datadog, New Relic integration).
- [ ] Auto-remediation for common issues (auto-restart failed containers, trigger failover).
- [ ] Status page mobile app (push notifications for incidents).
- [ ] Customer-specific status subscriptions (landlord receives alerts only for payment processing).
- [ ] SLA credits & insurance (auto-issue credits if uptime falls below committed level).

---

## 13. References

- [OPS-01 §6](autonomous-operation.md#6-escalation--daily-digest-the-phone-interface) — Escalation & Daily Digest
- [OPS-03 §2](runbook-incident.md#2-severity-levels--paging-policy) — Severity Levels & Paging Policy
- [OPS-04](runbook-support.md) — Support Runbook

---

**Status:** This is a stub specification for a status page. It will be implemented and automated in Phase 1a (tracked in ANL-04). Until then, status updates are communicated via in-app notifications and email.
