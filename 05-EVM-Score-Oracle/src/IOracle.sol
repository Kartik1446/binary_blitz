// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IOracle {
  /*///////////////////////////////////////////////////////////////
                              ERRORS
  ///////////////////////////////////////////////////////////////*/

  error Oracle_NotEnoughContributors();
  error Oracle_InvalidContribution();

  /*///////////////////////////////////////////////////////////////
                             FUNCTIONS
  ///////////////////////////////////////////////////////////////*/

  function contribute(uint256 _value) external payable;
  function poke() external;

  /*///////////////////////////////////////////////////////////////
                              VIEWS
  ///////////////////////////////////////////////////////////////*/

  function getRotation() external view returns (uint256);
  function contributorCount() external view returns (uint256);
  function contributions(address _contributor) external view returns (uint256);
}
