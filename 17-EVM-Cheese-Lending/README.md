# EVM: Cheese Lending

**Category:** Web3 / DeFi Security (Lending Pool & Oracles)  
**Difficulty:** Hard  

---

### Challenge Description
Welcome to Côte d'Azur's most exclusive DeFi fromage market. At CheeseLending, users collateralize artisanal cheese wheels to borrow stable assets. 

The protocol's creators claim their invariants are airtight and that there are "no holes in this system". Prove them wrong by breaking the lending invariants and draining the pool.

### Provided Files
- `src/Cheese.sol`: Token contract.
- `src/CheeseLending.sol`: Core lending protocol.
- `src/pool/`: Lending pool components.
- `script/Deploy.s.sol`, `script/Cow.s.sol`: Deployment scripts.

### Objective
Exploit pricing discrepancies, flash loans, or reentrancy to drain the lending pool reserves until `challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
