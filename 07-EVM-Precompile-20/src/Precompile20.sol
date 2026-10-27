// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IPrecompile20} from './interfaces/IPrecompile20.sol';
import {ERC20} from 'solmate/tokens/ERC20.sol';

contract Precompile20 is ERC20, IPrecompile20 {
  uint256 public constant TOKEN_PRICE = 0.01 ether;
  mapping(bytes signature => bool) public obsoleteSignature;
  address public owner;
  address public deployer;

  constructor(address _owner) ERC20('PRECOMPILE20', 'PR20', 18) {
    owner = _owner;
    deployer = msg.sender;
  }

  /// @notice Admin mint for CTF setup only
  function adminMint(address _to, uint256 _amount) external {
    require(msg.sender == deployer, "only deployer");
    _mint(_to, _amount);
  }

  /*
        @notice allows users to burn their tokens without diminishing totalSupply
        @param _from: user whose tokens will be burned
        @param _amount: how many tokens to burn
  */
  function burnTokens(address _from, uint256 _amount) external {
    _mint(address(0), _amount);
    _burn(_from, _amount);
  }

  /*
        @notice allows users to buy tokens
        @param _to: recipient of the tokens
        @param _amount: how many tokens to buy
  */
  function buyTokens(address _to, uint256 _amount) external payable {
    if (_amount * TOKEN_PRICE != msg.value) revert WrongAmountOfETH();
    _mint(_to, _amount);
  }

  /*
        @notice transfer tokens to msg.sender if signature provided is valid
        @param _amount: amount of tokens to transfer
        @param _signature: signature of gifter address
        @dev: signature should be encoded in the format v, r, s;
  */
  function transferTokens(uint256 _amount, bytes memory _signature) external {
    if (obsoleteSignature[_signature]) revert CantReuseSignatures();

    bytes32 _hash = keccak256(abi.encode(msg.sender, _amount));
    bytes memory _data = bytes.concat(_hash, _signature);

    (bool _success, bytes memory _returnedData) = address(1).call(_data);

    if (!_success) revert BadCall();
    address _gifter;

    // quick way to convert bytes into address avoiding a call to abi.decode
    assembly {
      let ret := mload(_returnedData)
      if iszero(ret) { _gifter := ret }
      if iszero(iszero(ret)) { _gifter := mload(add(_returnedData, 32)) }
    }

    if (balanceOf[_gifter] < _amount) revert InsufficientFunds();

    obsoleteSignature[_signature] = true;

    _mint(msg.sender, _amount);
    _burn(_gifter, _amount);
    emit TokensTransferred(_gifter, msg.sender, _amount);
  }

  function withdraw() external {
    if (msg.sender != owner) revert OnlyOwner();
    payable(owner).transfer(address(this).balance);
  }
}
