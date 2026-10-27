// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFSolver.sol";
import "src/Challenge.sol";
import "src/RedMemory.sol";

contract Solve is CTFSolver {
    function solve(address challengeAddress, address player) internal override {
        Challenge challenge = Challenge(challengeAddress);
        RedMemory redMemory = challenge.redMemory();

        // YOUR EXPLOIT HERE
    }
}
