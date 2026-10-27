// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/interfaces/IERC20.sol";
import "./PoolState.sol";


/// @notice Liquidate underwater positions: liquidator repays user debt and receives user supply balance as collateral (at a bonus).
abstract contract PoolLiquidation is PoolState {
    uint256 public constant LIQUIDATION_BONUS_BPS = 1000; // 10%

    bool invariant_liquidation = true;

    function liquidate(address collateralAsset, address debtAsset, address user, uint256 amount) external virtual  invariants(user) {
        require(reserves[collateralAsset].underlying != address(0) && reserves[debtAsset].underlying != address(0), "asset not listed");
        _accrueDebt(user, debtAsset);

        uint256 debtValue = _getDebtValue(user);
        uint256 collateralValue = _getCollateralValue(user);
        require(collateralValue < debtValue, "not underwater");


        // Cap the max available debt
        uint256 userDebt = debtPrincipal[user][debtAsset];
        if (amount > userDebt){
            amount = userDebt;
        }

        // Copute the debt value
        uint256 debtValueRepaid = amount * price[debtAsset];
        uint256 userCollateral = userSupplyBalance[user][collateralAsset];

        // Liquidation bonus
        uint256 collateral = (debtValueRepaid * (10000 + LIQUIDATION_BONUS_BPS)) / 10000;
        collateral = (collateral + price[collateralAsset] - 1) / price[collateralAsset];

        // Cap the max available collateral
        // Cancel the debt and take all the collateral if above
        debtPrincipal[user][debtAsset] = collateral <= userCollateral ? userDebt - amount : 0;
        userSupplyBalance[user][collateralAsset] =  collateral <= userCollateral ? userCollateral -  collateral : 0;

        debtLastUpdate[user][debtAsset] = block.timestamp;

        reserves[debtAsset].totalDebt -= userDebt - debtPrincipal[user][debtAsset];
        _settleLiquidation(collateralAsset, debtAsset, msg.sender, amount, collateral);

        // Ensure the pool has the assets it claims it has
        require(IERC20(assets[0]).balanceOf(address(this)) >= reserves[assets[0]].totalSupplied);
        require(IERC20(assets[1]).balanceOf(address(this)) >= reserves[assets[1]].totalSupplied);
    }

    function _settleLiquidation(
      address collateralAsset, address debtAsset, address user, uint256 debt, uint256 collateral
    ) internal {
        IERC20(debtAsset).transferFrom(user, address(this), debt);
        reserves[debtAsset].totalSupplied += debt;
        IERC20(collateralAsset).transfer(user, collateral);
        reserves[collateralAsset].totalSupplied -= collateral;
    } 

    function invariant(address user) internal override virtual {
        super.invariant(user);

        bool invariant0 = debtPrincipal[user][assets[0]] <= reserves[assets[0]].totalDebt;
        bool invariant1 = debtPrincipal[user][assets[1]] <= reserves[assets[1]].totalDebt;

        invariant_liquidation = invariant0 && invariant1;
    }
}
