-- =====================================================================
-- 03_transformation_validation.sql   (Day 3 — VALIDATED)
-- Validate the transformed status field end to end.
--   legacy.acct_status (INT: 1=ACTIVE, 2=DORMANT, 3=CLOSED)
--   -> modern.account_status (TEXT enum)
-- CASE encodes the mapping rule; WHERE ... <> ... keeps only mismatches.
-- Catches mis-mapped values AND out-of-domain (illegal) values.
-- Result: 103 (DORMANT->CLOSED), 107 (DORMANT->ACTIVE), 109 (CLOSED->INACTIVE, invalid) -> FAIL.
-- Note: join key was renamed in migration — legacy acct_id = modern account_id.
-- =====================================================================

SELECT a.account_id,
       la.acct_status AS legacy_code,
       CASE la.acct_status
            WHEN 1 THEN 'ACTIVE'
            WHEN 2 THEN 'DORMANT'
            WHEN 3 THEN 'CLOSED'
       END AS expected_status,
       a.account_status AS actual_status
FROM accounts AS a
JOIN legacy_accounts AS la ON a.account_id = la.acct_id
WHERE a.account_status <> CASE la.acct_status
                              WHEN 1 THEN 'ACTIVE'
                              WHEN 2 THEN 'DORMANT'
                              WHEN 3 THEN 'CLOSED'
                          END;
