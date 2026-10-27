// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {SentinelGate} from './SentinelGate.sol';

contract Challenge {
  SentinelGate public immutable GATE;

  constructor(address _player) payable {
    GATE = new SentinelGate(address(this));

    GATE.depositFor{value: msg.value}(_player);

    GATE.addToBlacklist(_player);
  }

  function isSolved() external view returns (bool) {
    return address(GATE).balance == 0;
  }
}
