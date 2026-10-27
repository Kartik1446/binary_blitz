# EVM: Meridian Credits

**Category:** Web3 / Smart Contract Security (Smart Accounts & Governance)  
**Difficulty:** Hard  

---

### Challenge Description
Seven star systems on the galaxy's outer rim formed the Meridian Concordat, governed by autonomous smart accounts and CannonGuard security modules.

Exploit account recovery logic and batch execution to bypass guard controls and seize the reserves.

### Provided Files
- `src/AccountRecovery.sol`, `src/BatchExecutor.sol`, `src/CannonGuard.sol`: Security modules.
- `src/Challenge.sol`: Challenge gatekeeper.
- `src/MeridianCredits.sol`: Token contract.
- `src/SafeSmartWallet.sol`: Smart wallet implementation.
- `foundry.toml` & `SETUP.md`: Build and setup files.

### Objective
Bypass the governance module and drain credits to satisfy `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
