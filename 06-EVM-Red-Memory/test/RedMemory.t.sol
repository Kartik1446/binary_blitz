// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/Challenge.sol";
import "src/RedMemory.sol";

contract RedMemoryTest is Test {
    Challenge challenge;
    RedMemory redMemory;
    address player;

    function setUp() public {
        player = makeAddr("player");

        vm.prank(player);
        challenge = new Challenge(player);
        redMemory = challenge.redMemory();
    }

    function testExploit() public {
        vm.startPrank(player);

        // YOUR EXPLOIT HERE

        vm.stopPrank();

        assertTrue(challenge.isSolved(), "Challenge not solved");
    }
}
