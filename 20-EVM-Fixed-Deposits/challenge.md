# Fixed Deposits

## Description

The Fixed Deposits contract allows users to deposit and withdraw funds earning interest when the deposit period matures. And they can also withdraw funds early, but without interest earned. The contract contains a vulnerability that can be exploited to steal funds from the vault. The goal is to exploit this vulnerability to steal half of the vault initial balance from the vault.

## Background

**Fixed Deposits Challenge** is a on-chain fixed-term deposit protocol.
Users lock ERC20 tokens for a set duration and earn annualised interest on maturity.

The interest rate is fixed at 10%.

The protocol settles matured deposits in batches, paying out interest from a shared vault, but the settlement function

- `removeCompleted()` can only be called 4 times.
  Deposits are tracked in a linked list sorted by owner address for efficient batch settlement.

Users can have multiple active deposits, and the protocol handles them in batches to optimize gas costs.

Users can wait for their deposits to mature and then call `removeCompleted()` to receive their principal plus interest
or alternatively, they can call `withdraw()` or `withdrawAll()` at any time to receive their principal back without interest.

The protocol is split across two contracts:

| Contract         | Role                                                                       |
| ---------------- | -------------------------------------------------------------------------- |
| `DepositVault`   | Custodies all funds                                                        |
| `DepositManager` | Manages deposit records. Handles insertion, sorting, and batch settlement. |

---

## Objective

The vault holds **500,000 tokens** in reserve (interest pool) plus user principal and the player's initial balance is 20_000 tokens.
**Steal half of the vault initial balance** and call `isSolved()` to claim the flag.

You can use any of the functions provided by the Challenge contract to manipulate the state and achieve the goal of the challenge.

For example, you might want to create a deposit, wait for it to mature, and then call `removeCompleted()` to see if you can extract more tokens than you should be able to.

The actual exploit will depend on the specific vulnerabilities in the Challenge contract, which you will need to analyze and understand in order to craft a successful attack.

Good luck.
