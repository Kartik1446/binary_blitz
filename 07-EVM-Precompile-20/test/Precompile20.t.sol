// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/Challenge.sol";
import "src/Precompile20.sol";

contract Precompile20Test is Test {
    Challenge challenge;
    Precompile20 precompile20;
    address player;
    uint256 playerPk;

    function setUp() public {
        (player, playerPk) = makeAddrAndKey("player");
        address system = makeAddr("system");

        vm.startPrank(system);
        precompile20 = new Precompile20(system);

        address alice = address(0xA11CE);
        address bob = address(0xB0B);
        address carl = address(0xCA1);

        precompile20.adminMint(alice, 1 ether);
        precompile20.adminMint(bob, 1 ether);
        precompile20.adminMint(carl, 1 ether);
        precompile20.adminMint(player, 2 ether);

        challenge = new Challenge(player, precompile20);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(player);

        // YOUR EXPLOIT HERE

        vm.stopPrank();

        assertTrue(challenge.isSolved(), "Challenge not solved");
    }
}
