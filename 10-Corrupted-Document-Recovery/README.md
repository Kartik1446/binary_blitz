# Corrupted Document Recovery

**Category:** Forensics / File Carving & Hex Repair  
**Difficulty:** Hard  

---

### Challenge Description
An intercepted document `Corrupt.pdf` contains mission-critical intelligence. However, the file structure has been deliberately sabotaged!

Key dictionary tags and internal object references have had bytes altered, and compressed Flate streams fail to decompress in standard PDF readers. Repair the corrupted binary structure to recover the hidden contents.

### Provided Files
- `Corrupt.pdf`: Damaged binary PDF file (14,895 bytes).

### Objective
1. Inspect `Corrupt.pdf` using a hex editor or binary inspection utility.
2. Locate and correct damaged PDF dictionary headers and object tags.
3. Repair corrupted compressed stream structures or extract the displayable stream content.
4. Render the repaired document to view the flag.

### Flag Format
```
Flag{...}
```
