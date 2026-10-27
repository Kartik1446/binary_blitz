# Tokyo Metro Statement Analysis

**Category:** OSINT / Railway Forensics & Deduction  
**Difficulty:** Medium-Hard  

---

### Challenge Description
> Nihar is a professional who lives in Tokyo and is in a dilemma. In 2017, he was late to an important meeting and is now facing severe repercussions. To defend himself, he needs to prove that it was not his fault.
> 
> His evidence? The train he boarded that day, traveling between **Omotesandō** and **Suitengūmae**, was severely delayed. However, his employer is not providing the specific details of the accusation. Nihar vividly remembers one key fact: **The train was around 61 minutes late.**
> 
> Help him uncover the exact date of the incident and the start time of the delay from official historical railway records. Justice for Nihar!

### Provided Files
- `Statement Analysis.docx`: Official challenge document.
- `Statement Analysis(Easy).pdf`: PDF version of problem statement.
- `story challenge.txt`: Plaintext summary.

### Objective
1. Identify the transit line serving Omotesandō and Suitengūmae stations.
2. Investigate historical 2017 Tokyo transit delay certificates (遅延証明書) and transport ministry records.
3. Identify the date and incident start time for the ~61-minute disruption.

### Flag Format
```
PFSWT{time_date}
```
*(Example format: `PFSWT{14:30_15March}`)*
