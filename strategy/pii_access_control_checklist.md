# PII Access-Control & Security Validation Checklist
### Legacy on-prem → modernized core banking platform · Day 4 artifact

Purpose: the SQL check in `queries/04_security_validation.sql` proves PII is protected
**at rest** (stored hashed, never plaintext). Protecting PII is broader than that — it
also means controlling **who** can read it and **where** it lives. This checklist is
what a Test Manager validates and signs off before cutover.

---

## 1. Data protection at rest  — *(automated, validated today)*
- [ ] Every PII field is hashed/encrypted; no value stored in human-readable plaintext.
- [ ] Coverage is **per the data dictionary** — every sensitive column, not just SSN
      (SSN, date of birth, and any phone / account / routing numbers in scope).
- [ ] Re-validated after every migration/ETL re-run.
- **Pass criteria:** zero rows returned by the plaintext-shape check across all PII fields.
- **Finding:** David Chang — SSN *and* DOB in plaintext. Cutover blocker until remediated.

## 2. Role-based access (least privilege)
- [ ] PII columns are readable only by explicitly authorized roles/service accounts.
- [ ] No blanket admin or analyst role can read raw PII by default.
- [ ] Separation of duties enforced (the role that migrates data ≠ the role that reads PII).
- **How to validate:** attempt to query a PII column as a non-privileged role → access denied.

## 3. Environment separation
- [ ] Real PII exists **only in production**.
- [ ] Dev / test / UAT use **masked or synthetic** data, never a copy of production PII.
- **How to validate:** run the plaintext-shape check *and* a "does real PII exist here at all"
      check in each non-production environment → expect none.

## 4. Encryption in transit
- [ ] PII travels only over encrypted channels (TLS) between application tiers.
- [ ] The migration/ETL pipeline itself moves PII over encrypted connections.

## 5. Audit trail  — *(stretch)*
- [ ] Every read and write of a PII field is logged: **who** accessed **which record/field,
      when, and from where**.
- [ ] Audit logs are tamper-evident and retained per the bank's retention policy.
- **How to validate:** access a PII record in a controlled test, then confirm an audit entry
      was generated containing all required fields.

## 6. Migration-specific controls
- [ ] The masking/hashing step covers **all** PII fields and **all** records — no code path
      skips a record (this is exactly how the David Chang leak occurred).
- [ ] A post-migration PII scan (section 1) is a mandatory gate in the cutover runbook.

---

### Sign-off criteria
No plaintext PII anywhere in the target · access restricted to authorized roles · non-prod
environments carry no real PII · audit logging active. **Any plaintext PII = automatic
no-go for cutover.**
