-- =====================================================================
-- modern_seed.sql
-- "Modernized" core banking schema + data (post-migration TARGET)
-- Target engine: SQLite 3
--
-- This is the migration target. It intentionally DRIFTS from legacy so the
-- validation queries have real defects to find. Seeded defects (do not
-- "fix" these — they are the test material):
--
--   [D1] Row-count mismatch  : customer 11 (Momi Kahale) dropped in migration
--                              -> customers 11 rows vs legacy 12
--   [D2] Orphaned FK         : account 111 still references customer 11 (gone)
--   [D3] Transform errors    : acct_status int -> account_status string
--                              103: 2(dormant) mapped to 'CLOSED'   (wrong)
--                              107: 2(dormant) mapped to 'ACTIVE'   (wrong)
--                              109: 3(closed)  mapped to 'INACTIVE' (invalid/unmapped value)
--   [D4] NULL violations     : email NULL for customer 3 and customer 8
--                              (modern schema intends NOT NULL)
--   [D5] PII in plaintext    : customer 5 (David Chang) ssn left as raw
--                              501/505 plaintext instead of hashed
--   [D6] Duplicate rows      : transactions 1003 and 1009 duplicated
--                              -> transactions 17 rows vs legacy 15
--   [D7] Balance mismatch    : account 105 balance differs from legacy
-- =====================================================================

PRAGMA foreign_keys = ON;   -- modern system intends to enforce integrity

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS account_balances;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

-- ---------- customers -------------------------------------------------
-- PII (ssn, date_of_birth) should be HASHED (64-char hex) post-migration.
-- email intended NOT NULL (see [D4] defects that violate this).
CREATE TABLE customers (
    customer_id    INTEGER PRIMARY KEY,
    first_name     TEXT NOT NULL,
    last_name      TEXT NOT NULL,
    ssn            TEXT,     -- should be a 64-char hash, never plaintext
    date_of_birth  TEXT,     -- should be a 64-char hash, never plaintext
    email          TEXT,     -- intended NOT NULL; defects present
    last_updated   TEXT
);

-- customer 11 (Momi Kahale) intentionally NOT migrated -> [D1]
INSERT INTO customers (customer_id, first_name, last_name, ssn, date_of_birth, email, last_updated) VALUES
(1,  'James',   'Kealoha',  '9f2c1a7b4e6d8039c5a1f0b2d7e4c6389a0b1c2d3e4f5061728394a5b6c7d8e9', 'a1b2c3d4e5f60718293a4b5c6d7e8f90112233445566778899aabbccddeeff00', 'james.k@example.com',   '2024-06-01 09:00:00'),
(2,  'Leilani', 'Naauao',   'b73e9d0c1a2f8465d7e0c9b8a6f5e4d3c2b1a0918273645564738291a0b1c2d3', 'c2d3e4f5061728394a5b6c7d8e9f00112233445566778899aabbccddeeff0011', 'leilani.n@example.com', '2024-06-01 09:00:00'),
(3,  'Keanu',   'Makoa',    'a0918273645564738291a0b1c2d3b73e9d0c1a2f8465d7e0c9b8a6f5e4d3c2b1', 'd3e4f5061728394a5b6c7d8e9f00112233445566778899aabbccddeeff001122',  NULL,                   '2024-06-01 09:00:00'), -- [D4] email lost
(4,  'Malia',   'Fern',     'c2b1a0918273645564738291a0b1c2d3b73e9d0c1a2f8465d7e0c9b8a6f5e4d3', 'e4f5061728394a5b6c7d8e9f00112233445566778899aabbccddeeff00112233', 'malia.f@example.com',   '2024-06-01 09:00:00'),
(5,  'David',   'Chang',    '505-56-7890', '1979-09-12', 'david.c@example.com',   '2024-06-01 09:00:00'),                                                                                                                     -- [D5] PII plaintext!
(6,  'Nohea',   'Lindsey',  'd3c2b1a0918273645564738291a0b1c2b73e9d0c1a2f8465d7e0c9b8a6f5e4d3', 'f5061728394a5b6c7d8e9f00112233445566778899aabbccddeeff0011223344', 'nohea.l@example.com',   '2024-06-01 09:00:00'),
(7,  'Kai',     'Watanabe', 'e4d3c2b1a0918273645564738291a0b1b73e9d0c1a2f8465d7e0c9b8a6f5e4d3', '061728394a5b6c7d8e9f00112233445566778899aabbccddeeff001122334455', 'kai.w@example.com',     '2024-06-01 09:00:00'),
(8,  'Hoku',    'Palakiko', 'f5e4d3c2b1a0918273645564738291a0b73e9d0c1a2f8465d7e0c9b8a6f5e4d3', '1728394a5b6c7d8e9f00112233445566778899aabbccddeeff00112233445566',  NULL,                   '2024-06-01 09:00:00'), -- [D4] email NULL
(9,  'Aiko',    'Tanaka',   '0615e4d3c2b1a0918273645564738291b73e9d0c1a2f8465d7e0c9b8a6f5e4d3', '28394a5b6c7d8e9f00112233445566778899aabbccddeeff0011223344556677', 'aiko.t@example.com',    '2024-06-01 09:00:00'),
(10, 'Bruno',   'Silva',    '17280615e4d3c2b1a0918273645564738b73e9d0c1a2f8465d7e0c9b8a6f5e4d', '394a5b6c7d8e9f00112233445566778899aabbccddeeff001122334455667788', 'bruno.s@example.com',   '2024-06-01 09:00:00'),
(12, 'Ronson',  'Ige',      '2839017280615e4d3c2b1a09182736455b73e9d0c1a2f8465d7e0c9b8a6f5e4d', '4a5b6c7d8e9f00112233445566778899aabbccddeeff0011223344556677889a', 'ronson.i@example.com',  '2024-06-01 09:00:00');

