# Security Compliance Alert (Phishing Investigation)

**Category:** Web Forensics / DOM Steganography  
**Difficulty:** Easy-Medium  

---

### Challenge Description
An employee flagged an urgent email received in their corporate inbox:
> *"URGENT: Action Required - Mandatory 2025 Security Compliance Training"*

The notification claims credentials will be suspended unless an external training module is completed immediately. While the template mimics legitimate enterprise communications, anomalous indicators suggest a covert payload.

Investigate the email structure and styling to uncover what is hidden in plain sight.

### Provided Files
- `index.html`: Complete HTML source and stylesheet of the suspicious email.
- `ctf.png`: Corporate branding asset.

### Objective
Render and inspect the email's document structure, styling properties, and elements to uncover the secret token.

### Flag Format
```
flag{...}
```
