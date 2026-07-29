-- =====================================================================
-- 06_referential_integrity_control.sql   (VALIDATED — PASSES)
-- The control for 02. Identical technique — LEFT JOIN ... WHERE key IS NULL —
-- pointed at a different relationship: transactions -> accounts.
--
-- Why a passing check is worth committing: a validation suite in which every
-- check fails is indistinguishable from a validation suite that is broken.
-- Nothing in an all-red report tells you whether the checks discriminate or
-- simply always return red. This one reports clean against a relationship that
-- migrated intact, which is what makes the orphan caught by 02 evidence.
--
-- Result: 0 rows -> PASS, every transaction resolves to a real account.
-- =====================================================================

SELECT t.transaction_id, t.account_id
FROM transactions AS t
LEFT JOIN accounts AS a
       ON t.account_id = a.account_id
WHERE a.account_id IS NULL;
