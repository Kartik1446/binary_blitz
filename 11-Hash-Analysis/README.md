# Hash Analysis

**Category:** Cryptography / PDF Forensics & Hash Cracking  
**Difficulty:** Medium-Hard  

---

### Challenge Description
The document `HASH.pdf` appears unremarkable on the surface, but standard text copy-pasting fails to extract the underlying text. Cryptographic hashes have been encoded into the document's internal font CMap tables (Adobe-Identity-UCS `ToUnicode` mapping streams).

Extract the underlying hash values, identify the hash algorithms, and crack the plaintexts.

### Provided Files
- `HASH.pdf`: PDF document containing encoded font CMaps.

### Objective
1. Analyze the internal streams of `HASH.pdf` to recover the true character mapping.
2. Extract the hidden MD5 and SHA-1 hash strings.
3. Recover the original plaintext values using dictionary or brute-force cracking tools.

### Flag Format
```
BB{<cracked_plaintext>}
```
