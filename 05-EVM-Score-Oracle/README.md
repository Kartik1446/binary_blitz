# EVM: Score Oracle

**Category:** Web3 / DeFi Security  
**Difficulty:** Medium-Hard  

---

### Challenge Description
> *"The Oracle holds the key to a perfect score — but only if you can calibrate it just right. Study the numbers, find the pattern, and prove you've earned every point."*

`Oracle.sol` continuously evaluates spot reserve metrics to calculate a dynamic performance score. Your task is to manipulate the protocol's observed state to force the score to its maximum threshold.

### Provided Files
- `src/Challenge.sol`: Verification contract.
- `src/Score.sol`: Scoring engine.
- `src/Oracle.sol`: Metric oracle.
- `src/IOracle.sol` & `src/IScore.sol`: Interfaces.
- `script/Deploy.s.sol`: Deployment script.
- `foundry.toml`: Foundry configuration.
- `SETUP.md`: Setup commands.

### Objective
Calibrate the oracle measurements to reach a perfect score of 100 such that `challenge.isSolved()` returns `true`.

### Flag Format
Submit upon satisfying `challenge.isSolved() == true`.
