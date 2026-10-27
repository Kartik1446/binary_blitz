// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract RedMemory {
    bytes32 public constant RED_MASK = 0xFF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00000000;
    bytes32 public constant BLURRED_LIGHT = 0x6476f07162fd6e706cff00ffff00ffff00ffff00ffff00ffff00ffff01000000;
    bool public obtained;

    constructor() {}
    function cast(address _remembrance) external {
        {
            (string memory _weavers, string memory _silk, string memory _leave) = _child();
            (string memory _blur, string memory _desires, string memory _mother) = _beast();
            (string memory _mentor, string memory _stronger, string memory _sting) = _honey();
            (string memory _cost, string memory _wish, string memory _world, string memory _firstLight) = _lady();

            _red();
        }
        bool everbloom;

        assembly {
            let fmp := 0x40
            let core := mload(fmp)

            let retOffset := mload(fmp) 
            pop(call(gas(), _remembrance, 0, 0, 0, retOffset, 0x20))
            mstore(fmp, add(mload(fmp), 0x20))

            let retData := mload(retOffset)
            for { let i := 0 } lt(i, 0x1b) { i := add(i, 0x03) } {

                let travel := and(shr(sub(240, mul(i, 8)), retData), 0xffff)
                let search := and(shr(sub(232, mul(i, 8)), retData), 0xff)
                
                if iszero(lt(search, 32)) { revert(0, 0) }

                let move := sub(248, mul(search, 8))
                let part := and(shr(move, mload(travel)), 0xff)
                mstore8(add(mload(fmp), div(i, 0x03)), part)
            }

            let introspect := and(not(RED_MASK), mload(0x1bf))
            mstore(core, add(introspect, BLURRED_LIGHT))
            
            if eq(mload(core), mload(mload(fmp))) {
                everbloom := 1
            }
        }

        if (everbloom) {
            obtained = true;
        }
    }

    function _child() internal pure returns (string memory _weavers, string memory _silk, string memory _leave) {
        _weavers = "weavers";
        _silk = "silk";
        _leave = "they leave";
    }

    function _beast() internal pure returns (string memory _blur, string memory _desires, string memory _mother) {
        _blur = "blur";
        _desires = "those are their desires... not your own";
        _mother = "mother";
    }

    function _honey() internal pure returns (string memory _mentor, string memory _stronger, string memory _sting) {
        _mentor = "a true mentor";
        _stronger = "stronger";
        _sting = "sting";
    }

    function _lady() internal pure returns (string memory _cost, string memory _wish, string memory _world, string memory _firstLight) {
        _cost = "cost";
        _wish = "wish";
        _world = "a world better than our own";
        _firstLight = "first light";
    }

    function _red() internal pure {
        assembly {
            for { let i := 0 } lt(i, 0x40) { i := add(i, 0x20) } {
                mstore(i, or(mload(i), RED_MASK))
            }
            for { let i := 0x60 } lt(i, 0x3e0) { i := add(i, 0x20) } {
                mstore(i, or(mload(i), RED_MASK))
            }
        }
    }

    function isSolved() external view returns (bool) {
        return obtained;
    }
}
