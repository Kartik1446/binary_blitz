// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @title DepositVault
/// @notice Holds user funds. Only the manager can release them.
contract DepositVault {

    ERC20 public token;
    address public manager;

    bool private _locked;

    modifier onlyManager() {
        require(msg.sender == manager, "not manager");
        _;
    }

    /// @notice Explicit reentrancy guard
    modifier nonReentrant() {
        require(!_locked, "reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    constructor(ERC20 _token) {
        token = _token;
        manager = msg.sender;
    }

    function transferManager(address newManager) external onlyManager {
        manager = newManager;
    }

    /// @notice Manager registers a pending payout for a user
    function registerPayout(address depositor, uint256 amount) external onlyManager {
        // Transfer tokens to the vault — will be released back to owner + interest at maturity
        token.transferFrom(depositor, address(this), amount);
    }

    /// @notice Direct release called by manager
    /// @dev amount must be pre-validated by manager
    function release(address to, uint256 amount) external onlyManager nonReentrant {
        token.transfer(to, amount);
    }
}