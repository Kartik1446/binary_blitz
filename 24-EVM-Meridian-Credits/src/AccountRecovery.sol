// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
/// @title Account Recovery V2
/// @notice Enhanced guardian-based account recovery system for regional reserves
/// @dev Upgraded version with improved event logging and owner migration support.
contract AccountRecovery is Initializable {
    struct RecoveryRequest {
        address newOwner;
        uint256 executeAfter;
        bool executed;
    }

    address public owner;                      
    mapping(address => bool) public guardians; 
    RecoveryRequest public pendingRecovery;    

    uint256 public constant RECOVERY_DELAY = 7 days;

    event GuardianAdded(address indexed guardian);
    event GuardianRemoved(address indexed guardian);
    event RecoveryInitiated(address indexed initiator, address indexed newOwner, uint256 executeAfter);
    event RecoveryExecuted(address indexed oldOwner, address indexed newOwner);
    event RecoveryCancelled();
    event OwnerUpdated(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyGuardian() {
        require(guardians[msg.sender], "Not guardian");
        _;
    }

    /// @notice Initialize the recovery module with owner and guardians
    /// @param _owner The account owner
    /// @param _guardians Array of guardian addresses
    function initialize(address _owner, address[] calldata _guardians) external reinitializer(2) {
        address oldOwner = owner;
        owner = _owner;

        for (uint256 i = 0; i < _guardians.length; i++) {
            guardians[_guardians[i]] = true;
            emit GuardianAdded(_guardians[i]);
        }

        emit OwnerUpdated(oldOwner, _owner);
    }

    /// @notice Add a guardian who can initiate recovery
    /// @param guardian The address to add as guardian
    function addGuardian(address guardian) external onlyOwner {
        require(guardian != address(0), "Invalid guardian");
        guardians[guardian] = true;
        emit GuardianAdded(guardian);
    }

    /// @notice Remove a guardian
    /// @param guardian The address to remove
    function removeGuardian(address guardian) external onlyOwner {
        guardians[guardian] = false;
        emit GuardianRemoved(guardian);
    }

    /// @notice Initiate account recovery process
    /// @param newOwner The proposed new owner
    function initiateRecovery(address newOwner) external onlyGuardian {
        require(newOwner != address(0), "Invalid new owner");
        require(!pendingRecovery.executed, "Recovery already executed");

        pendingRecovery = RecoveryRequest({
            newOwner: newOwner,
            executeAfter: block.timestamp + RECOVERY_DELAY,
            executed: false
        });

        emit RecoveryInitiated(msg.sender, newOwner, pendingRecovery.executeAfter);
    }

    /// @notice Execute pending recovery after time delay
    function executeRecovery() external onlyGuardian {
        require(pendingRecovery.newOwner != address(0), "No pending recovery");
        require(block.timestamp >= pendingRecovery.executeAfter, "Recovery delay not passed");
        require(!pendingRecovery.executed, "Already executed");

        address oldOwner = owner;
        owner = pendingRecovery.newOwner;
        pendingRecovery.executed = true;

        emit RecoveryExecuted(oldOwner, owner);
    }

    /// @notice Cancel pending recovery
    function cancelRecovery() external onlyOwner {
        require(pendingRecovery.newOwner != address(0), "No pending recovery");
        require(!pendingRecovery.executed, "Already executed");

        delete pendingRecovery;
        emit RecoveryCancelled();
    }

    /// @notice Execute arbitrary call (owner only)
    /// @param target The contract to call
    /// @param data The calldata to send
    function execute(address target, bytes calldata data) external payable onlyOwner returns (bytes memory) {
        (bool success, bytes memory result) = target.call{value: msg.value}(data);
        require(success, "Execution failed");
        return result;
    }

    /// @notice Fallback to accept ETH
    receive() external payable {}
}
