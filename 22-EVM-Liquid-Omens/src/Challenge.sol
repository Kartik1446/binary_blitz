// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "src/BadDebtMarket.sol";
import "src/LiquidationEngine.sol";
import "src/LiquidationVenue.sol";
import "src/MockERC20.sol";

/// @author EV_om
contract Challenge {
    uint256 private constant SOLVE_THRESHOLD = 900 ether;

    address public immutable PLAYER;

    MockERC20 public immutable collateralToken;
    MockERC20 public immutable quoteToken;
    BadDebtMarket public immutable market;
    LiquidationVenue public immutable venue;
    LiquidationEngine public immutable engine;

    constructor(
        address player,
        MockERC20 collateralToken_,
        MockERC20 quoteToken_,
        BadDebtMarket market_,
        LiquidationVenue venue_,
        LiquidationEngine engine_
    ) {
        PLAYER = player;
        collateralToken = collateralToken_;
        quoteToken = quoteToken_;
        market = market_;
        venue = venue_;
        engine = engine_;
    }

    function isSolved() external view returns (bool) {
        return quoteToken.balanceOf(PLAYER) >= SOLVE_THRESHOLD;
    }
}
