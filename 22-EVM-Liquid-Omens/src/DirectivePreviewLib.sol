// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library DirectivePreviewLib {
    error DirectiveTooShort();
    error CommandTooLong();

    struct DirectivePreview {
        uint256 directiveKind;
        bytes32 commandHash;
    }

    bytes32 internal constant PREVIEW_DOMAIN = keccak256("LIQUID_OMENS_PREVIEW_V1");
    uint256 internal constant COMMAND_LENGTH_OFFSET = 0x40;
    uint256 internal constant COMMAND_DATA_OFFSET = 0x60;
    uint256 internal constant MAX_COMMAND_LENGTH = 0x100;

    function liquidationDirectiveKind() internal pure returns (uint256) {
        return 1;
    }

    function load(bytes calldata directive) internal pure returns (DirectivePreview memory preview) {
        if (directive.length < COMMAND_DATA_OFFSET) revert DirectiveTooShort();

        uint256 commandDataOffset;
        uint256 commandLength;

        assembly {
            let base := directive.offset

            mstore(preview, calldataload(base))
            commandDataOffset := add(base, COMMAND_DATA_OFFSET)
            commandLength := calldataload(add(base, COMMAND_LENGTH_OFFSET))
        }

        if (commandLength > MAX_COMMAND_LENGTH) revert CommandTooLong();
        if (directive.length < COMMAND_DATA_OFFSET + commandLength) revert DirectiveTooShort();

        bytes memory commandBytes = new bytes(commandLength);
        assembly {
            calldatacopy(add(commandBytes, 0x20), commandDataOffset, commandLength)
        }

        preview.commandHash = keccak256(commandBytes);
    }

    function digest(bytes calldata directive, address engine) internal view returns (bytes32) {
        DirectivePreview memory preview = load(directive);
        return digest(preview, engine);
    }

    function digest(DirectivePreview memory preview, address engine) internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                PREVIEW_DOMAIN,
                block.chainid,
                engine,
                preview.directiveKind,
                preview.commandHash
            )
        );
    }
}
