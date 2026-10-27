# Infinity Send

## Description

The Wonderland treasury has deployed a new token distribution system. It carefully validates every transfer request before forwarding it to the multisig -- checking recipients, amounts, and totals all add up. Surely nothing can go wrong if the math checks out... right?

Make the money move fail.

## Overview

The `Challenge` contract holds 1,000 InfinityTokens and wants to distribute them using an onchain token sender called `MoneyMoves` at `0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A`. After every call of `sendMoney` on the `Challenge` contract, it resets all balances.

The `sendMoney` function takes raw calldata, validates it, and forwards it to `MoneyMoves`. Your job is to craft calldata that passes the challenge's validation but causes `MoneyMoves` to revert.

## Objective

Call `Challenge.sendMoney()` with calldata that:

1. Passes `validateCalldata` (correct selector, valid token address, matching arrays, sum <= 1000e18, sum == totalAmount)
2. Causes the `MoneyMoves` contract to revert

When `MoneyMoves` reverts, `isSolved()` returns true and you get the flag.

## Contracts

- **Challenge.sol** - Validates calldata and forwards it to MoneyMoves
- **InfinityToken.sol** - ERC20 token held by the Challenge (balances reset after each attempt, so you can't brick it)
- **MoneyMoves** - Onchain bytecode contract at `0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A`
