# EVM: Precompile 20

**Category:** Web3 / Smart Contract Security  
**Difficulty:** Hard  

---

### Challenge Description
> *"You have 2 ETH, need 5. Can you find a way?"*

`Precompile20.sol` introduces a custom state precompile into the EVM execution environment. Study the balance calculation logic and find an edge case in the state transition mechanism to mint the required balance.

### Provided Files
- `src/Challenge.sol`: Verification contract.
- `src/Precompile20.sol`: Precompile contract.
- `script/Deploy.s.sol` & `script/Solve.s.sol`: Script harnesses.
- `test/Precompile20.t.sol`: Foundry test suite.
- `foundry.toml`: Project configuration.

### Objective
Execute a sequence of calls that inflates your balance to at least 5 ETH so that `challenge.isSolved()` returns `true`.

### Flag Format
Trigger `challenge.isSolved() == true` on your instance.
