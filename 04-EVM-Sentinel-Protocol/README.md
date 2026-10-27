# EVM: Sentinel Protocol

**Category:** Web3 / Smart Contract Security  
**Difficulty:** Hard  

---

### Challenge Description
> *"Sentinel Vault only trusts code-verified operator modules. But trust is a snapshot, not a promise."*

The `SentinelVault` contract enforces strict module verification before granting asset execution. Analyze the interface boundaries and module registration logic to bypass verification and drain the vault.

### Provided Files
- `src/Challenge.sol`: Primary challenge contract.
- `src/SentinelVault.sol`: Core vault implementation.
- `src/EchoModule.sol`: Operator module.
- `src/interfaces/`: Interface specifications.
- `script/Deploy.s.sol`: Deployment harness.
- `foundry.toml`: Foundry build configuration.
- `SETUP.md`: Environment setup instructions.

### Objective
Interact with the contracts to bypass operator module authorization and drain the vault so that:
```solidity
challenge.isSolved() == true
```

### Flag Format
Submit your solve via the competition scoring portal or submit the on-chain verification token.
