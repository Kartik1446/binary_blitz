// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Transaction Capsule
/// @notice One-time-use transaction authorization contract
/// @dev Each capsule represents a single pre-approved operation.
///      Stores the approved target, function selector, and max ETH value.
///      The wallet reads these fields to construct the outbound call.
///      "Every transaction is its own smart contract."
contract TransactionCapsule {
    address public immutable wallet;
    address public immutable target;
    bytes4 public immutable selector;
    uint256 public immutable maxValue;
    address public immutable guard;

    bool public consumed;

    constructor(
        address _wallet,
        address _target,
        bytes4 _selector,
        uint256 _maxValue,
        address _guard
    ) {
        wallet = _wallet;
        target = _target;
        selector = _selector;
        maxValue = _maxValue;
        guard = _guard;
    }

    /// @notice Validate the capsule can be used by this wallet with this value
    /// @dev Called by the guard during capsule consumption. Marks capsule as consumed.
    /// @param _wallet The wallet attempting to use this capsule
    /// @param _value The ETH value of the transaction
    /// @return True if the capsule is authorized for this wallet and value
    function validate(
        address _wallet,
        uint256 _value
    ) external returns (bool) {
        require(msg.sender == guard, "Only guard");
        require(!consumed, "Capsule already consumed");
        require(_wallet == wallet, "Wrong wallet");
        require(_value <= maxValue, "Value exceeds maximum");

        consumed = true;
        return true;
    }
}

/// @title Cannon Guard
/// @notice Capsule-based transaction guard for smart wallets
/// @dev The commander pre-approves operations by deploying TransactionCapsule contracts.
contract CannonGuard {
    address public commander;

    mapping(address => address[]) internal _walletCapsules;
    mapping(address => bool) public isCapsule;

    event CapsuleCreated(
        address indexed wallet,
        address indexed capsule,
        address target,
        bytes4 selector,
        uint256 maxValue
    );
    event CapsuleConsumed(address indexed capsule, address indexed wallet);

    constructor(address _commander) {
        commander = _commander;
    }

    /// @notice Deploy a new transaction capsule authorizing a specific operation
    /// @param wallet The wallet this capsule is for
    /// @param target The allowed target contract
    /// @param selector The allowed function selector
    /// @param maxValue Maximum ETH value for the operation
    /// @return capsuleAddr The address of the deployed capsule
    function createCapsule(
        address wallet,
        address target,
        bytes4 selector,
        uint256 maxValue
    ) external returns (address capsuleAddr) {
        require(msg.sender == commander, "Only commander");

        TransactionCapsule capsule = new TransactionCapsule(
            wallet, target, selector, maxValue, address(this)
        );

        capsuleAddr = address(capsule);
        _walletCapsules[wallet].push(capsuleAddr);
        isCapsule[capsuleAddr] = true;

        emit CapsuleCreated(wallet, capsuleAddr, target, selector, maxValue);
    }

    /// @notice Validate and consume a capsule for a transaction
    /// @param capsule The capsule address to validate against
    /// @param value The ETH value
    /// @return True if validation passed and capsule was consumed
    function validateAndConsume(
        address capsule,
        uint256 value
    ) external returns (bool) {
        require(isCapsule[capsule], "Unknown capsule");

        bool valid = TransactionCapsule(capsule).validate(msg.sender, value);
        require(valid, "Capsule validation failed");

        emit CapsuleConsumed(capsule, msg.sender);
        return true;
    }

    /// @notice Check if a capsule is valid and unconsumed
    function isCapsuleValid(address capsule) external view returns (bool) {
        if (!isCapsule[capsule]) return false;
        return !TransactionCapsule(capsule).consumed();
    }

    /// @notice Get all capsules for a wallet
    function getCapsules(address wallet) external view returns (address[] memory) {
        return _walletCapsules[wallet];
    }

    /// @notice Get capsule count for a wallet
    function getCapsuleCount(address wallet) external view returns (uint256) {
        return _walletCapsules[wallet].length;
    }
}
