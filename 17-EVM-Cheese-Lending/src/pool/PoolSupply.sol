// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/interfaces/IERC20.sol";
import "./PoolState.sol";

/// @notice Supply and withdraw only. Pulls underlying, updates internal supply balance; no supply receipt token.
abstract contract PoolSupply is PoolState {

    bool invariant_supply = true;

    function supply(address asset, uint256 amount) external virtual  invariants(msg.sender) {
        ReserveData storage r = reserves[asset];
        require(r.underlying != address(0), "asset not listed");
        // We apply the CEI pattern
        // Cheese Eating Indigestion
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        userSupplyBalance[msg.sender][asset] += amount;
        r.totalSupplied += amount;


        require(r.totalSupplied <= SUPPLY_CAP);
    }

    function withdraw(address asset, uint256 amount, address to) external virtual  invariants(msg.sender) {
        ReserveData storage r = reserves[asset];
        require(r.underlying != address(0), "asset not listed");
        require(userSupplyBalance[msg.sender][asset] >= amount, "insufficient supply");
        IERC20(asset).transfer(to, amount);
        userSupplyBalance[msg.sender][asset] -= amount;
        r.totalSupplied -= amount;

        require(isHealthy(msg.sender));
    }

    function withdrawAll(address asset, uint256 amount, address to) external virtual  invariants(msg.sender) {
        ReserveData storage r = reserves[asset];
        require(r.underlying != address(0), "asset not listed");
        require(userSupplyBalance[msg.sender][asset] >= amount, "insufficient supply");
        IERC20(asset).transfer(to, userSupplyBalance[msg.sender][asset]);
        r.totalSupplied -= userSupplyBalance[msg.sender][asset];
        userSupplyBalance[msg.sender][asset] = 0;

        require(isHealthy(msg.sender));
    }

    function invariant(address user) internal  override virtual {
        super.invariant(user);

        bool invariant0 = IERC20(assets[0]).balanceOf(address(this)) <= SUPPLY_CAP;
        bool invariant1 = IERC20(assets[1]).balanceOf(address(this)) <= SUPPLY_CAP; 

        invariant_supply = invariant0 && invariant1;
    }

}
