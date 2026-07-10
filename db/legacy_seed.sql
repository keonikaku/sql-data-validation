-- =====================================================================
-- legacy_seed.sql
-- "Legacy on-prem" core banking schema + data (pre-migration source)
-- Target engine: SQLite 3
--
-- This represents the ORIGINAL system: looser constraints, integer status
-- codes, and PII stored in plaintext (as older on-prem systems often did).
-- The modern_seed.sql is the post-migration target and deliberately drifts
-- from this source so validation queries have real defects to catch.
-- =====================================================================

PRAGMA foreign_keys = OFF;   -- legacy system did not enforce FKs

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS account_balances;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

-- ---------- customers -------------------------------------------------
-- PII (ssn, date_of_birth) stored in PLAINTEXT. email nullable.
CREATE TABLE customers (
    customer_id    INTEGER PRIMARY KEY,
    first_name     TEXT    NOT NULL,
    last_name      TEXT    NOT NULL,
    ssn            TEXT,               -- plaintext, e.g. 501-12-3456
    date_of_birth  TEXT,               -- plaintext YYYY-MM-DD
    email          TEXT,               -- nullable in legacy
    last_updated   TEXT
);

INSERT INTO customers (customer_id, first_name, last_name, ssn, date_of_birth, email, last_updated) VALUES
(1,  'James',   'Kealoha',  '501-12-3456', '1975-03-14', 'james.k@example.com',   '2023-11-01 09:12:00'),
(2,  'Leilani', 'Naauao',   '502-23-4567', '1982-07-22', 'leilani.n@example.com', '2023-11-01 09:12:00'),
(3,  'Keanu',   'Makoa',    '503-34-5678', '1990-11-05', 'keanu.m@example.com',   '2023-11-01 09:12:00'),
(4,  'Malia',   'Fern',     '504-45-6789', '1968-01-30', 'malia.f@example.com',   '2023-11-01 09:12:00'),
(5,  'David',   'Chang',    '505-56-7890', '1979-09-12', 'david.c@example.com',   '2023-11-01 09:12:00'),
(6,  'Nohea',   'Lindsey',  '506-67-8901', '1995-05-18', 'nohea.l@example.com',   '2023-11-01 09:12:00'),
(7,  'Kai',     'Watanabe', '507-78-9012', '1987-12-03', 'kai.w@example.com',     '2023-11-01 09:12:00'),
(8,  'Hoku',    'Palakiko', '508-89-0123', '1972-08-27',  NULL,                   '2023-11-01 09:12:00'), -- legacy allowed NULL email
(9,  'Aiko',    'Tanaka',   '509-90-1234', '1993-04-09', 'aiko.t@example.com',    '2023-11-01 09:12:00'),
(10, 'Bruno',   'Silva',    '510-01-2345', '1965-06-21', 'bruno.s@example.com',   '2023-11-01 09:12:00'),
(11, 'Momi',    'Kahale',   '511-12-3456', '1988-10-15', 'momi.k@example.com',    '2023-11-01 09:12:00'),
(12, 'Ronson',  'Ige',      '512-23-4567', '1980-02-28', 'ronson.i@example.com',  '2023-11-01 09:12:00');

-- ---------- accounts --------------------------------------------------
-- acct_status is an INTEGER CODE: 1=active, 2=dormant, 3=closed
CREATE TABLE accounts (
    acct_id       INTEGER PRIMARY KEY,
    customer_id   INTEGER,            -- FK -> customers.customer_id (not enforced)
    acct_status   INTEGER,            -- 1=active, 2=dormant, 3=closed
    opened_date   TEXT,
    last_updated  TEXT
);

INSERT INTO accounts (acct_id, customer_id, acct_status, opened_date, last_updated) VALUES
(101, 1,  1, '2010-05-01', '2024-02-10 14:00:00'),
(102, 1,  1, '2012-08-15', '2024-02-10 14:00:00'),
(103, 2,  2, '2015-03-20', '2024-02-10 14:00:00'),
(104, 3,  3, '2009-11-11', '2024-02-10 14:00:00'),
(105, 5,  1, '2018-01-05', '2024-02-10 14:00:00'),
(106, 6,  1, '2020-07-19', '2024-02-10 14:00:00'),
(107, 7,  2, '2016-09-30', '2024-02-10 14:00:00'),
(108, 8,  1, '2011-04-22', '2024-02-10 14:00:00'),
(109, 9,  3, '2013-12-01', '2024-02-10 14:00:00'),
(110, 10, 1, '2019-06-14', '2024-02-10 14:00:00'),
(111, 11, 1, '2021-02-28', '2024-02-10 14:00:00'),  -- customer 11 exists here (dropped in modern -> orphan)
(112, 12, 2, '2017-10-10', '2024-02-10 14:00:00');

-- ---------- account_balances -----------------------------------------
CREATE TABLE account_balances (
    acct_id       INTEGER,            -- FK -> accounts.acct_id (not enforced)
    balance       REAL,
    last_updated  TEXT
);

INSERT INTO account_balances (acct_id, balance, last_updated) VALUES
(101, 1240.00, '2024-08-01 02:00:00'),
(102, 3000.00, '2024-08-01 02:00:00'),
(103,  -50.00, '2024-08-01 02:00:00'),
(104,  100.00, '2024-08-01 02:00:00'),
(105, -950.00, '2024-08-01 02:00:00'),
(106,  500.00, '2024-08-01 02:00:00'),
(107,  -75.00, '2024-08-01 02:00:00'),
(108, 2500.00, '2024-08-01 02:00:00'),
(109, -300.00, '2024-08-01 02:00:00'),
(110,  800.00, '2024-08-01 02:00:00'),
(111, -150.00, '2024-08-01 02:00:00'),
(112, 1000.00, '2024-08-01 02:00:00');

-- ---------- transactions ---------------------------------------------
CREATE TABLE transactions (
    txn_id      INTEGER PRIMARY KEY,
    acct_id     INTEGER,             -- FK -> accounts.acct_id (not enforced)
    amount      REAL,
    txn_type    TEXT,                -- DEPOSIT / WITHDRAWAL
    txn_date    TEXT
);

INSERT INTO transactions (txn_id, acct_id, amount, txn_type, txn_date) VALUES
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
(1015, 105,   250.00, 'DEPOSIT',    '2023-08-03 10:10:00');

-- Legacy summary (source-of-truth counts):
--   customers        : 12
--   accounts         : 12
--   account_balances : 12
--   transactions     : 15
