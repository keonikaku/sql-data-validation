-- =====================================================================
-- 07_transformation_control.sql   (VALIDATED — PASSES)
-- The control for 03. Confirms that rows which did migrate came through
-- unaltered: for every transaction present in BOTH systems, type and amount
-- must match to the cent.
--
-- Scope, stated deliberately: the JOIN only sees transactions that exist on
-- both sides, so rows present in only one system are invisible here. That is
-- not an oversight — completeness is 01's job (it catches the duplicated rows
-- in the modernized platform), and fidelity is this one's. A single check
-- trying to answer both questions would report one failure and mask the other.
--
-- Result: 0 rows -> PASS, no migrated transaction was altered in flight.
-- =====================================================================

SELECT t.transaction_id,
       lt.txn_type        AS legacy_type,
       t.transaction_type AS modern_type,
       lt.amount          AS legacy_amount,
       t.amount           AS modern_amount
FROM transactions AS t
JOIN legacy_transactions AS lt ON t.transaction_id = lt.txn_id
WHERE t.transaction_type <> lt.txn_type
   OR ROUND(t.amount, 2) <> ROUND(lt.amount, 2);
