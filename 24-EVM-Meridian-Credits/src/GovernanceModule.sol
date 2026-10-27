// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Governance Module
/// @notice DAO-style governance for the Kael Bastion Council
/// @dev Proposals require council membership, quorum, voting period, and execution delay.
///      Designed for transparent, time-locked decision-making on reserve operations.
contract GovernanceModule {
    struct Proposal {
        address proposer;
        address target;
        bytes data;
        uint256 value;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
    }

    address public owner;
    bool public initialized;
    uint256 public proposalCount;
    uint256 public quorum;
    uint256 public councilSize;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => bool) public council;

    uint256 public constant VOTING_PERIOD = 3 days;
    uint256 public constant EXECUTION_DELAY = 1 days;

    event ProposalCreated(uint256 indexed id, address indexed proposer, address target);
    event Voted(uint256 indexed id, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyCouncil() {
        require(council[msg.sender], "Not council member");
        _;
    }

    /// @notice Initialize governance with owner, council members, and quorum
    /// @param _owner The reserve owner
    /// @param _council Array of council member addresses
    /// @param _quorum Minimum votes required to pass a proposal
    function initialize(
        address _owner,
        address[] calldata _council,
        uint256 _quorum
    ) external {
        require(!initialized, "Already initialized");
        require(_quorum > 0 && _quorum <= _council.length, "Invalid quorum");
        owner = _owner;
        quorum = _quorum;
        for (uint256 i = 0; i < _council.length; i++) {
            council[_council[i]] = true;
        }
        councilSize = _council.length;
        initialized = true;
    }

    /// @notice Create a new proposal
    /// @param target The target contract for the proposed action
    /// @param data The calldata for the proposed action
    /// @param value ETH value for the proposed action
    /// @return id The proposal ID
    function createProposal(
        address target,
        bytes calldata data,
        uint256 value
    ) external onlyCouncil returns (uint256 id) {
        id = proposalCount++;
        Proposal storage p = proposals[id];
        p.proposer = msg.sender;
        p.target = target;
        p.data = data;
        p.value = value;
        p.deadline = block.timestamp + VOTING_PERIOD;
        emit ProposalCreated(id, msg.sender, target);
    }

    /// @notice Vote on a proposal
    /// @param id The proposal ID
    /// @param support True to vote for, false to vote against
    function vote(uint256 id, bool support) external onlyCouncil {
        Proposal storage p = proposals[id];
        require(block.timestamp < p.deadline, "Voting ended");
        require(!hasVoted[id][msg.sender], "Already voted");

        hasVoted[id][msg.sender] = true;
        if (support) {
            p.votesFor++;
        } else {
            p.votesAgainst++;
        }
        emit Voted(id, msg.sender, support);
    }

    /// @notice Execute a passed proposal after the execution delay
    /// @param id The proposal ID
    function executeProposal(uint256 id) external onlyCouncil {
        Proposal storage p = proposals[id];
        require(block.timestamp >= p.deadline, "Voting not ended");
        require(p.votesFor >= quorum, "Quorum not met");
        require(block.timestamp >= p.deadline + EXECUTION_DELAY, "Execution delay not passed");
        require(!p.executed, "Already executed");

        p.executed = true;
        (bool success,) = p.target.call{value: p.value}(p.data);
        require(success, "Execution failed");
        emit ProposalExecuted(id);
    }

    /// @notice Emergency direct execution (owner only)
    /// @param target The contract to call
    /// @param data The calldata
    function execute(address target, bytes calldata data) external payable onlyOwner returns (bytes memory) {
        (bool success, bytes memory result) = target.call{value: msg.value}(data);
        require(success, "Execution failed");
        return result;
    }

    receive() external payable {}
}
