// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./pool/PoolSupply.sol";
import "./pool/PoolLend.sol";
import "./pool/PoolFlash.sol";
import "./pool/PoolLiquidation.sol";

/// @notice CTF entry + main pool
contract CheeseLending is PoolSupply, PoolFlash, PoolLiquidation, PoolLend {
    address public immutable PLAYER;
    bool private solved;

    constructor(address player, address gruyere, address emmental) {
        PLAYER = player;
        _initReserve(gruyere, 1);
        _initReserve(emmental, 2);
    }

    function check_invariant(address user) public{
        invariant(user);
    }

    function solve() external {
        solved = !(invariant_supply && invariant_lending && invariant_liquidation && invariant_flash);
    }

    function isSolved() external view returns (bool) {
        return solved;
    }

    function invariant(address user) internal override(PoolFlash, PoolLiquidation, PoolLend, PoolSupply) {
        super.invariant(user);
    }

}
