# EVM: Encoded Spell

**Category:** Web3 / Smart Contract Security (ABI Encoding & Calldata)  
**Difficulty:** Medium-Hard  

---

### Challenge Description
> *"Powerful spells require intricate incantations. Only well-versed wizards know how to weave bytes together without provoking the runes."*

A smart contract security puzzle centered on EVM low-level calldata formatting, selector validation, and ABI decoding.

### Provided Files
- `src/Challenge.sol`: Spell validation contract.
- `script/Deploy.s.sol`: Deployment script.
- `foundry.toml`: Project configuration.

### Objective
Craft and submit an encoded calldata payload that satisfies the spell verification conditions and triggers `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
