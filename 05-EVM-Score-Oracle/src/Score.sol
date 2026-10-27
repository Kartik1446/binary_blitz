// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IScore} from "src/IScore.sol";
import {IOracle} from "src/IOracle.sol";

contract Score is IScore {
    address public immutable PLAYER;

    bytes32 public seed;
    address public oracle;

    constructor(address _oracle, address _player) payable {
        seed = keccak256(abi.encodePacked(block.number, block.timestamp, block.prevrandao, _player));
        oracle = _oracle;
        PLAYER = _player;
    }

    function solve(uint256[] calldata _indices) external {

        bytes32 _target = generateTarget();
        bytes32 _accumulator;
        uint256 _r = IOracle(oracle).getRotation();

        for (uint256 _i = 0; _i < _indices.length; _i++) {
            bytes32 _element = getElement(_indices[_i]);
            assembly {
                let mask := sub(shl(_r, 1), 1)
                let temp := add(_accumulator, and(_element, mask))
                temp := or(shl(_r, temp), shr(sub(256, _r), temp))
                _accumulator := xor(temp, _element)
            }
        }

        if (_accumulator != _target) revert Score_WrongSolution();

        (bool _ok,) = PLAYER.call{value: address(this).balance}("");
        if (!_ok) revert Score_TransferFailed();

        assembly {
            mstore(0x00, sload(seed.slot))
            mstore(0x20, number())
            let _gasLimit := add(mod(keccak256(0x00, 0x40), 40000), 10000)
            if gt(gas(), _gasLimit) {
                mstore(0x00, 0x021b0014)
                revert(0x1c, 0x04)
            }
        }
    }

    function isSolved() external view returns (bool _result) {
        assembly {
            _result := iszero(selfbalance())
        }
    }

    function generateTarget() public view returns (bytes32) {
        return keccak256(abi.encodePacked(seed, block.number));
    }

    function getElement(uint256 _index) public view returns (bytes32) {
        return keccak256(abi.encodePacked(seed, _index, block.number));
    }

    receive() external payable {}
}
