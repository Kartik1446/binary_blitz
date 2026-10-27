# EVM: Overseer

**Category:** Web3 / Smart Contract Security (Storage & Assembly)  
**Difficulty:** Hard  

---

### Challenge Description
> *"Guilds monopolize crafts. In so doing, they gatekeep competition. Why can I not sell and master my craft? Why must I pay their usurious prices? Why are only the descendants, acquaintances, and children of those in power accepted as apprentices? May they fall from their horses! A masterpiece they ask of journeymen if his desire is to become a master. I may not be a journeyman, but I am on a journey, and I will show them a masterpiece."*

The Guild system in `Overseer.sol` manages apprentice and master permissions using low-level storage routines. Exploit storage pointer mechanics to usurp guild master status.

### Provided Files
- `src/Challenge.sol`: Challenge gatekeeper.
- `src/Guild.sol`, `src/Overseer.sol`, `src/OverseerEye.sol`: Protocol contracts.
- `src/elders/Loyalist.sol`: Guild elder contract.
- `script/Deploy.s.sol`: Deployment script.
- `foundry.toml`: Configuration.

### Objective
Elevate your permissions to master status in the Guild contract to satisfy `challenge.isSolved() == true`.

### Flag Format
Submit upon satisfying `challenge.isSolved() == true`.
