# EVM: Pigeon Relay

**Category:** Web3 / Smart Contract Security  
**Difficulty:** Medium-Hard  

---

### Challenge Description
> *"A friend once told me pigeons make for wondrous message carriers, as long as they rest. Else, he said, they can become exhausted."*

`Pigeon.sol` relays signed execution payloads to a `SimpleSafe` smart wallet. Examine the message validation flow and execution delegation to take control of the wallet.

### Provided Files
- `src/Challenge.sol`: Verification contract.
- `src/Pigeon.sol`: Message relay contract.
- `src/SimpleSafe.sol`: Smart wallet implementation.
- `script/Deploy.s.sol`: Deployment script.
- `foundry.toml` & `remappings.txt`: Build configurations.
- `SETUP.md`: Dependency setup instructions.

### Objective
Exploit context confusion in the execution delegation to seize control or drain `SimpleSafe`, satisfying `challenge.isSolved() == true`.

### Flag Format
Submit upon achieving `challenge.isSolved() == true`.
