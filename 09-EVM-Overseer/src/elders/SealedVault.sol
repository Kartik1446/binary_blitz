// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

contract SealedVault {
    uint256 private _proof;

    constructor() {
        _proof = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, address(this))));
    }

    function _verifyProof(uint256 proof) internal view returns (bool) {
        return proof == _proof;
    }
}
