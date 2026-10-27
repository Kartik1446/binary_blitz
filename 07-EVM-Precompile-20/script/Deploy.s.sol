// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFDeployer.sol";
import "src/Precompile20.sol";
import "src/Challenge.sol";

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        Precompile20 precompile20 = new Precompile20(system);

        address alice = address(0xA11CE);
        address bob = address(0xB0B);
        address carl = address(0xCA1);

        precompile20.adminMint(alice, 1 ether);
        precompile20.adminMint(bob, 1 ether);
        precompile20.adminMint(carl, 1 ether);
        precompile20.adminMint(player, 2 ether);

        challenge = address(new Challenge(player, precompile20));

        vm.stopBroadcast();
    }
}
