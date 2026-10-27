// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract EchoModule {
  function ping() external pure returns (string memory) {
    return 'pong';
  }

  function decommission() external {
    selfdestruct(payable(msg.sender));
  }
}
