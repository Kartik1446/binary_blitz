# EVM: Red Memory

**Category:** Web3 / Smart Contract Security (Transient Storage & Memory)  
**Difficulty:** Hard  

---

### Challenge Description
> *"The hearts beat, disembodied, to the rhythm of the chants. A claw of red ink lacerates color from your sight. The tremors creep into your soul and like a log you snap. The room fades into crimson gates. It's time to get good."*

A low-level EVM exploitation challenge centered on execution state transitions, transient storage semantics, and memory boundary conditions.

### Provided Files
- `src/Challenge.sol`: Verification contract.
- `src/RedMemory.sol`: Target contract.
- `script/Deploy.s.sol`: Deployment harness.
- `script/Solve.s.sol`: Solution template (`// YOUR EXPLOIT HERE`).
- `test/RedMemory.t.sol`: Foundry local test runner.
- `foundry.toml`: Project configuration.

### Objective
Implement an exploit in `test/RedMemory.t.sol` or `script/Solve.s.sol` to satisfy:
```solidity
redMemory.obtained() == true
```

### Flag Format
Trigger `challenge.isSolved() == true` on your challenge instance.
