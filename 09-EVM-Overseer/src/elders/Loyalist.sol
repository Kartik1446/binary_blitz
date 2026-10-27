// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {IFolk} from "../interfaces/IFolk.sol";
import {IOverseer} from "../interfaces/IOverseer.sol";

interface ILoyalistGuild {
    function badge() external view returns (bytes16);
}

contract Loyalist is IFolk {
    error NotOwner();
    error AlreadyInitialized();
    error InvalidVerdict();

    bytes32 public constant DECREE_VOTED = keccak256("DECREE_VOTED");

    address public immutable owner;
    IOverseer public immutable overseer;
    bytes16 public badge;
    address public guild;
    bytes16 public guildBadge;

    constructor(IOverseer _overseer, address _owner) {
        owner = _owner;
        overseer = _overseer;
        badge = _overseer.enroll();
    }

    function setGuild(address _guild) external {
        if (guild != address(0)) revert AlreadyInitialized();
        guild = _guild;
        guildBadge = ILoyalistGuild(_guild).badge();
    }

    function vote(bytes16 _decreeId, uint8 _verdict) external {
        if (msg.sender != owner) revert NotOwner();
        if (_verdict == 0 || _verdict > 3) revert InvalidVerdict();

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
