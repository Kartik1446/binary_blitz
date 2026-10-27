pragma solidity 0.8.33;

import "./EVMVM.sol";

contract Challenge {
    address public immutable PLAYER;

    EVMVM public evmvm;

    constructor (address player) {
        PLAYER = player;
        evmvm = new EVMVM();
    }

    function isSolved() external view returns (bool) {
        return evmvm.owner() == PLAYER;
    }
}
