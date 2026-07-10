# Performance / Response-Time Validation — SLA & Load Approach
### Legacy on-prem → modernized core banking platform · Day 5 artifact

Correctness is not enough. A migration can pass reconciliation, integrity, transformation,
and security and still fail in production because performance regressed — most often because
an **index was not recreated** (indexes are separate objects from the data). This defines the
response-time bar to hold before cutover.

---

## 1. How we detect it (validated today)
- Use `EXPLAIN QUERY PLAN` on hot-path queries to read the plan without needing production
  volume or a stopwatch.
- `SCAN <table>` = full table scan (reads every row) → red flag on a filtered lookup.
- `SEARCH <table> USING INDEX ...` = jumps straight to the matches → healthy.
- **Finding:** the account → transactions lookup does a full `SCAN` — index not migrated.
  Correct data, slow query. Cutover risk once volume is real.

## 2. Response-time SLA targets
**Absolute thresholds** (from customer/business expectations, measured at p95):

| Operation                    | p95 target |
|------------------------------|-----------|
| Balance inquiry              | < 200 ms  |
| 90-day transaction history   | < 1 s     |
| Login / authentication       | < 500 ms  |
| Funds transfer (write)       | < 800 ms  |

**Relative / no-regression rule:** for the same logical query, modern p95 ≤ legacy baseline
(within a small tolerance). Capture legacy baselines *before* cutover to compare against.

**Measure at percentiles, not averages** — p95 / p99. Averages hide the slow tail, and the
slow tail is the angry customer.

## 3. Cutover gate
- Block cutover if any hot-path operation exceeds its p95 target, **or** regresses more than
  an agreed % versus the legacy baseline.
- Require an index-coverage check (section 1) on every hot-path query as a runbook gate.

## 4. Load & concurrency (stretch)
Single-query speed is necessary but not sufficient. Validate under concurrent load at peak
banking windows (payday, month-end, close of business):
- Simulate realistic concurrent mixes — balance checks, history pulls, transfers — at
  projected peak volumes.
- Confirm p95/p99 targets **hold under load**, and that there are no deadlocks, timeouts, or
  connection-pool exhaustion.
- Ramp to find the breaking point (headroom above expected peak).

**Experience tie-in:** this mirrors validating a live SQL backend under real-time,
high-concurrency data ingestion at Telescope — proving the system stays both correct and
responsive when many operations hit simultaneously, not just in isolation.
