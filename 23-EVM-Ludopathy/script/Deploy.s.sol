// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFDeployer.sol";
import "src/Ludopathy.sol";
import "src/Challenge.sol";

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        Ludopathy ludopathy = new Ludopathy(system);

        uint96[] memory nums1 = new uint96[](1);
        nums1[0] = 42;
        uint200[] memory amts1 = new uint200[](1);
        amts1[0] = 5;
        ludopathy.largeBet{value: 5 ether}(nums1, amts1);

        uint96[] memory nums2 = new uint96[](3);
        nums2[0] = 123;
        nums2[1] = 456;
        nums2[2] = 789;
        uint200[] memory amts2 = new uint200[](3);
        amts2[0] = 2;
        amts2[1] = 1;
        amts2[2] = 2;
        ludopathy.largeBet{value: 5 ether}(nums2, amts2);

        uint96[] memory nums3 = new uint96[](3);
        nums3[0] = 100;
        nums3[1] = 121;
        nums3[2] = 144;
        uint200[] memory amts3 = new uint200[](3);
        amts3[0] = 3;
        amts3[1] = 1;
        amts3[2] = 1;
        ludopathy.largeBet{value: 5 ether}(nums3, amts3);

        ludopathy.selectWinningNumber(999);

        challenge = address(new Challenge(ludopathy));

        vm.stopBroadcast();
    }
}
