// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {IFolk} from "../interfaces/IFolk.sol";
import {IOverseer} from "../interfaces/IOverseer.sol";
import {SealedVault} from "./SealedVault.sol";

interface ISealedGuild {
    function badge() external view returns (bytes16);
}
contract SealedTurncloak is SealedVault, IFolk layout at 10 {
    error AlreadyInitialized();
    error AlreadyUnsealed();
    error InvalidProof();
    error InvalidVerdict();

    bytes32 public constant DECREE_VOTED = keccak256("DECREE_VOTED");

    IOverseer public immutable overseer;
    bytes16 public badge;
    address public guild;
    bytes16 public guildBadge;

    mapping(bytes16 => bool) public unsealed;

    constructor(IOverseer _overseer) {
        overseer = _overseer;
        badge = _overseer.enroll();
    }

    function setGuild(address _guild) external {
        if (guild != address(0)) revert AlreadyInitialized();
        guild = _guild;
        guildBadge = ISealedGuild(_guild).badge();
    }

    function unseal(bytes16 _decreeId, uint8 _verdict, uint256 _proof) external {
        if (_verdict == 0 || _verdict > 3) revert InvalidVerdict();
        if (unsealed[_decreeId]) revert AlreadyUnsealed();
        if (!_verifyProof(_proof)) revert InvalidProof();

        unsealed[_decreeId] = true;

        overseer.oversee(
            badge,
            guildBadge,
            DECREE_VOTED,
            bytes32(_decreeId),
            abi.encode(_decreeId, _verdict)
        );
    }

    function write(bytes16, bytes32, bytes32, bytes calldata) external override {}
}
