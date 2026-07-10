-- =====================================================================
-- 04_security_validation.sql   (Day 4 — VALIDATED — PRIORITY area)
-- PII exposure check: confirm NO sensitive field survived migration in
-- human-readable plaintext. Hashed values are 64-char hex; plaintext SSN
-- is shaped ___-__-____ and plaintext DOB is shaped ____-__-__.
-- Checks BOTH ssn and date_of_birth — never assume a field is clean.
-- Result: David Chang (customer 5) — SSN and DOB both plaintext -> FAIL
--         (critical, cutover-blocking compliance defect).
-- =====================================================================

SELECT customer_id, first_name, last_name, ssn, date_of_birth
FROM customers
WHERE ssn LIKE '___-__-____'
   OR date_of_birth LIKE '____-__-__';

-- Reusable pattern: run one plaintext-shape check per PII field in scope.
-- Extend the WHERE with OR <field> LIKE '<shape>' for every sensitive column
-- (phone, account/routing numbers, etc.) identified in the data model.
