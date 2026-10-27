// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFDeployer.sol";

import "src/Challenge.sol";
import "src/Pigeon.sol";

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        challenge = address(new Challenge{value: 10 ether}(player, system));
        Pigeon(payable(address(Challenge(challenge).pigeonProxy()))).band(player, 2 ether);

        vm.stopBroadcast();
    }
}
