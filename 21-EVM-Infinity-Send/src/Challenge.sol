// SPDX-License-Identifier: MIT
// aderyn-ignore-next-line(push-zero-opcode,unspecific-solidity-pragma)
pragma solidity ^0.8.0;

import {InfinityToken} from "src/InfinityToken.sol";

/// @title Challenge
/// @author patrickalphac
contract Challenge {
    address public immutable PLAYER;
    uint256 public constant FOUR_BYTE = 4;
    address public constant MONEY_MOVES = 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A;
    uint256 public constant STARTING_MONEY = 1000e18;
    InfinityToken public immutable TOKEN;

    bool private solved;

    constructor(address player) {
        PLAYER = player;
        TOKEN = new InfinityToken(STARTING_MONEY);
    }

    error Challenge__InvalidCalldata();

    // aderyn-ignore-next-line(state-change-without-event)
    function sendMoney(bytes calldata data) external {
        if (!validateCalldata(data)) revert Challenge__InvalidCalldata();

        (uint256 v, uint256 n, uint256 t) = _preflight();

        // aderyn-ignore-next-line(reentrancy-state-change,unsafe-erc20-operation)
        TOKEN.approve(MONEY_MOVES, STARTING_MONEY);
        // aderyn-ignore-next-line(reentrancy-state-change)
        (bool resp,) = MONEY_MOVES.call(data);

        _postcheck(resp, v, n, t);

        TOKEN.resetBalance();
    }

    function _preflight() internal view returns (uint256 ver, uint256 nonce, uint256 thresh) {
        assembly {
            let fmp := mload(0x40)

            mstore(fmp, hex"b187bd26")
            let ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            if mload(fmp) { revert(0, 0) }

            mstore(fmp, hex"0d8e6e2c")
            ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            ver := mload(fmp)

            mstore(fmp, hex"3408e470")
            ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            nonce := mload(fmp)

            mstore(fmp, hex"e75235b8")
            ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            thresh := mload(fmp)
        }
    }

    // aderyn-ignore-next-line(state-change-without-event)
    function _postcheck(bool resp, uint256 prevVer, uint256 prevNonce, uint256 prevThresh) internal {
        uint256 postVer;
        uint256 postNonce;
        uint256 postThresh;

        assembly {
            let fmp := mload(0x40)

            mstore(fmp, hex"0d8e6e2c")
            let ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            postVer := mload(fmp)

            mstore(fmp, hex"3408e470")
            ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            postNonce := mload(fmp)

            mstore(fmp, hex"e75235b8")
            ok := staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, 0x04, fmp, 0x20)
            if iszero(ok) { revert(0, 0) }
            postThresh := mload(fmp)
        }

        if (postVer != prevVer) revert();
        if (postNonce != prevNonce) revert();
        if (postThresh != prevThresh) revert();

        if (!resp) {
            solved = true;
        }
    }

    // aderyn-ignore-next-line(unused-public-function)
    function validateCalldata(bytes calldata data) public view returns (bool) {
        if (data.length < FOUR_BYTE) return false;

        bytes4 sig;
        assembly {
            sig := calldataload(data.offset)
        }
        if (uint32(sig) ^ uint32(0xdeadbeef) != uint32(0x7e1ec59c)) return false;

        address tokenAddress;
        uint256 recipLen;
        uint256 amtLen;
        uint256 totalAmount;
        uint256 sum;

        assembly {
            let cd := add(data.offset, 4)

            tokenAddress := calldataload(cd)

            let off1 := calldataload(add(cd, 0x20))
            let off2 := calldataload(add(cd, 0x40))
            totalAmount := calldataload(add(cd, 0x60))

            let arr1Pos := add(cd, off1)
            let arr1Len := calldataload(arr1Pos)

            let arr2Pos := add(cd, off2)
            let arr2Len := calldataload(arr2Pos)

            recipLen := arr1Len
            amtLen := arr2Len

            for { let i := 0 } lt(i, arr2Len) { i := add(i, 1) } {
                sum := add(sum, calldataload(add(arr2Pos, mul(add(i, 1), 0x20))))
            }
        }

        if (tokenAddress != address(TOKEN)) return false;
        if (recipLen != amtLen) return false;
        if (sum > STARTING_MONEY) return false;
        if (sum != totalAmount) return false;

        _validateSignature(data);
        return true;
    }

    function _validateSignature(bytes calldata data) internal view {
        assembly {
            let cd := add(data.offset, 4)
            let off1 := calldataload(add(cd, 0x20))
            let off2 := calldataload(add(cd, 0x40))

            let arr1Pos := add(cd, off1)
            let arr1Len := calldataload(arr1Pos)
            let arr2Pos := add(cd, off2)
            let arr2Len := calldataload(arr2Pos)

            let fmp := mload(0x40)
            mstore(fmp, hex"4d88119a")
            mstore(add(fmp, 0x04), 0x40)
            let arr1DataSize := mul(add(arr1Len, 1), 0x20)
            mstore(add(fmp, 0x24), add(0x40, arr1DataSize))
            let writePos := add(fmp, 0x44)
            mstore(writePos, arr1Len)
            writePos := add(writePos, 0x20)
            for { let i := 0 } lt(i, arr1Len) { i := add(i, 1) } {
                mstore(writePos, calldataload(add(arr1Pos, mul(add(i, 1), 0x20))))
                writePos := add(writePos, 0x20)
            }
            mstore(writePos, arr2Len)
            writePos := add(writePos, 0x20)
            for { let i := 0 } lt(i, arr2Len) { i := add(i, 1) } {
                mstore(writePos, calldataload(add(arr2Pos, mul(add(i, 1), 0x20))))
                writePos := add(writePos, 0x20)
            }
            let callSize := sub(writePos, fmp)
            pop(staticcall(gas(), 0x6b28050C71313e4Cce8886EBEE6946B4CA0F0b9A, fmp, callSize, 0x00, 0x00))
        }
    }

    function isSolved() external view returns (bool) {
        return solved;
    }
}
