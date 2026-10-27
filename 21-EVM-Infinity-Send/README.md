# EVM: Infinity Send

**Category:** Web3 / Smart Contract Security (Token Distribution Logic)  
**Difficulty:** Medium-Hard  

---

### Challenge Description
The treasury has deployed a token distribution system that validates every transfer request before forwarding it to the multi-sig.

Craft a transaction payload that passes initial validation but causes downstream execution to revert unexpectedly.

### Provided Files
- `src/Challenge.sol`: Forwarding & validation contract.
- `src/InfinityToken.sol`: ERC-20 token contract.
- `SETUP.md`: Environment setup instructions.

### Objective
Submit calldata to `Challenge.sendMoney()` that passes validation but causes `MoneyMoves` to revert, setting `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
