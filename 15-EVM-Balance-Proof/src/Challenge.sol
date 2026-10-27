// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "eigenlayer/libraries/BeaconChainProofs.sol";

contract Challenge {
    address public constant EIP_4788_ORACLE = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    bool public isSolved;

    constructor(address) {}

    function solve(
        uint64 beaconTimestamp,
        BeaconChainProofs.BalanceContainerProof calldata balanceContainerProof,
        uint40 validatorIndex,
        BeaconChainProofs.BalanceProof calldata balanceProof
    ) external {
        // Fetch a beacon block root from the EIP-4788 oracle
        (bool success, bytes memory data) = EIP_4788_ORACLE.staticcall(abi.encode(beaconTimestamp));
        require(success && data.length == 32, "Invalid beacon timestamp");
        bytes32 beaconBlockRoot = abi.decode(data, (bytes32));

        // Use the EigenLayer library to prove the validator balance
        BeaconChainProofs.verifyBalanceContainer(beaconBlockRoot, balanceContainerProof);
        uint64 balance = BeaconChainProofs.verifyValidatorBalance(
            balanceContainerProof.balanceContainerRoot,
            validatorIndex,
            balanceProof
        );

        // The proven balance must be at least 100_000 ETH (balance value is in gwei terms)
        require(balance >= 100_000_000_000_000, "Proven balance is too low");

        isSolved = true;
    }
}
