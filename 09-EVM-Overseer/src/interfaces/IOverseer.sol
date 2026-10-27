// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

interface IOverseer {
    function oversee(
        bytes16 fromBadge,
        bytes16 toBadge,
        bytes32 activity,
        bytes32 subject,
        bytes calldata data
    ) external;

    function enroll() external returns (bytes16);

    function proposeBadgeChange(address newFolk) external;

    function acceptBadgeChange(bytes16 badge) external;

    function generateBadgeId(address folk, uint256 nonce) external view returns (bytes16);

    function badgeToFolk(bytes16 badge) external view returns (address);

    function badgeToProposedFolk(bytes16 badge) external view returns (address);

    function folkToBadge(address folk) external view returns (bytes16);

    function enrolledBadges(bytes16 badge) external view returns (bool);

    function registeredFolk(address folk) external view returns (bool);

    function activeBadges(bytes16 badge) external view returns (bool);
}
