# SQL Data Validation Suite — Core Banking Migration

An interactive, browser-based data-validation suite that proves a data migration
from a **legacy on-premises system** to a **modernized platform** moved data
completely, correctly, securely, and without performance regression.

**▶ Live demo:** <https://keonikaku.github.io/sql-data-validation/>

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

## Why two checks pass

The suite runs **7 checks: 2 pass, 5 fail.** The failures are the seeded defects
being caught, and the dashboard says so above the results.

The two passing checks are there on purpose. **A validation suite in which every
check fails is indistinguishable from a validation suite that is broken** — an
all-red report tells you nothing about whether the checks discriminate or simply
always return red. Each passing check uses the *same technique* as a failing
neighbour, against part of the migration that came through clean:

| Control | Mirrors | Technique |
|---|---|---|
| Transaction ownership (`06`) | Orphaned accounts (`02`) | `LEFT JOIN ... WHERE key IS NULL` |
| Transaction fidelity (`07`) | Account status mapping (`03`) | source-vs-target field comparison |

Neither was produced by weakening an existing check or by editing the seed data.
They are new checks against relationships that genuinely reconcile.

## How To View

**Option A — just open it:** download `index.html` and open it in any browser.
Everything (SQLite engine + both databases) is embedded in the single file.

**Option B — live URL:** <https://keonikaku.github.io/sql-data-validation/>,
served by GitHub Pages from this repository.

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
│   ├── 05_performance_validation.sql
│   ├── 06_referential_integrity_control.sql   # passes — control for 02
│   └── 07_transformation_control.sql          # passes — control for 03
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
20+ years in software, 15 in QA, ~6 in release management
[GitHub](https://github.com/keonikaku) · [LinkedIn](https://www.linkedin.com/in/keonikaku)
