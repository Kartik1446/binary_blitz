// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Precompile20} from './Precompile20.sol';

contract Challenge {
    Precompile20 public immutable precompile20;
    address public immutable PLAYER;

    constructor(address _player, Precompile20 _precompile20) {
        PLAYER = _player;
        precompile20 = _precompile20;
    }

    function isSolved() external view returns (bool) {
        return precompile20.balanceOf(PLAYER) >= 5 ether;
    }
}
