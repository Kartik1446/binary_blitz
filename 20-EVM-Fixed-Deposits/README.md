# EVM: Fixed Deposits

**Category:** Web3 / Smart Contract Security (Vault Share Accounting)  
**Difficulty:** Hard  

---

### Challenge Description
The Fixed Deposits contract allows users to deposit and lock assets to earn annualized yield upon maturity. The vault holds 500,000 tokens in reserve.

A flaw in share accounting allows an attacker to manipulate share redemption ratios. Exploit the protocol to steal at least half of the initial vault reserves.

### Provided Files
- `src/Challenge.sol`: Main challenge contract.
- `src/CtfDepositToken.sol`: Vault token.
- `src/DepositVault.sol`: Vault logic.
- `script/Deploy.s.sol`: Deployment script.
- `SETUP.md`: Setup instructions.

### Objective
Exploit the deposit vault share calculation to extract at least half of the vault's initial balance and trigger `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
