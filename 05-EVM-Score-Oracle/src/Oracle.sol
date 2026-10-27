// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IOracle} from "src/IOracle.sol";

contract Oracle is IOracle {
    uint256 public constant MIN_CONTRIBUTORS = 3;

    uint256 private _entropy; 
    uint256 private _scale;
    uint256 public contributorCount;
    mapping(address => uint256) public contributions;

    constructor() payable {
        _entropy = uint256(keccak256(abi.encodePacked(block.number, block.timestamp, block.prevrandao)));
    }

    function contribute(uint256 _value) external payable {
        if (_value == 0) revert Oracle_InvalidContribution();

        _entropy = uint256(keccak256(abi.encodePacked(_entropy, _value, msg.sender)));
        contributions[msg.sender] = _value;
        _scale += _value;
        contributorCount++;
    }

    function poke() external {
        _entropy ^= uint256(keccak256(abi.encodePacked(block.number, msg.sender)));
    }

    function getRotation() external view returns (uint256 _rotation) {
        assembly {
            if lt(sload(0x02), 3) {
                mstore(0x00, 0x27dd2fbf)
                revert(0x1c, 0x04)
            }

            mstore(0x00, sload(0x00))
            mstore(0x20, sload(0x02))

            let _key := keccak256(0x00, 0x40)

            let _hi := shr(128, _key)
            let _lo := and(_key, 0xffffffffffffffffffffffffffffffff)
            let _mixed := xor(_hi, shl(64, _lo))
            _mixed := or(shr(7, _mixed), shl(249, _mixed))

            let _s := sload(0x01)
            let _reconstructed := xor(mul(div(selfbalance(), _s), _s), mod(selfbalance(), _s))
            let _base := xor(_mixed, _reconstructed)
            _rotation := mod(_base, 0x80)
        }
    }
}
