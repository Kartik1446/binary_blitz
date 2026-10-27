# EVM: Blackout

**Category:** Web3 / Smart Contract Security (Bytecode & Access Control)  
**Difficulty:** Medium-Hard  

---

### Challenge Description
> *"The gates have eyes, and yours is a face they won't forget. Your funds sit on the other side, tantalizingly close. Perhaps it's time to wear a different mask. Same face, just... taller."*

`SentinelGate.sol` maintains a caller blacklist preventing your player address from withdrawing deposited funds. Find a method to bypass access control and reclaim the funds.

### Provided Files
- `src/Challenge.sol`: Challenge gatekeeper.
- `src/SentinelGate.sol`: Vault contract with blacklist.
- `script/Deploy.s.sol`: Deployment script.
- `SETUP.md`: Setup commands.

### Objective
Bypass the gatekeeper authorization check and retrieve the funds to satisfy `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
