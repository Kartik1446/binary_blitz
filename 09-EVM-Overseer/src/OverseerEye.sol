// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {IOverseer} from "./interfaces/IOverseer.sol";

abstract contract OverseerEye {
    error FolkNotEnrolled();

    IOverseer public immutable overseer;

    mapping(bytes32 => mapping(bytes16 => bool)) internal _rankByBadge;

    constructor(IOverseer _overseer) {
        overseer = _overseer;
    }

    function hasRank(bytes32 _rank, address _folk) public view virtual returns (bool) {
        bytes16 _badge = overseer.folkToBadge(_folk);
        return _rankByBadge[_rank][_badge];
    }

    function _grantRank(bytes32 _rank, address _folk) internal virtual returns (bytes16 _badge) {
        _badge = overseer.folkToBadge(_folk);
        if (_badge == bytes16(0)) revert FolkNotEnrolled();
        if (!_rankByBadge[_rank][_badge]) _rankByBadge[_rank][_badge] = true;
    }

    function _revokeRank(bytes32 _rank, address _folk) internal virtual returns (bytes16 _badge) {
        _badge = overseer.folkToBadge(_folk);
        if (_badge == bytes16(0)) revert FolkNotEnrolled();
        if (_rankByBadge[_rank][_badge]) _rankByBadge[_rank][_badge] = false;
    }
}
