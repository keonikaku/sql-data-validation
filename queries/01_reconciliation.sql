-- =====================================================================
-- 01_reconciliation.sql   (VALIDATED)
-- Source-to-target record count reconciliation, legacy vs modern, per table.
-- Non-zero delta = records lost (positive) or duplicated (negative) in migration.
-- Result: customers -1 (loss), transactions +2 (duplicates) -> FAIL, defects caught.
-- =====================================================================

SELECT 'customers' AS table_name,
       (SELECT COUNT(*) FROM legacy_customers) AS legacy_count,
       (SELECT COUNT(*) FROM customers)        AS modern_count,
       (SELECT COUNT(*) FROM legacy_customers) - (SELECT COUNT(*) FROM customers) AS delta
UNION ALL
SELECT 'accounts',
       (SELECT COUNT(*) FROM legacy_accounts),
       (SELECT COUNT(*) FROM accounts),
       (SELECT COUNT(*) FROM legacy_accounts) - (SELECT COUNT(*) FROM accounts)
UNION ALL
SELECT 'account_balances',
       (SELECT COUNT(*) FROM legacy_account_balances),
       (SELECT COUNT(*) FROM account_balances),
       (SELECT COUNT(*) FROM legacy_account_balances) - (SELECT COUNT(*) FROM account_balances)
UNION ALL
SELECT 'transactions',
       (SELECT COUNT(*) FROM legacy_transactions),
       (SELECT COUNT(*) FROM transactions),
       (SELECT COUNT(*) FROM legacy_transactions) - (SELECT COUNT(*) FROM transactions);
