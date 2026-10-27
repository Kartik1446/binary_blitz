// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface ILudopathy {
  struct Bet {
    uint200 amountOfNumbers;
    uint48 roundId;
    bool claimed;
  }

  struct Rounds {
    uint96 roundWinner;
    uint248 prizePool;
  }

  event BrokeLudopath(address _ludopath, uint96 _number);
  event RichLudopath(address _ludopath, uint96[] _number, uint200[] _amount);
  event RoundWinnerSelected(uint96 _roundWinner);
  event PrizeClaimed(address _winner, uint256 _amountToPay, uint256 _prizePool);

  error YouAreBroke();
  error BettingTimeOver();
  error NoRugging();
  error OnlyOwner();
  error NoTricks();
  error AreYouThisDesperate();
  error BroWait();
  error AlreadyClaimed();
  error WaitTillNextRound();
  error BadCall();
  error OddLengths();
  error WinnerNotSelected();
  error AlreadySelected();
  error ProhibitedWinner();
  error ContractClosed();
  error ContractStillActive();
  error Wait();
  error TakePill();
}
