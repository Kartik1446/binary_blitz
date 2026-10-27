// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IPrecompile20 {
  event TokensTransferred(address _from, address _to, uint256 _amount);

  error WrongAmountOfETH();
  error CantReuseSignatures();
  error InsufficientFunds();
  error BadCall();
  error OnlyOwner();
}
