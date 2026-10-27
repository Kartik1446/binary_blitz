// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Shared Escrow
/// @notice Bilateral escrow for inter-regional trade between two partner reserves
/// @dev Both partners must agree before any funds or operations can be released.
contract SharedEscrow {
    address public owner;       
    address public partner;     
    bool public initialized;    

    uint256 public escrowBalance;

    mapping(address => bool) public releaseApproved;

    event EscrowInitialized(address indexed owner, address indexed partner);
    event Deposited(address indexed from, uint256 amount);
    event ReleaseApproved(address indexed approver);
    event ReleaseRevoked(address indexed revoker);
    event FundsReleased(address indexed to, uint256 amount);
    event OperationExecuted(address indexed target);

    modifier onlyParticipant() {
        require(msg.sender == owner || msg.sender == partner, "Not a participant");
        _;
    }

    /// @notice Initialize the escrow with owner and partner
    /// @param _owner The primary reserve 
    /// @param _partner The partner reserve for bilateral operations
    function initialize(address _owner, address _partner) external {
        require(!initialized, "Already initialized");
        require(_owner != address(0) && _partner != address(0), "Invalid addresses");
        require(_owner != _partner, "Owner cannot be partner");
        owner = _owner;
        partner = _partner;
        initialized = true;
        emit EscrowInitialized(_owner, _partner);
    }

    /// @notice Deposit ETH into the escrow
    function deposit() external payable onlyParticipant {
        require(msg.value > 0, "No value");
        escrowBalance += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Signal agreement to release funds or execute operations
    function agreeToRelease() external onlyParticipant {
        releaseApproved[msg.sender] = true;
        emit ReleaseApproved(msg.sender);
    }

    /// @notice Revoke release agreement
    function revokeRelease() external onlyParticipant {
        releaseApproved[msg.sender] = false;
        emit ReleaseRevoked(msg.sender);
    }

    /// @notice Release ETH from the escrow (requires both parties' approval)
    /// @param to Recipient address
    /// @param amount Amount to release
    function release(address payable to, uint256 amount) external onlyParticipant {
        require(releaseApproved[owner] && releaseApproved[partner], "Both must approve");
        require(amount <= escrowBalance, "Insufficient balance");

        escrowBalance -= amount;
        releaseApproved[owner] = false;
        releaseApproved[partner] = false;

        (bool success,) = to.call{value: amount}("");
        require(success, "Transfer failed");
        emit FundsReleased(to, amount);
    }

    /// @notice Execute an arbitrary call (requires both parties' approval)
    /// @param target The contract to call
    /// @param data The calldata
    function execute(address target, bytes calldata data) external onlyParticipant returns (bytes memory) {
        require(releaseApproved[owner] && releaseApproved[partner], "Both must approve");
        releaseApproved[owner] = false;
        releaseApproved[partner] = false;

        (bool success, bytes memory result) = target.call(data);
        require(success, "Execution failed");
        emit OperationExecuted(target);
        return result;
    }

    receive() external payable {}
}
