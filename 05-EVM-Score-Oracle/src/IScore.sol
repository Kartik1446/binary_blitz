// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IScore {
  /*///////////////////////////////////////////////////////////////
                              ERRORS
  ///////////////////////////////////////////////////////////////*/

  error Score_NoIndices();
  error Score_TooFewIndices();
  error Score_IndexOutOfBounds();
  error Score_WrongSolution();
  error Score_GasTooHigh();
  error Score_TransferFailed();

  /*///////////////////////////////////////////////////////////////
                             FUNCTIONS
  ///////////////////////////////////////////////////////////////*/

  function solve(uint256[] calldata _indices) external;

  /*///////////////////////////////////////////////////////////////
                              VIEWS
  ///////////////////////////////////////////////////////////////*/

  function seed() external view returns (bytes32);
  function generateTarget() external view returns (bytes32);
  function getElement(uint256 _index) external view returns (bytes32);
  function isSolved() external view returns (bool);
}
