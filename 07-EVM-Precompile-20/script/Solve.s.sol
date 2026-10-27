// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFSolver.sol";
import "src/Challenge.sol";
import "src/Precompile20.sol";

contract Solve is CTFSolver {
    function solve(address _challenge, address player) internal override {
        Challenge challenge = Challenge(_challenge);
        Precompile20 precompile20 = challenge.precompile20();

        // YOUR EXPLOIT HERE
    }
}
