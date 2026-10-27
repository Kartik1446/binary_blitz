// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFDeployer.sol";

import "src/Challenge.sol";
import "src/CtfDepositToken.sol";
import "src/DepositVault.sol";

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        CtfDepositToken token = new CtfDepositToken();
        DepositVault vault = new DepositVault(token);

        // Fund the vault with 500_000 tokens to pay interest
        token.transfer(address(vault), 500_000e18);
        // Give the player 20_000 tokens to work with
        token.transfer(player, 20_000e18);

        Challenge challengeContract = new Challenge(player, token, vault);
        challenge = address(challengeContract);

        // Transfer the vault manager role to the challenge contract
        vault.transferManager(challenge);

        vm.stopBroadcast();
    }
}