# EVM: Liquid Omens

**Category:** Web3 / DeFi Security (Liquidation Engine & Bad Debt)  
**Difficulty:** Very Hard  

---

### Challenge Description
The omen monks run a venue bound by strict rites, signatures, and canon. One borrower is already underwater. One reserve is still full.

Something in the liquidation liturgy is less rigid than it appears. Exploit directive preview calculations to clear the debt and claim the reserve.

### Provided Files
- `src/BadDebtMarket.sol`: Market contract.
- `src/Challenge.sol`: Gatekeeper contract.
- `src/DirectivePreviewLib.sol`: Math preview library.
- `src/LiquidationEngine.sol`: Core engine.
- `src/LiquidationVenue.sol`: Venue contract.

### Objective
Drain sufficient `oUSD` from the venue reserve to satisfy `Challenge.isSolved() == true`.

### Flag Format
Satisfy `challenge.isSolved() == true` on your instance.
