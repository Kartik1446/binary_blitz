# Magician's Secret (LSB Steganography)

**Category:** Forensics / Spatial Image Steganography  
**Difficulty:** Medium-Hard  

---

### Challenge Description
An innocent-looking high-resolution artwork (`STEGANOGRAPHY.png`, 1372x1500 resolution, RGBA) harbors a secret message. A digital magician has embedded a covert token across the least significant bits of the pixel color channels.

Build an extraction script or utilize steganography tools to recover the hidden token.

### Provided Files
- `STEGANOGRAPHY.png`: High-resolution PNG image (3,718,045 bytes).

### Objective
Analyze the spatial bit planes across the image color channels (Red, Green, Blue) to extract the hidden byte sequence.

### Flag Format
Wrap the recovered secret keyword in the competition format:
```
BB{<SECRET>_stego_revealed}
```
*(Example: If the keyword found was `ALOHOMORA`, the flag would be `BB{ALOHOMORA_stego_revealed}`)*
