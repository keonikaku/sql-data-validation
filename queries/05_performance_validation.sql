-- =====================================================================
-- 05_performance_validation.sql   (VALIDATED — PRIORITY area)
-- Validate query performance via EXPLAIN QUERY PLAN (no stopwatch / volume
-- needed — read the plan). A hot-path lookup must use an index, not scan.
-- SCAN = reads every row (slow at scale); SEARCH ... USING INDEX = jumps
-- straight to matches. A SCAN on a filtered column means an index was not
-- recreated during migration.
-- =====================================================================

-- 1) As migrated: how will the DB find one account's transactions?
EXPLAIN QUERY PLAN
SELECT t.transaction_id, t.amount, t.transaction_date
FROM transactions AS t
WHERE t.account_id = 105;
-- Result: "SCAN t"  -> FULL TABLE SCAN, index missing -> FAIL

-- 2) The fix the migration should have carried over:
CREATE INDEX idx_txn_acct ON transactions(account_id);

-- 3) Same query, re-planned:
EXPLAIN QUERY PLAN
SELECT t.transaction_id, t.amount, t.transaction_date
FROM transactions AS t
WHERE t.account_id = 105;
-- Result: "SEARCH t USING INDEX idx_txn_acct (account_id=?)" -> healthy

-- Interview point: correctness checks can all pass while performance fails,
-- because indexes are separate objects that migrations can drop.
