# Njeromin - The Gateway

**Category:** Forensics / Image Steganography  
**Difficulty:** Medium-Hard  

---

### Challenge Description
> *"The given image contains a secret message. Decode this message to enter in the world of Binary Blitz. Hint: Steganography"*

A massive 7.7MB PNG image `Njeromin.png` (1920x2400 resolution) guards the entrance to the competition. Hidden within the pixel bitstream is the passphrase required to breach the perimeter.

### Provided Files
- `Njeromin.png`: High-resolution PNG image (7,726,903 bytes).
- `README.txt`: Official challenge hint.

### Objective
Perform pixel bitplane analysis across the image channels to uncover the embedded keyword.

### Flag Format
Wrap the recovered keyword in the competition format:
```
BB{<KEYWORD>_njeromin_hidden}
```
*(Example: If the keyword found was `CYBER`, the flag would be `BB{CYBER_njeromin_hidden}`)*
