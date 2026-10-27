// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ISentinelGate} from './interfaces/ISentinelGate.sol';

/// @title SentinelGate
/// @notice A gas-optimized vault with per-address balances and a blacklist mechanism.
///         The withdrawal path is implemented via a fallback dispatcher to reduce
///         ABI decoding overhead on the hot path.
contract SentinelGate {
  address public owner;
  mapping(address => uint256) public balances;
  mapping(address => bool) public blacklisted;

  error SentinelGate_Blacklisted();
  error SentinelGate_NoBalance();
  error SentinelGate_TransferFailed();
  error SentinelGate_OnlyOwner();

  event Deposit(address indexed account, uint256 amount);
  event Withdrawal(address indexed to, uint256 amount);
  event Blacklisted(address indexed account);
  event RemovedFromBlacklist(address indexed account);

  constructor(address _owner) {
    owner = _owner;
  }

  /// @notice Deposit ETH for the caller
  function deposit() external payable {
    balances[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
  }

  /// @notice Deposit ETH on behalf of another account
  function depositFor(address _account) external payable {
    balances[_account] += msg.value;
    emit Deposit(_account, msg.value);
  }

  /// @notice Add an address to the blacklist
  function addToBlacklist(address _account) external {
    if (msg.sender != owner) revert SentinelGate_OnlyOwner();
    blacklisted[_account] = true;
    emit Blacklisted(_account);
  }

  /// @notice Remove an address from the blacklist
  function removeFromBlacklist(address _account) external {
    if (msg.sender != owner) revert SentinelGate_OnlyOwner();
    blacklisted[_account] = false;
    emit RemovedFromBlacklist(_account);
  }

  receive() external payable {}

  /// @notice Gas-optimized dispatcher for the withdrawal path.
  ///         Handles: withdrawAll(address _to)
  fallback() external payable {
    // Selector for withdrawAll(address)
    bytes4 _withdrawSelector = ISentinelGate.withdrawAll.selector;

    if (msg.sig != _withdrawSelector) {
      revert();
    }

    // Inline blacklist enforcement using raw calldata for gas efficiency
    bool _isBlacklisted;
    assembly {
      mstore(0x00, calldataload(4))
      mstore(0x20, blacklisted.slot)
      _isBlacklisted := sload(keccak256(0x00, 0x40))
    }
    if (_isBlacklisted) revert SentinelGate_Blacklisted();

    address _to;
    assembly {
      _to := calldataload(4)
    }

    uint256 _balance = balances[_to];
    if (_balance == 0) revert SentinelGate_NoBalance();

    balances[_to] = 0;

    (bool _success,) = payable(_to).call{value: _balance}('');
    if (!_success) revert SentinelGate_TransferFailed();

    emit Withdrawal(_to, _balance);
  }
}
