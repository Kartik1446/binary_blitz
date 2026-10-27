// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IGuard {
    function canExecute(address) external returns (bool);
}

contract SimpleSafe {
    address[] public owners;
    uint256 public threshold;
    uint256 public nonce;
    address public guard;

    mapping(bytes32 => mapping(address => bool)) public hasApproved;

    error NotEnoughApprovals();
    error ExecutionFailed();
    error NotOwner();
    error NoOwners();
    error InvalidThreshold();
    error CantExecute();

    constructor(address[] memory _owners, uint256 _threshold, address _guard) payable {
        if (_owners.length == 0) revert NoOwners();
        if (_threshold == 0 || _threshold > _owners.length) revert InvalidThreshold();

        owners = _owners;
        threshold = _threshold;
        guard = _guard;
    }

    function approveHash(bytes32 txHash) external {
        if (!_isOwner(msg.sender)) revert NotOwner();
        hasApproved[txHash][msg.sender] = true;
    }

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bytes memory result) {
        bytes32 txHash = _hashTx(to, value, data, nonce);

        uint256 approvals;
        for (uint256 i = 0; i < owners.length; i++) {
            if (hasApproved[txHash][owners[i]]) approvals++;
        }
        if (approvals < threshold) revert NotEnoughApprovals();

        nonce++;

        bool success;

        if (guard != address(0)) {
            if (!IGuard(guard).canExecute(msg.sender)) revert CantExecute();
        }

        (success, result) = to.call{value: value}(data);
        if (!success) revert ExecutionFailed();
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function hashTx(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 _nonce
    ) external view returns (bytes32) {
        return _hashTx(to, value, data, _nonce);
    }

    function _hashTx(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 _nonce
    ) internal view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, address(this), to, value, data, _nonce));
    }

    function _isOwner(address addr) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == addr) return true;
        }
        return false;
    }

    receive() external payable {}
}
