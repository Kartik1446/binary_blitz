// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface ISentinelGate {
  // ==============================
  // ========== Events ============
  // ==============================

  event Deposit(address indexed account, uint256 amount);
  event Withdrawal(address indexed to, uint256 amount);
  event Blacklisted(address indexed account);
  event RemovedFromBlacklist(address indexed account);

  // ==============================
  // ========== Errors ============
  // ==============================

  error SentinelGate_Blacklisted();
  error SentinelGate_NoBalance();
  error SentinelGate_TransferFailed();
  error SentinelGate_OnlyOwner();

  // ==============================
  // ======= Public State =========
  // ==============================

  function owner() external view returns (address);
  function balances(address _account) external view returns (uint256);
  function blacklisted(address _account) external view returns (bool);

  // ==============================
  // ======== Functions ===========
  // ==============================

  function deposit() external payable;
  function depositFor(address _account) external payable;
  function addToBlacklist(address _account) external;
  function removeFromBlacklist(address _account) external;
  function withdrawAll(address _to) external;
}
