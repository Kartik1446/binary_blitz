// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'forge-ctf/CTFDeployer.sol';

import 'src/EchoModule.sol';
import 'src/Challenge.sol';

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        EchoModule echoModuleRef = new EchoModule();
        challenge = address(new Challenge{value: 10 ether}(address(echoModuleRef)));

        vm.stopBroadcast();
    }
}
