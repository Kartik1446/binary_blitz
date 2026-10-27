# EVM: EVMVM (Virtual Machine in EVM)

**Category:** Web3 / Smart Contract Security (Custom VM / Bytecode Jailbreak)  
**Difficulty:** Very Hard  

---

### Challenge Description
We have EVMs on Solana, Cosmos, and as ZK circuits. But why has no one built an EVM inside an EVM? 

`EVMVM.sol` implements a full virtual machine inside Solidity, complete with custom opcodes, memory stack, and execution loops. Find a boundary flaw or execution exploit to escape the sandbox.

### Provided Files
- `src/Challenge.sol`: Verification contract.
- `src/EVMVM.sol`: Custom stack virtual machine.
- `script/Deploy.s.sol`: Deployment script.

### Objective
Exploit the virtual machine interpreter to escape sandbox constraints and make `challenge.isSolved()` return `true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
