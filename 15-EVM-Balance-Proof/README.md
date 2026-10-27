# EVM: Balance Proof

**Category:** Web3 / Smart Contract Security (Beacon Chain SSZ & Merkle Proofs)  
**Difficulty:** Hard  

---

### Challenge Description
Can you prove a validator's balance is over 100,000 ETH?

The challenge contract relies on EIP-4788 (Beacon Block Root in EVM) and beacon chain proof libraries. You must construct a valid Merkle container proof against the beacon state to verify an exorbitant validator balance.

### Provided Files
- `src/Challenge.sol`: Main challenge contract.
- `script/Deploy.s.sol`: Deployment script.
- `foundry.toml`: Foundry configuration.
- `remappings.txt`: Dependency remappings.

### Objective
Call `solve()` with a valid beacon timestamp and `BalanceContainerProof` such that `challenge.isSolved()` returns `true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
