// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "src/MockERC20.sol";

contract BadDebtMarket {
    error NotOwner();
    error NotEngine();
    error EngineAlreadySet();
    error BorrowerIsHealthy();
    error NothingToLiquidate();
    error PartialRepayNotSupported();

    struct Position {
        uint256 collateral;
        uint256 debt;
    }

    uint256 public constant COLLATERAL_PRICE = 0.5 ether;
    uint256 public constant LIQUIDATION_THRESHOLD_BPS = 9_000;

    address public immutable owner;
    address public engine;
    address public currentBorrower;

    MockERC20 public immutable collateralToken;
    MockERC20 public immutable quoteToken;

    mapping(address => Position) public positions;

    constructor(MockERC20 collateralToken_, MockERC20 quoteToken_) {
        owner = msg.sender;
        collateralToken = collateralToken_;
        quoteToken = quoteToken_;
    }

    function setEngine(address engine_) external {
        if (msg.sender != owner) revert NotOwner();
        if (engine != address(0)) revert EngineAlreadySet();
        engine = engine_;
    }

    function seedPosition(address borrower, uint256 collateral, uint256 debt) external {
        if (msg.sender != owner) revert NotOwner();
        positions[borrower] = Position({collateral: collateral, debt: debt});
        currentBorrower = borrower;
    }

    function isLiquidatable(address borrower) public view returns (bool) {
        Position memory position = positions[borrower];
        if (position.debt == 0) {
            return false;
        }

        uint256 collateralValue = (position.collateral * COLLATERAL_PRICE) / 1 ether;
        return collateralValue * 10_000 < position.debt * LIQUIDATION_THRESHOLD_BPS;
    }

    function liquidate(address borrower, uint256 repayAmount, address receiver) external returns (uint256 seizedCollateral) {
        if (msg.sender != engine) revert NotEngine();

        Position memory position = positions[borrower];
        if (position.debt == 0) revert NothingToLiquidate();
        if (!isLiquidatable(borrower)) revert BorrowerIsHealthy();
        if (repayAmount != position.debt) revert PartialRepayNotSupported();

        delete positions[borrower];
        if (borrower == currentBorrower) {
            currentBorrower = address(0);
        }

        quoteToken.transferFrom(msg.sender, address(this), repayAmount);
        collateralToken.transfer(receiver, position.collateral);

        return position.collateral;
    }
}
