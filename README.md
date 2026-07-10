# SQL Data Validation Suite — Core Banking Migration

An interactive, browser-based data-validation suite that proves a data migration
from a **legacy on-premises system** to a **modernized platform** moved data
completely, correctly, securely, and without performance regression.

**▶ Live demo:** `https://keonikaku.github.io/sql-data-validation/`
_(update this link after enabling GitHub Pages — see the publishing guide)_

## About This Project

A simulated core banking migration (customers, accounts, balances, transactions)
seeded with realistic migration defects. The suite runs real SQL checks against
two SQLite databases — the legacy source and the modernized target — entirely in
the browser (SQLite compiled to JavaScript, no server, no install). Each check
reports **PASS / FAIL** with the query and result rows behind it, exactly like a
Test Manager's validation report.

## Validation Categories

| # | Category | What it proves | Technique |
|---|----------|----------------|-----------|
| 1 | **Reconciliation** | No records lost or duplicated | Source-vs-target counts, signed delta |
| 2 | **Referential integrity** | No orphaned records | `LEFT JOIN ... WHERE key IS NULL` |
| 3 | **Transformation / field mapping** | Converted fields translated correctly | `CASE` mapping, expected vs. actual |
| 4 | **Security / PII** | No sensitive data exposed in plaintext | Plaintext-shape detection (`LIKE`) |
| 5 | **Performance / response time** | No query-speed regression | `EXPLAIN QUERY PLAN` index-usage check |

Each seeded defect is caught by its check: a lost customer, an orphaned account,
mis-mapped account statuses, a plaintext SSN/DOB, and a missing index.

## How To View

**Option A — just open it:** download `index.html` and open it in any browser.
Everything (SQLite engine + both databases) is embedded in the single file.

**Option B — live URL:** enabled via GitHub Pages (see `PUBLISHING_GUIDE.md`).

Scroll to the bottom for a **query playground** to run your own SQL against both
databases.

## Project Structure

```
sql-data-validation/
├── index.html                 # The interactive validation dashboard (self-contained)
├── db/
│   ├── legacy_seed.sql        # Legacy on-prem schema + data (with seeded drift)
│   └── modern_seed.sql        # Modernized target schema + data
├── queries/
│   ├── 01_reconciliation.sql
│   ├── 02_referential_integrity.sql
│   ├── 03_transformation_validation.sql
│   ├── 04_security_validation.sql
│   └── 05_performance_validation.sql
└── strategy/
    ├── migration_test_strategy.md        # One-page test strategy + KPIs
    ├── pii_access_control_checklist.md   # PII security validation checklist
    └── performance_sla_and_load.md       # Response-time SLA + load approach
```

## Skills Demonstrated

Source-to-target reconciliation · referential-integrity validation · ETL /
field-mapping validation · PII / security validation · query-performance
(execution-plan) analysis · test strategy, KPIs, and go/no-go criteria.

## Author

Keoni Kakugawa — QA & Release Management Leader
20+ years of QA, data validation, and release delivery experience
[GitHub](https://github.com/keonikaku) · [LinkedIn](https://www.linkedin.com/in/keonikaku)
