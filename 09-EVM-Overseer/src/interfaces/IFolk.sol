// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

interface IFolk {
    function write(bytes16 fromBadge, bytes32 activity, bytes32 subject, bytes calldata data) external;
}
