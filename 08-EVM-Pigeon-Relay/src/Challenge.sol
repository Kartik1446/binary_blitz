// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "src/Pigeon.sol";
import "src/SimpleSafe.sol";

contract Challenge {
    ICreateXLike public constant CREATEX = ICreateXLike(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);
    SimpleSafe public constant safe = SimpleSafe(payable(0x924054eF74BbAED1Dc1bA76C2117D3277A509067)); 
    address public immutable PLAYER;
    address public immutable KEEPER;

    Pigeon public immutable pigeonImplementation;
    ERC1967Proxy public immutable pigeonProxy;

    constructor(address player, address keeper) payable {
        require(msg.value >= 10 ether, "insufficient deploy funding");

        PLAYER = player;
        KEEPER = keeper;

        pigeonImplementation = new Pigeon();
        bytes memory initData = abi.encode(address(pigeonImplementation), abi.encodeCall(Pigeon.initialize, (safe, KEEPER)));
        bytes memory initCode = abi.encodePacked(type(ERC1967Proxy).creationCode, initData);
        pigeonProxy = ERC1967Proxy(payable(CREATEX.deployCreate3(bytes32("WonderlandCTFBestCTF"), initCode)));

        (bool ok,) = payable(address(pigeonProxy)).call{value: 10 ether}("");
        require(ok, "proxy funding failed");
    }

    function isSolved() external view returns (bool) {
        return address(pigeonProxy).balance < 7 ether;
    }
}


interface ICreateXLike {
    function deployCreate3(bytes32 salt, bytes memory initCode) external payable returns (address newContract);
}
