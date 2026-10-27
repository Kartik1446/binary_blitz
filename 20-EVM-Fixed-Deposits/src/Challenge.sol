// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {DepositVault} from "./DepositVault.sol";
import {CtfDepositToken} from "./CtfDepositToken.sol";

/// @title DepositManager
/// @notice Manages fixed-term deposits sorted by owner address.
///         Completed deposits are settled in batch via removeCompleted().
contract Challenge {

    bytes32 public constant NULL_NODE = bytes32(0);

    uint256 public constant RATE = 1000; // 10% annual interest
    uint256 public constant SECONDS_PER_YEAR = 365 days;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    type Timestamp is uint256;

    event Deposit(
        bytes32 indexed depositId,
        address indexed owner,
        uint256 amount,
        uint256 start,
        uint256 maturity
    );

    event DepositCompleted(bytes32 indexed depositId);

    error InsufficientBalance(uint256 available, uint256 required);

    struct FixedDepositInfo {
        address owner;
        uint256 amount;
        Timestamp start;
        Timestamp maturity;
    }

    struct FixedDepositNode {
        FixedDepositInfo info;
        bytes32 next;
    }

    struct FixedDepositList {
        bytes32 head;
        mapping(bytes32 => FixedDepositNode) deposits;
    }

    bytes32 internal nextDepositId;
    FixedDepositList internal depositsList;

    CtfDepositToken public token;
    DepositVault public vault;

    uint8 public constant MAX_SETTLEMENTS = 4; // Maximum number of settlements before the challenge is considered solved
    uint8 public settlementCount;
    address public immutable PLAYER;

    uint256 public playerInitialBalance;
    uint256 public vaultInitialBalance;

    constructor(address player, CtfDepositToken _token, DepositVault _vault) {
        PLAYER = player;
        token = _token;
        vault = _vault;
        playerInitialBalance = token.balanceOf(PLAYER);
        vaultInitialBalance = token.balanceOf(address(vault));
    }

    modifier valid(Timestamp maturity) {
        // Enforce minimum maturity of 90 days to prevent trivial early settlements and ensure interest accrual
        require(
            Timestamp.unwrap(maturity) >= block.timestamp,
            "maturity must be at least 90 days in the future"
        );
        _;
    }

    modifier settlementAllowed() {
        require(settlementCount < MAX_SETTLEMENTS, "maximum settlements reached");
        settlementCount++;
        _;
    }



    // -----------------------------------------------------------------------
    // Deposit entry point
    // -----------------------------------------------------------------------

    function deposit(address owner, uint256 amount, Timestamp maturity) external valid(maturity) {
        require(amount > 0, "zero amount");
        FixedDepositInfo memory info = FixedDepositInfo(
            owner,
            amount,
            Timestamp.wrap(block.timestamp),
            maturity
        );

        vault.registerPayout(msg.sender, amount);

        nextDepositId = bytes32(uint256(nextDepositId) + 1);
        _insertSorted(nextDepositId, info);

        emit Deposit(nextDepositId, owner, amount, Timestamp.unwrap(info.start), Timestamp.unwrap(info.maturity));
    }

    // withdraw function for users to pull their funds from the vault without waiting for settlement
    function withdrawDeposit(bytes32 depositId, uint256 amount) external {
        require(amount > 0, "zero amount");

        require(depositsList.deposits[depositId].info.owner == msg.sender, "not owner");
        require(depositsList.deposits[depositId].info.amount >= amount, InsufficientBalance(depositsList.deposits[depositId].info.amount, amount));

        // Update the deposit info to reflect the withdrawal
        depositsList.deposits[depositId].info.amount -= amount;

        // Withdraw function for users to pull their funds from the vault
        vault.release(msg.sender, amount);
    }

    function withdrawAll() external {
        address owner = msg.sender;
        bytes32 current = depositsList.head;
        while (current != NULL_NODE) {
            if (depositsList.deposits[current].info.owner == owner) {
                uint256 amount = depositsList.deposits[current].info.amount;
                if (amount > 0) {
                    // Withdraw function for users to pull their funds from the vault
                    try vault.release(owner, amount) {
                        // Update the deposit info to reflect the withdrawal
                        depositsList.deposits[current].info.amount = 0;
                    } catch  {
                        continue; // If the vault release fails (e.g., due to insufficient funds), stop processing further withdrawals
                    }
                }
            }
            current = depositsList.deposits[current].next;
        }
    }

    function totalAmountInActiveDeposits() public view returns (uint256) {
        uint256 count = 0;
        bytes32 current = depositsList.head;

        while (current != NULL_NODE) {
            count += depositsList.deposits[current].info.amount;
            current = depositsList.deposits[current].next;
        }
        return count;
    }

    // -----------------------------------------------------------------------
    // Linked-list management
    // -----------------------------------------------------------------------

    /// @notice Inserts a deposit node sorted ascending by owner address.
    function _insertSorted(bytes32 depositId, FixedDepositInfo memory info) internal {
        bytes32 current  = depositsList.head;
        bytes32 previous = current;

        // Empty list — just set head
        if (current == NULL_NODE) {
            depositsList.head = depositId;
            depositsList.deposits[depositId].info = info;
            depositsList.deposits[depositId].next = NULL_NODE;
            return;
        }

        while (current != NULL_NODE) {
            if (current == depositId) break; // duplicate — no-op

            if (info.owner < depositsList.deposits[current].info.owner) {
                if (current == depositsList.head) {
                    depositsList.head = depositId;
                } else {
                    depositsList.deposits[previous].next = depositId;
                }
                depositsList.deposits[depositId].next = current;
                depositsList.deposits[depositId].info = info;
                return;
            }

            previous = current;
            current  = depositsList.deposits[current].next;
        }

        // Append to tail (owner is >= all existing owners)
        depositsList.deposits[previous].next = depositId;
        depositsList.deposits[depositId].info = info;
        depositsList.deposits[depositId].next = NULL_NODE;
    }

    function deleteNode(bytes32 depositId, bytes32 previous) internal {
        // Unlink the completed node
        if (depositId == depositsList.head) {
            depositsList.head = depositsList.deposits[depositId].next;
        } else {
            depositsList.deposits[previous].next = depositsList.deposits[depositId].next;
        }

        emit DepositCompleted(depositId);
    }

    // -----------------------------------------------------------------------
    // Settlement
    // -----------------------------------------------------------------------

    /// @notice Iterates the deposit list and settles any matured deposits.
    ///         Releases principal via vault and pays accrued interest.
    /// @dev    Settlement order follows the sorted-by-owner linked list.
    ///         Nodes are deleted after payout.
    function removeCompleted() external settlementAllowed {
        bytes32 currentNode  = depositsList.head;
        bytes32 previousNode = currentNode;

        // Batch accumulators
        address batchOwner      = address(0);
        uint256 batchPrincipal  = 0;
        uint256 batchInterest   = 0;

        while (currentNode != NULL_NODE) {
            bytes32 next = depositsList.deposits[currentNode].next;
            if (block.timestamp >= Timestamp.unwrap(depositsList.deposits[currentNode].info.maturity)) {
                FixedDepositInfo memory info = depositsList.deposits[currentNode].info;

                // Flush previous batch if owner changes
                if (batchOwner != address(0) && info.owner != batchOwner) {
                    vault.release(batchOwner, batchPrincipal + batchInterest);
                    batchPrincipal = 0;
                    batchInterest  = 0;
                }

                // Accumulate into current batch
                batchOwner      = info.owner;
                batchPrincipal += info.amount;
                batchInterest  += _calculateInterest(info.amount, Timestamp.unwrap(info.start), Timestamp.unwrap(info.maturity));

                deleteNode(currentNode, previousNode);
            }
            previousNode = currentNode;
            currentNode = next;
        }
        // Flush the final batch
        if (batchOwner != address(0)) {
            vault.release(batchOwner, batchPrincipal + batchInterest);
        }
    }

    // -----------------------------------------------------------------------
    // Interest calculation
    // -----------------------------------------------------------------------
    // Simple linear interest calculation for demonstration purposes
    function _calculateInterest(uint256 amount, uint256 start, uint256 maturity) internal pure returns (uint256) {
        uint256 duration = maturity - start;
        return (amount * RATE * duration) / (SECONDS_PER_YEAR * BPS_DENOMINATOR);
    }

    // -----------------------------------------------------------------------
    // Challenge validation
    // -----------------------------------------------------------------------

    function isSolved() external view returns (bool) {
        // The challenge is solved if the player has successfully extracted more than half of the vault's initial balance
        return token.balanceOf(address(vault)) < vaultInitialBalance / 2;
    }
}