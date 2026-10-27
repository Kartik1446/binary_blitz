// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/interfaces/IERC20.sol";
import "./PoolState.sol";

interface IFlashBorrowReceiver {
    function executeOperation(address asset, uint256 amount, uint256 fee, bytes calldata params) external returns (bool);
}

/// @notice Flash loan: transfer asset to receiver, callback, require repayment of amount + fee.
abstract contract PoolFlash is PoolState {

    bool invariant_flash = true;

    function flashLoan(address receiver, address asset, uint256 amount, bytes calldata params) external virtual invariants(receiver) {
        ReserveData storage r = reserves[asset];
        require(r.underlying != address(0), "asset not listed");
        require(r.totalDebt == 0, "can only flash loan if there is no debt");
        require(amount <= 1e18, "flash loan cap");
        
        uint256 balanceBefore = IERC20(asset).balanceOf(address(this));

        uint256 fee = (amount / 10000); // 0.01% fee
        flashInProgress = true;

        IERC20(asset).transfer(receiver, amount);

        r.totalSupplied -= amount;
        require(IFlashBorrowReceiver(receiver).executeOperation(asset, amount, fee, params), "callback failed");

        uint balanceNow = IERC20(asset).balanceOf(address(this)) - fee;
        require(balanceNow >= balanceBefore + fee, "repay with fee required");
        r.totalSupplied = balanceNow;
        
        flashInProgress = false;
    }

    function invariant(address user) internal  override virtual {
        // TODO: implement a flash loan invariant
    }
}
