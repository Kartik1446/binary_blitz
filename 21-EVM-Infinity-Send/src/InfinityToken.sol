// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InfinityToken is ERC20 {
    address public immutable OWNER;
    uint256 public immutable INITIAL_SUPPLY;

    address[] private _touchedAddresses;
    mapping(address => bool) private _isTouched;

    error InfinityToken__OnlyOwner();

    constructor(uint256 initialSupply) ERC20("InfinityToken", "INF") {
        OWNER = msg.sender;
        INITIAL_SUPPLY = initialSupply;
        _mint(msg.sender, initialSupply);
    }

    function resetBalance() external {
        if (msg.sender != OWNER) revert InfinityToken__OnlyOwner();

        // aderyn-ignore-next-line(costly-loop)
        for (uint256 i = 0; i < _touchedAddresses.length; ++i) {
            address addr = _touchedAddresses[i];
            uint256 bal = balanceOf(addr);
            if (bal > 0) {
                _burn(addr, bal);
            }
            _isTouched[addr] = false;
        }
        delete _touchedAddresses;

        _mint(OWNER, INITIAL_SUPPLY);
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);

        if (to != address(0) && !_isTouched[to]) {
            _isTouched[to] = true;
            _touchedAddresses.push(to);
        }
    }
}