-- ---------- accounts --------------------------------------------------
-- account_status is now a STRING enum: ACTIVE / DORMANT / CLOSED
-- Correct mapping: 1->ACTIVE, 2->DORMANT, 3->CLOSED
CREATE TABLE accounts (
    account_id      INTEGER PRIMARY KEY,
    customer_id     INTEGER,
    account_status  TEXT,             -- ACTIVE / DORMANT / CLOSED
    opened_date     TEXT,
    last_updated    TEXT
);

INSERT INTO accounts (account_id, customer_id, account_status, opened_date, last_updated) VALUES
(101, 1,  'ACTIVE',   '2010-05-01', '2024-06-01 09:00:00'),
(102, 1,  'ACTIVE',   '2012-08-15', '2024-06-01 09:00:00'),
(103, 2,  'CLOSED',   '2015-03-20', '2024-06-01 09:00:00'),   -- [D3] legacy=2 dormant, should be DORMANT
(104, 3,  'CLOSED',   '2009-11-11', '2024-06-01 09:00:00'),
(105, 5,  'ACTIVE',   '2018-01-05', '2024-06-01 09:00:00'),
(106, 6,  'ACTIVE',   '2020-07-19', '2024-06-01 09:00:00'),
(107, 7,  'ACTIVE',   '2016-09-30', '2024-06-01 09:00:00'),   -- [D3] legacy=2 dormant, should be DORMANT
(108, 8,  'ACTIVE',   '2011-04-22', '2024-06-01 09:00:00'),
(109, 9,  'INACTIVE', '2013-12-01', '2024-06-01 09:00:00'),   -- [D3] legacy=3 closed, invalid enum value
(110, 10, 'ACTIVE',   '2019-06-14', '2024-06-01 09:00:00'),
(111, 11, 'ACTIVE',   '2021-02-28', '2024-06-01 09:00:00'),   -- [D2] customer 11 does not exist in modern -> orphan
(112, 12, 'DORMANT',  '2017-10-10', '2024-06-01 09:00:00');

-- ---------- account_balances -----------------------------------------
CREATE TABLE account_balances (
    account_id    INTEGER,
    balance       REAL,
    last_updated  TEXT
);

INSERT INTO account_balances (account_id, balance, last_updated) VALUES
(101, 1240.00, '2024-08-01 02:00:00'),
(102, 3000.00, '2024-08-01 02:00:00'),
(103,  -50.00, '2024-08-01 02:00:00'),
(104,  100.00, '2024-08-01 02:00:00'),
(105, -700.00, '2024-08-01 02:00:00'),   -- [D7] legacy had -950.00
(106,  500.00, '2024-08-01 02:00:00'),
(107,  -75.00, '2024-08-01 02:00:00'),
(108, 2500.00, '2024-08-01 02:00:00'),
(109, -300.00, '2024-08-01 02:00:00'),
(110,  800.00, '2024-08-01 02:00:00'),
(111, -150.00, '2024-08-01 02:00:00'),
(112, 1000.00, '2024-08-01 02:00:00');

-- ---------- transactions ---------------------------------------------
CREATE TABLE transactions (
    transaction_id    INTEGER PRIMARY KEY,
    account_id        INTEGER,
    amount            REAL,
    transaction_type  TEXT,
    transaction_date  TEXT
);

INSERT INTO transactions (transaction_id, account_id, amount, transaction_type, transaction_date) VALUES
(1001, 101,  1500.00, 'DEPOSIT',    '2023-01-05 10:15:00'),
(1002, 101,  -200.00, 'WITHDRAWAL', '2023-01-10 11:30:00'),
(1003, 102,  3000.00, 'DEPOSIT',    '2023-02-01 09:00:00'),
(1004, 103,   -50.00, 'WITHDRAWAL', '2023-02-15 16:45:00'),
(1005, 104,   100.00, 'DEPOSIT',    '2023-03-01 08:20:00'),
(1006, 105, -1200.00, 'WITHDRAWAL', '2023-03-20 13:10:00'),
(1007, 106,   500.00, 'DEPOSIT',    '2023-04-02 12:05:00'),
(1008, 107,   -75.00, 'WITHDRAWAL', '2023-04-18 15:40:00'),
(1009, 108,  2500.00, 'DEPOSIT',    '2023-05-09 10:55:00'),
(1010, 109,  -300.00, 'WITHDRAWAL', '2023-05-25 14:25:00'),
(1011, 110,   800.00, 'DEPOSIT',    '2023-06-11 11:00:00'),
(1012, 111,  -150.00, 'WITHDRAWAL', '2023-06-30 17:20:00'),
(1013, 112,  1000.00, 'DEPOSIT',    '2023-07-14 09:35:00'),
(1014, 101,   -60.00, 'WITHDRAWAL', '2023-07-22 18:00:00'),
(1015, 105,   250.00, 'DEPOSIT',    '2023-08-03 10:10:00'),
-- [D6] duplicate rows introduced during migration (new surrogate ids, same business txn)
(1016, 102,  3000.00, 'DEPOSIT',    '2023-02-01 09:00:00'),   -- dup of 1003
(1017, 108,  2500.00, 'DEPOSIT',    '2023-05-09 10:55:00');   -- dup of 1009

-- Modern summary (target counts, with drift):
--   customers        : 11   (legacy 12)  -> [D1]
--   accounts         : 12
--   account_balances : 12
--   transactions     : 17   (legacy 15)  -> [D6]
