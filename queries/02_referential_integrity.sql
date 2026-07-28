-- =====================================================================
-- 02_referential_integrity.sql   (VALIDATED)
-- Orphan detection: accounts whose customer_id points to a customer that
-- does not exist in the modernized platform (foreign key with no parent).
-- LEFT JOIN keeps every account; WHERE ... IS NULL isolates the unmatched ones.
-- Result: account 111 -> customer 11 (dropped in migration) -> FAIL, orphan caught.
-- =====================================================================

SELECT a.account_id, a.customer_id
FROM accounts AS a
LEFT JOIN customers AS c
       ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
