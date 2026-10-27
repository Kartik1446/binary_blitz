// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "src/BadDebtMarket.sol";
import "src/DirectivePreviewLib.sol";
import "src/LiquidationVenue.sol";
import "src/MockERC20.sol";

contract LiquidationEngine {
    error NotOwner();
    error InvalidKeeperSignature();
    error BorrowerIsHealthy();

    event LiquidationExecuted(
        address indexed borrower,
        address indexed beneficiary,
        uint256 repayAmount,
        uint256 seizedCollateral,
        uint256 payout
    );

    bytes32 private constant DIRECTIVE_KEY_DOMAIN = keccak256("LIQUID_OMENS_DIRECTIVE_KEY_V1");
    bytes32 private constant DIRECTIVE_JOURNAL_DOMAIN = keccak256("LIQUID_OMENS_DIRECTIVE_JOURNAL_V1");

    address public immutable owner;
    address public immutable player;
    BadDebtMarket public immutable market;
    LiquidationVenue public immutable venue;
    MockERC20 public immutable quoteToken;
    address public immutable keeperSigner;

    constructor(
        BadDebtMarket market_,
        LiquidationVenue venue_,
        MockERC20 quoteToken_,
        address keeperSigner_,
        address player_
    ) {
        owner = msg.sender;
        player = player_;
        market = market_;
        venue = venue_;
        quoteToken = quoteToken_;
        keeperSigner = keeperSigner_;

        quoteToken_.approve(address(market_), type(uint256).max);
    }

    function recordDirective(bytes calldata directive) external {
        if (msg.sender != owner) revert NotOwner();

        _recordDirective(directive, _deriveFilingKey(block.number));
    }

    function liquidate(bytes calldata directive, bytes calldata signature) external returns (uint256 payout) {
        DirectivePreviewLib.DirectivePreview memory preview = DirectivePreviewLib.load(directive);
        bytes32 digest = DirectivePreviewLib.digest(preview, address(this));

        if (_recover(digest, signature) != keeperSigner) revert InvalidKeeperSignature();
        address borrower = market.currentBorrower();
        if (!market.isLiquidatable(borrower)) revert BorrowerIsHealthy();

        (, uint256 repayAmount) = market.positions(borrower);
        uint256 seizedCollateral = market.liquidate(borrower, repayAmount, address(venue));
        payout = venue.executeDirective(directive, borrower, player, seizedCollateral);

        emit LiquidationExecuted(borrower, player, repayAmount, seizedCollateral, payout);
    }

    function _recover(bytes32 digest, bytes calldata signature) private pure returns (address signer) {
        if (signature.length != 65) {
            return address(0);
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 0x20))
            v := byte(0, calldataload(add(signature.offset, 0x40)))
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(digest, v, r, s);
    }

    function _deriveFilingKey(uint256 filingBlock) private view returns (uint256) {
        return uint256(keccak256(abi.encode(DIRECTIVE_KEY_DOMAIN, player, filingBlock)));
    }

    function _recordDirective(bytes calldata directive, uint256 filingKey) private {
        uint256 base = uint256(keccak256(abi.encode(DIRECTIVE_JOURNAL_DOMAIN, filingKey)));
        uint256 words = (directive.length + 31) / 32;

        assembly {
            sstore(base, directive.length)
        }

        for (uint256 i = 0; i < words; ++i) {
            bytes32 word;
            uint256 slot = base + i + 1;

            assembly {
                word := calldataload(add(directive.offset, mul(i, 0x20)))
                sstore(slot, word)
            }
        }
    }
}
