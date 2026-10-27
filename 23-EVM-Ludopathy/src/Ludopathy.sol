// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ILudopathy} from './interfaces/ILudopathy.sol';

contract Ludopathy is ILudopathy {
  uint256 public constant SINGLE_BET_COST = 1.2 ether;
  uint256 public constant WINNER_BOOST = 1;
  uint256 public constant DISCOUNTED_COST_FOR_LARGE_BETS = 1 ether;
  uint256 public constant PRIZE_PER_WINNING_NUMBER = 1.5 ether;
  uint256 public constant BETTING_TIME = 0; // CTF: no delay
  uint256 public constant TIME_BETWEEN_ROUNDS = 0; // CTF: no delay
  uint256 public constant END_TIMESTAMP = 1_995_162_248;

  // user => number => Bet
  mapping(address => mapping(uint256 => Bet)) bets;

  bool roundClosed;
  uint40 roundStart;
  uint48 public currentRoundId = 1;
  address public owner;

  mapping(uint48 => Rounds) public rounds;

  uint256 nextRoundStartTimestamp;

  constructor(address _owner) {
    owner = _owner;
  }

  /*
    @notice: Allows ludopaths to bet on multiple numbers with multiple amounts
    @param _numbersToBetOn: Numbers the ludopath wants to place a bet on
    @param _amountsOfNumbersToBuy: Amount of numbers to buy for a certain bet
  */
  function largeBet(uint96[] calldata _numbersToBetOn, uint200[] calldata _amountsOfNumbersToBuy) external payable {
    if (block.timestamp >= END_TIMESTAMP) revert ContractClosed();
    uint256 _numbersLength = _numbersToBetOn.length;
    if (_numbersLength != _amountsOfNumbersToBuy.length) revert OddLengths();
    if (roundStart == 0) roundStart = uint40(block.timestamp);
    uint48 _currentRoundId = currentRoundId;
    uint256 totalNumbersBought;
    for (uint256 _i; _i < _numbersLength;) {
      Bet storage _numberBet = bets[msg.sender][_numbersToBetOn[_i]];
      if (_numberBet.roundId != _currentRoundId) _numberBet.roundId = _currentRoundId;
      unchecked {
        _numberBet.amountOfNumbers += _amountsOfNumbersToBuy[_i];
        totalNumbersBought += _amountsOfNumbersToBuy[_i];
        ++_i;
      }
    }
    if (msg.value < totalNumbersBought * DISCOUNTED_COST_FOR_LARGE_BETS) revert YouAreBroke();
    unchecked {
      rounds[currentRoundId].prizePool += uint248(msg.value);
    }
    emit RichLudopath(msg.sender, _numbersToBetOn, _amountsOfNumbersToBuy);
  }

  /*
    @notice: Allows owner to select the winning number of a round
    @param _roundWinner: The winning number of the current round
  */
  function selectWinningNumber(uint96 _roundWinner) external {
    if (msg.sender != owner) revert OnlyOwner();
    if (block.timestamp < roundStart + BETTING_TIME) revert BroWait();
    if (_roundWinner == 0) revert ProhibitedWinner();
    if (roundStart == 0) revert AlreadySelected();
    rounds[currentRoundId].roundWinner = _roundWinner;
    roundClosed = true;
    nextRoundStartTimestamp = block.timestamp + TIME_BETWEEN_ROUNDS;
    emit RoundWinnerSelected(_roundWinner);
  }

  /*
    @notice: Allows users to start a new round after some time has elapsed.
  */
  function startNextRound() external {
    if (block.timestamp < nextRoundStartTimestamp) revert Wait();
    roundClosed = false;
    ++currentRoundId;
    roundStart = 0;
  }

  /*
    @notice: Allows ludopaths to bet on a single number
    @param _numberToBetOn: Number the ludopath wants to bet on
  */
  function smallBet(uint96 _numberToBetOn) external payable {
    if (block.timestamp >= END_TIMESTAMP) revert ContractClosed();
    if (roundClosed) revert TakePill();
    if (msg.value < SINGLE_BET_COST) revert YouAreBroke();
    if (roundStart == 0) roundStart = uint40(block.timestamp);
    if (block.timestamp >= roundStart + BETTING_TIME) revert BettingTimeOver();
    unchecked {
      rounds[currentRoundId].prizePool += uint248(msg.value);
    }
    bets[msg.sender][_numberToBetOn] = Bet(1, currentRoundId, false);
    emit BrokeLudopath(msg.sender, _numberToBetOn);
  }

  /*
    @notice: Allows the winning ludopath to claim the prize of the round he won
    @param _roundId: Id of the round the ludopath won

    @dev: This is a brutal game. If there were multiple winners, only the first one to call this function gets the prize.
          This is intended. If the first ludopath didn't buy enough amounts of the winning number and some of the prize pool remains
          then another winning ludopath can claim as well.
  */
  function claimPrize(uint48 _roundId) external {
    Rounds storage _rounds = rounds[_roundId];
    uint96 _roundWinner = _rounds.roundWinner;
    if (_roundWinner == 0) revert WinnerNotSelected();
    Bet storage _winningBet = bets[msg.sender][_roundWinner];
    if (_winningBet.claimed) revert AlreadyClaimed();

    if (_winningBet.roundId == 0 || _winningBet.roundId != _roundId) revert NoTricks();

    uint256 _amountToPay = (WINNER_BOOST + _winningBet.amountOfNumbers) * PRIZE_PER_WINNING_NUMBER;
    bool _success;
    if (_amountToPay > _rounds.prizePool) (_success,) = payable(msg.sender).call{value: _rounds.prizePool}('');
    else (_success,) = payable(msg.sender).call{value: _amountToPay}('');
    if (!_success) revert BadCall();
    emit PrizeClaimed(msg.sender, _amountToPay, _rounds.prizePool);
  }

  /*
    @notice: Allows any user to claim the contract's dust when the contract ceases to be active
  */
  function dustClaim() external {
    if (block.timestamp < END_TIMESTAMP) revert ContractStillActive();
    (bool _success,) = payable(msg.sender).call{value: address(this).balance}('');
    if (!_success) revert BadCall();
  }
}
