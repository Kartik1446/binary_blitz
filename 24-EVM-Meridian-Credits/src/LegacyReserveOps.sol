// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Legacy Reserve Operations
/// @notice Reserve operations contract for regional coordination
contract LegacyReserveOps {
    address public admin;              
    address public trustedPartner;     
    mapping(address => bool) public authorizedOperators;

    event PartnershipEstablished(address indexed partner);
    event OperationExecuted(address indexed target, bytes data);

    /// @notice Initialize the legacy contract
    /// @param _admin The reserve admin address
    /// @param _partner The trusted partner reserve for cross-regional coordination
    function initialize(address _admin, address _partner) external {
        require(admin == address(0), "Already initialized");
        admin = _admin;
        trustedPartner = _partner;
        authorizedOperators[_admin] = true;
        authorizedOperators[_partner] = true;
        emit PartnershipEstablished(_partner);
    }

    /// @notice Execute a call to an external contract
    /// @param target The contract to call
    /// @param data The calldata to send
    function execute(address target, bytes calldata data) external {
        require(msg.sender == admin, "Not admin");
        (bool success, ) = target.call(data);
        require(success, "Execution failed");
        emit OperationExecuted(target, data);
    }

    receive() external payable {}
}
