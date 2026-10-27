// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface ICannonGuard {
    function validateAndConsume(
        address capsule,
        uint256 value
    ) external returns (bool);

    function isCapsuleValid(address capsule) external view returns (bool);
}

interface ITransactionCapsule {
    function target() external view returns (address);
    function selector() external view returns (bytes4);
}

/// @title Safe Smart Wallet
/// @notice A simplified Safe-style smart wallet with Cannon Guard integration
/// @dev Used as an EIP-7702 delegation target for regional reserves.
///      Supports owner-gated execution and capsule-based pre-approved transactions.
contract SafeSmartWallet {
    address public owner;       
    address public guard;       
    bool public initialized;    

    event TransactionExecuted(address indexed to, uint256 value, bytes data);
    event CapsuleTransactionExecuted(address indexed capsule, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Initialize the wallet with an owner and guard
    /// @param _owner The wallet owner
    /// @param _guard The Cannon Guard contract address
    function initialize(address _owner, address _guard) external {
        require(!initialized, "Already initialized");
        owner = _owner;
        guard = _guard;
        initialized = true;
    }

    /// @notice Execute a transaction (owner only)
    /// @param to Target contract address
    /// @param value ETH value to send
    /// @param data Calldata for the transaction
    function execTransaction(address to, uint256 value, bytes calldata data)
        external
        onlyOwner
        returns (bool)
    {
        (bool success,) = to.call{value: value}(data);
        require(success, "Transaction failed");
        emit TransactionExecuted(to, value, data);
        return true;
    }

    /// @notice Execute a pre-approved capsule transaction
    /// @param capsuleAddress The address of the TransactionCapsule to use
    /// @param params The ABI-encoded function parameters
    function executeApprovedCapsule(
        address capsuleAddress,
        bytes calldata params
    ) external payable returns (bool) {
        require(guard != address(0), "No guard set");

        // Validate and consume the capsule through the guard
        bool valid = ICannonGuard(guard).validateAndConsume(
            capsuleAddress,
            msg.value
        );
        require(valid, "Capsule validation failed");

        // Read the approved operation details from the capsule
        address target = ITransactionCapsule(capsuleAddress).target();
        bytes4 sel = ITransactionCapsule(capsuleAddress).selector();

        // Construct calldata: capsule's selector + caller's parameters
        bytes memory data = abi.encodePacked(sel, params);

        // Execute the transaction as this wallet
        (bool success,) = target.call{value: msg.value}(data);
        require(success, "Capsule transaction failed");

        emit CapsuleTransactionExecuted(capsuleAddress, target, msg.value);
        return true;
    }

    receive() external payable {}
}
