// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "src/DirectivePreviewLib.sol";
import "src/MockERC20.sol";

contract LiquidationVenue {
    error NotOwner();
    error NotEngine();
    error EngineAlreadySet();
    error OnlySelf();
    error VenueBusy();
    error InvalidDirectiveKind();
    error NoActiveLot();

    event LotSettled(address indexed borrower, address indexed beneficiary, uint256 seizedCollateral, uint256 payout);

    address internal constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public immutable owner;
    address public engine;

    address public activeBorrower;
    address public activeBeneficiary;
    uint256 public activeCollateral;

    MockERC20 public immutable collateralToken;
    MockERC20 public immutable quoteToken;
    uint256 private stagedQuote;

    constructor(MockERC20 collateralToken_, MockERC20 quoteToken_, uint256 stagedQuote_) {
        owner = msg.sender;
        collateralToken = collateralToken_;
        quoteToken = quoteToken_;
        stagedQuote = stagedQuote_;
    }

    modifier onlySelf() {
        if (msg.sender != address(this)) revert OnlySelf();
        _;
    }

    function setEngine(address engine_) external {
        if (msg.sender != owner) revert NotOwner();
        if (engine != address(0)) revert EngineAlreadySet();
        engine = engine_;
    }

    function executeDirective(bytes calldata directive, address borrower, address beneficiary, uint256 collateralAmount)
        external
        returns (uint256 payout)
    {
        if (msg.sender != engine) revert NotEngine();
        if (activeBorrower != address(0)) revert VenueBusy();

        (uint256 directiveKind, bytes memory command) = abi.decode(directive, (uint256, bytes));
        if (directiveKind != DirectivePreviewLib.liquidationDirectiveKind()) revert InvalidDirectiveKind();

        activeBorrower = borrower;
        activeBeneficiary = beneficiary;
        activeCollateral = collateralAmount;

        (bool success, bytes memory returndata) = address(this).call(command);
        if (!success) _bubble(returndata);

        payout = abi.decode(returndata, (uint256));

        activeBorrower = address(0);
        activeBeneficiary = address(0);
        activeCollateral = 0;
    }

    function highlyProfitableTradingStrategy() external onlySelf returns (uint256 proceeds) {
        if (activeBorrower == address(0)) revert NoActiveLot();

        proceeds = (activeCollateral * 3) / 8;
        stagedQuote -= proceeds;
        collateralToken.transfer(BURN_ADDRESS, activeCollateral);
        quoteToken.transfer(activeBeneficiary, proceeds);
    }

    function netInventory() external onlySelf returns (uint256 proceeds) {
        if (activeBorrower == address(0)) revert NoActiveLot();

        proceeds = activeCollateral / 2;
        stagedQuote -= proceeds;
        collateralToken.transfer(BURN_ADDRESS, activeCollateral);
        quoteToken.transfer(activeBeneficiary, proceeds);
    }

    function settleLot() external onlySelf returns (uint256 payout) {
        if (activeBorrower == address(0)) revert NoActiveLot();

        uint256 seizedCollateral = activeCollateral;
        address beneficiary = activeBeneficiary;
        payout = stagedQuote;
        stagedQuote = 0;

        collateralToken.transfer(BURN_ADDRESS, seizedCollateral);
        quoteToken.transfer(beneficiary, payout);

        emit LotSettled(activeBorrower, beneficiary, seizedCollateral, payout);
    }

    function _bubble(bytes memory returndata) private pure {
        assembly {
            revert(add(returndata, 0x20), mload(returndata))
        }
    }
}
