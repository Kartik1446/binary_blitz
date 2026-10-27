// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-ctf/CTFDeployer.sol";

import "src/Challenge.sol";

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        challenge = address(new Challenge{value: 11.337 ether}(player));

        vm.stopBroadcast();
    }
}
