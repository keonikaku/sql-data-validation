# Migration Test Strategy
### Legacy on-prem → modernized core banking platform

**Owner:** Keoni Kakugawa, Test Manager
**Scope:** Data migration validation for the core banking platform — customers, accounts,
balances, and transactions moving from the legacy on-premises system to the modernized
platform. This strategy governs how we prove the migration is complete, correct, secure,
and performant before cutover.

---

## 1. Objective
Provide evidence-based go/no-go assurance that every record migrated **completely,
accurately, securely, and without performance regression** — and that any defect is caught
in test, not in production.

## 2. Validation categories
Each category is an automated, repeatable check that runs against source and target.

| # | Category | What it proves | Method |
|---|----------|----------------|--------|
| 1 | **Reconciliation** | No records lost or duplicated | Source-vs-target row counts per table; signed delta (loss vs. duplication) |
| 2 | **Referential integrity** | Every relationship intact | Orphan detection via `LEFT JOIN ... WHERE key IS NULL` |
| 3 | **Transformation / field mapping** | Converted fields translated correctly | Rule-based `CASE` mapping; catches wrong *and* invalid values |
| 4 | **Security / PII** | No sensitive data exposed | Plaintext-shape detection across all PII fields; access-control checklist |
| 5 | **Performance / response time** | No speed regression | `EXPLAIN QUERY PLAN` index-usage checks; p95 SLA thresholds |

## 3. Test approach
- **Source-to-target, automated, repeatable.** Every check is codified so it re-runs
  identically after each migration iteration — no manual eyeballing (which doesn't scale
  and misses defects).
- **Risk-based prioritization.** Security/PII and performance are treated as cutover
  blockers; a single exposed SSN or a dropped index halts go-live.
- **Root-cause over symptom.** One defect can surface across multiple checks (e.g., a
  dropped customer appears as both a count variance and an orphaned account); we trace to
  the underlying cause, not just the symptom.
- **Engineering partnership.** Test Engineers author and maintain the validation queries;
  the Test Manager owns coverage, execution oversight, interpretation, and sign-off.
- **Prevention, not just detection.** Where possible, recommend controls (constraints,
  enforced foreign keys, masking gates) so defects can't recur.

## 4. KPIs — measuring testing effectiveness
| KPI | Definition | Target |
|-----|-----------|--------|
| **Reconciliation pass rate** | % of tables/records that reconcile source-to-target with zero variance | 100% before cutover |
| **Defect leakage rate** | % of defects found *after* the stage that should have caught them (escaped to later phases / production) | Trend to near-zero; any production leak = process review |
| **Validation coverage** | % of tables, fields, and validation categories covered by automated checks | 100% of in-scope entities |
| **Open cutover-blockers** | Count of unresolved critical (security/PII, data-loss, performance) defects | Must be **0** to go live |

## 5. Team structure
A **Test Manager + Test Engineer hybrid** model (per the role):
- **Test Manager** (this role): owns the strategy, defines coverage, prioritizes by risk,
  reviews and interprets results, reports status to stakeholders, and holds go/no-go
  sign-off. Hands-on enough to read, review, and direct the validation queries.
- **Test Engineer(s):** author and maintain the validation SQL, build the automated
  execution/reporting, and triage findings with the Test Manager.

This keeps deep technical authorship with engineering while accountability for quality and
release readiness sits with a single owner.

## 6. Cutover go/no-go criteria
Cutover is approved only when: reconciliation pass rate = 100%; zero orphaned/invalid
records; all transformed fields validated; **no plaintext PII anywhere in the target**;
hot-path queries meet p95 SLA with no regression vs. legacy baseline; and zero open
cutover-blockers. Any failure is an automatic no-go.

---
*Backed by a live validation suite (5 categories, executable checks) and supporting
artifacts: PII access-control checklist and performance SLA / load-testing approach.*
