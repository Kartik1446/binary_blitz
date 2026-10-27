# EVM: Ludopathy

**Category:** Web3 / Smart Contract Security (On-Chain Randomness)  
**Difficulty:** Medium-Hard  

---

### Challenge Description
A betting contract holding 15 ETH in its prize pool. The winning number has been selected by an on-chain algorithm.

Can you predict the dice roll and drain the bankroll?

### Provided Files
- `src/Challenge.sol`: Verification contract.
- `src/Ludopathy.sol`: Betting game contract.
- `script/Deploy.s.sol`: Deployment script.
- `SETUP.md`: Setup commands.

### Objective
Exploit on-chain state variables to consistently win bets and reduce the contract balance below 1 ETH, satisfying `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
