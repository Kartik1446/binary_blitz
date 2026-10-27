# Fiftyville Mystery

**Category:** Database Forensics / SQL Investigation  
**Difficulty:** Medium  

---

### Challenge Description
A high-profile theft occurred on the morning of **July 28, 2021** on **Humphrey Street** in the town of Fiftyville. The CS50 duck has been taken!

Fiftyville's municipal records, security camera logs, financial transactions, phone calls, and airport passenger manifests have been consolidated into a relational database (`fiftyville.db`). 

As the lead forensic investigator, your task is to interrogate the database and uncover the conspiracy:
1. **Who is the THIEF?**
2. **Which CITY did the thief escape to?**
3. **Who is the ACCOMPLICE** who purchased the flight ticket?

### Provided Files
- `fiftyville.db`: SQLite3 database containing 10 interconnected tables (`crime_scene_reports`, `interviews`, `atm_transactions`, `bank_accounts`, `bakery_security_logs`, `phone_calls`, `passengers`, `flights`, `airports`, `people`).
- `log.sql`: Scratchpad to document your investigative SQL queries.
- `answers.txt`: Verification template for your findings.

### Objective
Construct SQL queries to correlate evidence across witness interview transcripts, parking lot exit cameras, ATM cash withdrawals, phone call durations, and flight manifests to solve the crime.

### Flag Format
```
BB{Thief_City_Accomplice}
```
*(Example: `BB{JohnDoe_London_JaneSmith}`)*
