// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Batch Executor
/// @notice Modern batch execution infrastructure for reserves
/// @dev Used by regional reserves to batch multiple administrative operations.
///      Supports owner-based access control and optional allowance delegation
///      from partner reserves for cross-regional coordination.
contract BatchExecutor {
    /// @notice Owner of this batch executor instance
    address public owner; 

    /// @notice Optional allowance source for delegated minting authority
    /// @dev If set, this address is also authorized to execute batches.
    ///      The source reserve delegates its operational authority by calling delegateAllowance().
    address public allowanceSource; 

    /// @notice Whether this executor has been initialized
    bool public initialized; 

    /// @notice Struct representing a single call in a batch
    struct Call {
        address target;   // The contract to call
        uint256 value;    // ETH value to send with the call
        bytes data;       // Calldata for the call
    }

    event BatchExecuted(uint256 callCount);
    event AllowanceDelegated(address indexed source);
    event AllowanceDelegationRevoked(address indexed revokedSource);

    modifier onlyAuthorized() {
        require(msg.sender == owner || msg.sender == allowanceSource, "Not authorized");
        _;
    }

    /// @notice Initialize the batch executor
    /// @param _owner The owner address
    function initialize(address _owner) external {
        require(!initialized, "Already initialized");
        owner = _owner;
        initialized = true;
    }

    /// @notice Delegate your minting allowance to this reserve
    /// @dev Called by the SOURCE reserve on the beneficiary's BatchExecutor.
    ///      The caller (source) authorizes this reserve to mint using their MRC allowance.
    ///      This is a bilateral action: the source must actively call this function
    ///      to consent to sharing their allowance.
    function delegateAllowance() external {
        require(allowanceSource == address(0), "Delegation already active");
        allowanceSource = msg.sender;
        emit AllowanceDelegated(msg.sender);
    }

    /// @notice Revoke an active allowance delegation
    /// @dev Only the source reserve that delegated their allowance can revoke it
    function revokeAllowanceDelegation() external {
        require(msg.sender == allowanceSource || msg.sender == owner, "Only source or owner can revoke");
        emit AllowanceDelegationRevoked(allowanceSource);
        allowanceSource = address(0);
    }

    /// @notice Execute multiple calls in a single transaction
    /// @dev All calls are executed atomically - if any fails, the entire batch reverts
    /// @param calls Array of Call structs defining the operations to execute
    /// @return results Array of return data from each call
    function executeBatch(Call[] calldata calls) external payable onlyAuthorized returns (bytes[] memory results) {
        results = new bytes[](calls.length);

        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = calls[i].target.call{value: calls[i].value}(calls[i].data);
            require(success, "BatchExecutor: call failed");
            results[i] = result;
        }

        emit BatchExecuted(calls.length);
        return results;
    }

    /// @notice Fallback to accept ETH
    receive() external payable {}
}
