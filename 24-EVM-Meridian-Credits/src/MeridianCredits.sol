// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Meridian Credits
/// @author Meridian Concordat Reserve Authority
/// @notice The Concordat's unified digital currency, managed by regional reserve stations
contract MeridianCredits is ERC20 {
    address public immutable PLAYER;

    // Reserve stations authorized to mint MRC tokens
    mapping(address => bool) public authorized;

    // Mint cap per station (each station can only mint once, up to their cap)
    mapping(address => uint256) public mintCap;

    // Stations can only mint once
    mapping(address => bool) public hasMinted;

    event MinterAuthorized(address indexed minter, uint256 initialAllowance);
    event TokensMinted(address indexed minter, address indexed recipient, uint256 amount);
    event AllowanceTransferred(address indexed from, address indexed to, uint256 amount);

    constructor(address player, address[] memory reserveStations, uint256[] memory allowances)
        ERC20("Meridian Credits", "MRC")
    {
        require(reserveStations.length == allowances.length, "Array length mismatch");
        PLAYER = player;

        for (uint256 i = 0; i < reserveStations.length; i++) {
            authorized[reserveStations[i]] = true;
            mintCap[reserveStations[i]] = allowances[i];
            emit MinterAuthorized(reserveStations[i], allowances[i]);
        }
    }

    /// @notice Mint MRC tokens to a specified address
    function mint(address to, uint256 amount) external {
        require(authorized[msg.sender], "Unauthorized minter");
        require(mintCap[msg.sender] >= amount, "Exceeds station mint cap");
        require(!hasMinted[msg.sender], "Station has already minted");
        hasMinted[msg.sender] = true;
        mintCap[msg.sender] -= amount;
        _mint(to, amount);

        emit TokensMinted(msg.sender, to, amount);
    }

    /// @notice Transfer mint allowance between stations
    function transferMintCap(address to, uint256 amount) external {
        require(authorized[msg.sender], "Unauthorized: sender not a minter");
        require(authorized[to], "Unauthorized: recipient not a minter");
        require(mintCap[msg.sender] >= amount, "Insufficient allowance");

        mintCap[msg.sender] -= amount;
        mintCap[to] += amount;

        emit AllowanceTransferred(msg.sender, to, amount);
    }

    /// @notice Check if the challenge is solved
    function isSolved() external view returns (bool) {
        return balanceOf(PLAYER) >= 1_150_000 * 10**18;
    }

    /// @dev Restrict transfers to authorized stations only.
    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0)) {
            require(authorized[from], "Unauthorized: sender not authorized");
            require(authorized[to], "Unauthorized: recipient not authorized");
        }
        super._update(from, to, value);
    }
}
