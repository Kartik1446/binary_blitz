// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/interfaces/IERC20.sol";
import "./PoolState.sol";

import {console} from "forge-std/console.sol";


/// @notice Borrow and repay only. Collateral = supply balance × fixed prices; debt accrues time-based interest.
abstract contract PoolLend is PoolState {

    bool invariant_lending = true;

    function borrow(address asset, uint256 amount) external virtual invariants(msg.sender) {
        ReserveData storage r = reserves[asset];
        require(r.underlying != address(0), "asset not listed");
        _accrueDebt(msg.sender, asset);

        IERC20(asset).transfer(msg.sender, amount);
        debtPrincipal[msg.sender][asset] += amount;
        r.totalDebt += amount;
        debtLastUpdate[msg.sender][asset] = block.timestamp;

        r.totalSupplied -= amount;

        require(r.totalSupplied > 1); // Minimal cap

        require(isHealthy(msg.sender), "Not healthy");
    }

    function repay(address asset, uint256 amount) external virtual  invariants(msg.sender) {
        ReserveData storage r = reserves[asset];
        require(r.underlying != address(0), "asset not listed");
        _accrueDebt(msg.sender, asset);

        uint256 debt = debtPrincipal[msg.sender][asset];

        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        // Cap to prevent underflow
        if (amount <= debt)
        {
            debtPrincipal[msg.sender][asset] -= amount;
        }
        else {
            debtPrincipal[msg.sender][asset] = 0;
        }

        debtLastUpdate[msg.sender][asset] = block.timestamp;

        r.totalSupplied += amount;
        r.totalDebt -= debt - debtPrincipal[msg.sender][asset];

    }

    function invariant(address user) internal override virtual {
        super.invariant(user);

        bool condition0 = reserves[assets[0]].totalSupplied != 0 ||reserves[assets[0]].totalDebt != 0;
        bool condition1 = reserves[assets[1]].totalSupplied != 0 ||reserves[assets[1]].totalDebt != 0; 

        invariant_lending = condition0 && condition1;
    }
}
