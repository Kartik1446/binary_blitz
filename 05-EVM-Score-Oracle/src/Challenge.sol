// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Oracle} from "src/Oracle.sol";
import {Score} from "src/Score.sol";

contract Challenge {
    address public immutable PLAYER;
    Oracle public immutable ORACLE;
    Score public immutable SCORE;

    constructor(address _player) payable {
        PLAYER = _player;
        ORACLE = new Oracle{value: 1.337 ether}();
        SCORE = new Score{value: 10 ether}(address(ORACLE), _player);
    }

    function isSolved() external view returns (bool) {
        return SCORE.isSolved();
    }
}
