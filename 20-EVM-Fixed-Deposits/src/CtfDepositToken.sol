// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract CtfDepositToken is ERC20 {

    constructor() ERC20("CtfDepositToken", "CTFDPT") {
        _mint(msg.sender, 520_000e18);
    }
}