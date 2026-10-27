// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ludopathy} from './Ludopathy.sol';

contract Challenge {
    Ludopathy public immutable ludopathy;

    constructor(Ludopathy _ludopathy) {
        ludopathy = _ludopathy;
    }

    function isSolved() external view returns (bool) {
        return address(ludopathy).balance < 1 ether;
    }
}
