// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-ctf/CTFDeployer.sol";

import "src/CheeseLending.sol";
import "src/Cheese.sol";
import "./Cow.s.sol";


contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        vm.startBroadcast(system);

        uint256 initialSupply = 0;
        Cheese gruyere = new Cheese(initialSupply, "Gruyere", "GRY");
        Cheese emmental = new Cheese(initialSupply, "Emmental", "ETL");

        CheeseLending cheeseLending = new CheeseLending(player, address(gruyere), address(emmental));

        Cow cow = new Cow(cheeseLending);

        gruyere.mint(player, 100 * 1e18);
        gruyere.mint(address(cow), 10 * 1e18);
        gruyere.dropMint();
        require(gruyere.totalSupply() == 110 * 1e18);

        emmental.mint(player, 100 * 1e18);
        emmental.mint(address(cow), 10 * 1e18);
        emmental.dropMint();

        require(emmental.totalSupply() == 110 * 1e18);

        cow.init(gruyere, emmental);

        challenge = address(cheeseLending);


        require(emmental.balanceOf(address(cheeseLending))>0);
        require(gruyere.balanceOf(address(cheeseLending))>0);


        vm.stopBroadcast();
    }
}


