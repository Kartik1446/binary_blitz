// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface ISentinelVault {
  /*///////////////////////////////////////////////////////////////
                              STRUCTS
  //////////////////////////////////////////////////////////////*/

  struct ModuleRecord {
    bool isRegistered;
    bytes32 codeHash;
  }

  /*///////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/

  event CodeHashApproved(bytes32 indexed codeHash);
  event ModuleRegistered(address indexed module, bytes32 codeHash);
  event OperatorWithdrawal(address indexed module, address indexed recipient, uint256 amount);

  /*///////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/

  error SentinelVault_OnlyOwner();
  error SentinelVault_CodeHashNotApproved();
  error SentinelVault_ModuleAlreadyRegistered();
  error SentinelVault_ModuleNotRegistered();
  error SentinelVault_TransferFailed();
  error SentinelVault_ZeroAddress();
  error SentinelVault_InsufficientBalance();

  /*///////////////////////////////////////////////////////////////
                            FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  function owner() external view returns (address);
  function approvedCodeHashes(bytes32 _codeHash) external view returns (bool);
  function modules(address _module) external view returns (bool isRegistered, bytes32 codeHash);
  function approveCodeHash(bytes32 _codeHash) external;
  function registerModule(address _module) external;
  function operatorWithdraw(address _recipient, uint256 _amount) external;
}
