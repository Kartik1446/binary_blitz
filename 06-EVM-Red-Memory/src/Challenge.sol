// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/RedMemory.sol";

contract Challenge {
    address public immutable PLAYER;
    RedMemory public redMemory;

    constructor(address player) {
        PLAYER = player;
        redMemory = new RedMemory();
    }

    function isSolved() external view returns (bool) {
        return redMemory.obtained();
    }
}
