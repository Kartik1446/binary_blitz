// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {IOverseer} from "src/interfaces/IOverseer.sol";
import {Overseer} from "src/Overseer.sol";
import {Guild} from "src/Guild.sol";
import {SealedTurncloak} from "src/elders/SealedTurncloak.sol";
import {Loyalist} from "src/elders/Loyalist.sol";

contract Challenge {
    address public immutable PLAYER;
    Overseer public immutable overseer;
    Guild public immutable guild;
    SealedTurncloak public immutable sealedTurncloak;
    Loyalist public immutable loyalistFolk;

    constructor(address player) payable {
        PLAYER = player;

        overseer = new Overseer(player);

        sealedTurncloak = new SealedTurncloak(IOverseer(address(overseer)));
        loyalistFolk = new Loyalist(IOverseer(address(overseer)), 0xf5930c6AC61D6bdD2cB8d3312beBe506DEab78Cc);

        address[] memory initialElders = new address[](3);
        initialElders[0] = address(sealedTurncloak);
        initialElders[1] = address(loyalistFolk);
        initialElders[2] = player;

        guild = new Guild(
            player,
            IOverseer(address(overseer)),
            Guild.CouncilRules({verdictThreshold: 3, duration: 15}),
            initialElders
        );

        sealedTurncloak.setGuild(address(guild));
        loyalistFolk.setGuild(address(guild));

        (bool ok,) = address(guild).call{value: msg.value}("");
        require(ok);
    }

    function isSolved() external view returns (bool) {
        return address(guild).balance == 0;
    }
}
