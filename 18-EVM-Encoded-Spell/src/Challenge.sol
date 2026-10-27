// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

struct Spell {
    string name;
    bytes32[8] enchantments;
}

contract Challenge {
    bool        public unleashed;
    uint256     public mana;
    bytes32     public masterSeal;
    bytes32[8]  public weakSeals;

    constructor(address) {}

    function createMagicCircle(string calldata runes, bytes32 newMasterSeal) external {
        mana = msg.data.length;
        masterSeal = newMasterSeal;
        weakSeals = abi.decode(bytes(runes), (bytes32[8]));
    }

    function cast(Spell calldata spell) external {
        // Spells in the Grimoire
        bytes32 secretSpellName = keccak256(bytes(spell.name));
        require(
            (secretSpellName == keccak256("CURE")   && mana == 100) ||
            (secretSpellName == keccak256("CURA")   && mana == 200) ||
            (secretSpellName == keccak256("CURAGA") && mana == 300) ||
            (secretSpellName == keccak256("ULTIMA") && mana == 6e66)
        );

        // Each weak seal must be broken by a powerful enchantment
        for (uint i; i < weakSeals.length; i++) {
            bool brokenSeal = spell.enchantments[i] > weakSeals[i];
            require(brokenSeal);
        }

        // The power balance of the spell must match the one of the master seal
        require(keccak256(abi.encode(spell)) == masterSeal);

        // The full power of the spell is unleashed
        unleashed = true;
    }

    function isSolved() external view returns (bool) {
        return unleashed;
    }
}
