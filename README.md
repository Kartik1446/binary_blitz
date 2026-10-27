# ⚡ Binary Blitz CTF ⚡

> **Official Participant Handbook & Challenge Repository**  
> Welcome to **Binary Blitz**, an elite cybersecurity and smart contract security Capture The Flag (CTF) competition. This repository contains all official challenge files, contract sources, forensic artifacts, and deployment harnesses.

---

## 🎯 Table of Contents

- [Overview](#-overview)
- [Challenge Tracks & Distribution](#-challenge-tracks--distribution)
- [Master Challenge Catalog](#-master-challenge-catalog)
- [Prerequisites & Environment Setup](#-prerequisites--environment-setup)
  - [1. Web3 & EVM Tooling (Foundry)](#1-web3--evm-tooling-foundry)
  - [2. Forensics, Steganography & Network](#2-forensics-steganography--network)
  - [3. Database & OSINT](#3-database--osint)
- [EVM Challenge Architecture & Solving Guide](#-evm-challenge-architecture--solving-guide)
  - [How EVM Challenges Work](#how-evm-challenges-work)
  - [Writing and Executing Exploits](#writing-and-executing-exploits)
- [Flag Formats & Submission Rules](#-flag-formats--submission-rules)
- [Repository Structure](#-repository-structure)
- [Rules of Engagement](#-rules-of-engagement)
- [Troubleshooting & FAQs](#-troubleshooting--faqs)

---

## 🧭 Overview

Binary Blitz is designed to test your offensive security acumen across modern attack surfaces. From low-level EVM memory manipulation and DeFi economic exploits to 802.11 frame decryption, binary file carving, and real-world database forensics, each challenge is crafted to simulate authentic vulnerabilities.

- **Total Challenges:** 24
- **Primary Focus:** EVM / Smart Contract Security (16 Challenges) + Forensics, Crypto, Steganography, OSINT & SQL (8 Challenges)
- **Difficulty Range:** Easy-Medium to Very Hard

---

## 📊 Challenge Tracks & Distribution

```
┌─────────────────────────────────────────────────────────────┬───────┐
│ Category / Domain                                           │ Count │
├─────────────────────────────────────────────────────────────┼───────┤
│ 🛡️ Web3 / Smart Contract & DeFi Security (EVM)              │  16   │
│ 🔍 Digital Forensics, File Carving & Hex Repair             │   1   │
│ 📶 Network Forensics & Wireless Security                    │   1   │
│ 🖼️ Steganography (Spatial Bitplane & DOM)                   │   3   │
│ 🔐 Cryptography & Font CMap Hash Cracking                   │   1   │
│ 🗄️ Database Forensics & SQL Investigation                  │   1   │
│ 🌐 OSINT & Transit Schedule Deduction                       │   1   │
├─────────────────────────────────────────────────────────────┼───────┤
│ Total                                                       │  24   │
└─────────────────────────────────────────────────────────────┴───────┘
```

---

## 🗺️ Master Challenge Catalog

| # | Challenge Name | Category | Difficulty | Solved Condition / Flag Format | Key Focus / Vulnerability |
|:---:|:---|:---|:---:|:---|:---|
| **01** | [Cypher Handshake](01-Cypher-Handshake/README.md) | Network / Wireless | `Medium` | `BB{<cracked_key>}` | 802.11 IEEE capture, 4-Way EAPOL handshake extraction & WPA PSK recovery |
| **02** | [Fiftyville Mystery](02-Fiftyville-Mystery/README.md) | Database Forensics / SQL | `Medium` | `BB{Thief_City_Accomplice}` | Relational query correlation across 10 SQLite municipal tables |
| **03** | [Security Compliance Alert](03-Phishing-Email-Investigation/README.md) | Web Forensics / DOM Stego | `Easy-Medium` | `flag{...}` | Suspicious email DOM inspection, styling anomalies, covert payload |
| **04** | [EVM: Sentinel Protocol](04-EVM-Sentinel-Protocol/README.md) | Web3 / Smart Contracts | `Hard` | `challenge.isSolved() == true` | Operator module verification bypass, code hash trust boundaries |
| **05** | [EVM: Score Oracle](05-EVM-Score-Oracle/README.md) | Web3 / DeFi Security | `Medium-Hard` | `challenge.isSolved() == true` | Spot reserve metric manipulation, dynamic scoring calibration |
| **06** | [EVM: Red Memory](06-EVM-Red-Memory/README.md) | Web3 / Low-Level EVM | `Hard` | `challenge.isSolved() == true` | Transient storage semantics (`TSTORE`/`TLOAD`), memory boundaries |
| **07** | [EVM: Precompile 20](07-EVM-Precompile-20/README.md) | Web3 / Smart Contracts | `Hard` | `challenge.isSolved() == true` | Custom state precompile balance calculation edge case, state transitions |
| **08** | [EVM: Pigeon Relay](08-EVM-Pigeon-Relay/README.md) | Web3 / Smart Contracts | `Medium-Hard` | `challenge.isSolved() == true` | Execution delegation context confusion, smart wallet hijacking |
| **09** | [EVM: Overseer](09-EVM-Overseer/README.md) | Web3 / EVM Assembly | `Hard` | `challenge.isSolved() == true` | Low-level storage routines, assembly pointer collision, privilege usurpation |
| **10** | [Corrupted Document Recovery](10-Corrupted-Document-Recovery/README.md) | Forensics / File Carving | `Hard` | `Flag{...}` | Damaged PDF headers, corrupted dictionary tags & FlateDecode stream repair |
| **11** | [Hash Analysis](11-Hash-Analysis/README.md) | Crypto / PDF Forensics | `Medium-Hard` | `BB{<cracked_plaintext>}` | Font CMap (`ToUnicode`) mapping extraction, MD5 & SHA-1 cracking |
| **12** | [Magician's Secret](12-LSB-Steganography/README.md) | Forensics / Stego | `Medium-Hard` | `BB{<SECRET>_stego_revealed}` | Spatial LSB bitplane steganography extraction across RGB color channels |
| **13** | [Njeromin - The Gateway](13-Njeromin-Steganography/README.md) | Forensics / Stego | `Medium-Hard` | `BB{<KEYWORD>_njeromin_hidden}` | High-res PNG bitplane analysis, covert gateway token extraction |
| **14** | [Tokyo Metro Statement Analysis](14-Tokyo-Metro-Statement-Analysis/README.md) | OSINT / Transit Deduction | `Medium-Hard` | `PFSWT{time_date}` | Historical Tokyo delay certificates (遅延証明書), timeline deduction |
| **15** | [EVM: Balance Proof](15-EVM-Balance-Proof/README.md) | Web3 / Consensus & SSZ | `Hard` | `challenge.isSolved() == true` | EIP-4788 Beacon block roots, validator SSZ Merkle container proofs |
| **16** | [EVM: Blackout](16-EVM-Blackout/README.md) | Web3 / Access Control | `Medium-Hard` | `challenge.isSolved() == true` | Caller blacklist evasion, execution context & identity masquerade |
| **17** | [EVM: Cheese Lending](17-EVM-Cheese-Lending/README.md) | Web3 / DeFi Lending | `Hard` | `challenge.isSolved() == true` | Lending pool invariant violation, collateral pricing discrepancies |
| **18** | [EVM: Encoded Spell](18-EVM-Encoded-Spell/README.md) | Web3 / Calldata & ABI | `Medium-Hard` | `challenge.isSolved() == true` | Low-level calldata crafting, non-standard selector & ABI decoding |
| **19** | [EVM: EVMVM](19-EVM-VM-Interpreter/README.md) | Web3 / Custom VM Escape | `Very Hard` | `challenge.isSolved() == true` | Custom stack virtual machine jailbreak, opcode interpreter boundary escape |
| **20** | [EVM: Fixed Deposits](20-EVM-Fixed-Deposits/README.md) | Web3 / Vault Accounting | `Hard` | `challenge.isSolved() == true` | Vault share ratio manipulation, batch settlement payout exploitation |
| **21** | [EVM: Infinity Send](21-EVM-Infinity-Send/README.md) | Web3 / Token Distribution | `Medium-Hard` | `challenge.isSolved() == true` | Calldata forwarding bypass, inducing downstream execution revert |
| **22** | [EVM: Liquid Omens](22-EVM-Liquid-Omens/README.md) | Web3 / Liquidation Engine | `Very Hard` | `challenge.isSolved() == true` | Bad debt auction manipulation, directive preview math discrepancies |
| **23** | [EVM: Ludopathy](23-EVM-Ludopathy/README.md) | Web3 / On-Chain RNG | `Medium-Hard` | `challenge.isSolved() == true` | Predictable block timestamp & state PRNG exploitation to drain prize pool |
| **24** | [EVM: Meridian Credits](24-EVM-Meridian-Credits/README.md) | Web3 / Smart Accounts | `Hard` | `challenge.isSolved() == true` | Account recovery flaw, CannonGuard bypass & batch execution drain |

---

## 🛠️ Prerequisites & Environment Setup

### 1. Web3 & EVM Tooling (Foundry)

All smart contract challenges use **Foundry** (`forge`, `cast`, `anvil`).

#### Installing Foundry
- **Linux / macOS / WSL**:
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **Windows (PowerShell)**:
  Download the installer from [Foundry Releases](https://github.com/foundry-rs/foundry/releases) or use Cargo:
  ```powershell
  cargo install --git https://github.com/foundry-rs/foundry --profile release --locked forge cast anvil chisel
  ```

#### Installing Dependencies in EVM Challenges
Many EVM challenges reference `forge-std`, `forge-ctf`, `solmate`, or `OpenZeppelin`. When working in a challenge directory that requires dependencies:
```bash
# Inside the challenge folder:
forge install foundry-rs/forge-std@v1.7.1 --no-commit
```
If you encounter missing imports, verify the folder's `remappings.txt` matches your local `lib/` directory.

---

### 2. Forensics, Steganography & Network

Ensure you have the following packages and utilities installed:

- **Network Forensics:**
  - [Wireshark](https://www.wireshark.org/) / `tshark`
  - `aircrack-ng` suite (for WPA 4-way handshake analysis)
  - `hashcat` or `john` (for pre-shared key cracking)
- **Image Steganography:**
  - Python 3 with imaging libraries:
    ```bash
    pip install Pillow numpy opencv-python matplotlib
    ```
  - `zsteg` (for PNG LSB analysis: `gem install zsteg`)
  - `steghide`, `exiftool`
- **Binary & File Carving:**
  - Hex Editors: [ImHex](https://imhex.werwolv.net/), HxD, or 010 Editor
  - CLI tools: `xxd`, `binwalk`, `file`, `strings`
  - PDF diagnostic utilities: `qpdf`, `mutool`, `pdf-parser.py` (Didier Stevens)

---

### 3. Database & OSINT

- **Database Forensics (`02-Fiftyville-Mystery`):**
  - SQLite CLI (`sqlite3`) or GUI: [DB Browser for SQLite](https://sqlitebrowser.org/) / DBeaver
  - Quick launch:
    ```bash
    sqlite3 fiftyville.db
    .tables
    .schema
    ```
- **Web Forensics (`03-Phishing-Email-Investigation`):**
  - Any modern browser (Google Chrome, Firefox) + Developer Tools (`F12`) to inspect DOM trees, pseudo-elements, and hidden styling.
- **OSINT (`14-Tokyo-Metro-Statement-Analysis`):**
  - Web browser, search engines, and Japanese transit archives (Tokyo Metro historical delay certificates: 遅延証明書).

---

## ⚡ EVM Challenge Architecture & Solving Guide

### How EVM Challenges Work

Each EVM challenge directory is structured with:
- `src/`: Smart contracts under test.
- `src/Challenge.sol`: Verification contract containing the `isSolved()` victory condition.
- `script/Deploy.s.sol`: Deployment harness using `forge-ctf`.
- `foundry.toml`: Compiler profile and Solc version.

#### The Solved Condition
To claim a solve, your transactions must transition the state such that:
```solidity
challenge.isSolved() == true;
```

### Writing and Executing Exploits

#### Local Testing with Foundry
You can simulate your exploit locally using Foundry test runners:
```bash
# In the challenge directory:
forge test -vvvv
```

#### Writing an Attack Script
Create an exploit script (e.g., `script/Solve.s.sol`):
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/Challenge.sol";

contract SolveScript is Script {
    function run() external {
        address challengeAddr = vm.envAddress("CHALLENGE_ADDRESS");
        vm.startBroadcast();

        // 1. Deploy your exploit contract or execute transactions
        // 2. Trigger the vulnerability

        vm.stopBroadcast();

        // Verify solve state
        require(Challenge(challengeAddr).isSolved(), "Challenge not solved!");
    }
}
```

#### Launching Against Live Instances
When the competition scoring infrastructure provides an RPC URL and challenge instance address:
```bash
forge script script/Solve.s.sol \
  --rpc-url <INSTANCE_RPC_URL> \
  --private-key <PLAYER_PRIVATE_KEY> \
  --broadcast \
  -vvvv
```

---

## 🚩 Flag Formats & Submission Rules

Different tracks feature tailored flag formats. Always follow the specific pattern indicated in the challenge's `README.md`:

| Category / Challenge | Flag Pattern | Example | Notes |
|:---|:---|:---|:---|
| **Standard Binary Blitz** | `BB{<content>}` | `BB{dragon123}` | Case-sensitive unless stated |
| **Fiftyville Mystery (02)** | `BB{Thief_City_Accomplice}` | `BB{Bruce_NewYorkCity_Robin}` | Underscore-separated |
| **Phishing DOM (03)** | `flag{...}` | `flag{inspect_the_css}` | Recovered from HTML/DOM |
| **PDF Carving (10)** | `Flag{...}` | `Flag{h3x_r3pa1r_m4st3r}` | Recovered from repaired stream |
| **LSB Stego (12)** | `BB{<SECRET>_stego_revealed}` | `BB{ALOHOMORA_stego_revealed}` | Wrap recovered keyword |
| **Njeromin Stego (13)** | `BB{<KEYWORD>_njeromin_hidden}` | `BB{CYBER_njeromin_hidden}` | Wrap recovered keyword |
| **Tokyo Metro (14)** | `PFSWT{time_date}` | `PFSWT{14:30_15March}` | Format: `HH:MM_DMonth` |
| **EVM Challenges (04-09, 15-24)** | `challenge.isSolved() == true` | On-Chain State | Auto-verified by scoring bot / instance portal |

> [!TIP]
> Do not add extra whitespace, quotes, or newlines when submitting flags through the competition scoring portal.

---

## 📁 Repository Structure

```text
binary_blitz/
├── README.md                              <- You are here (Master Participant Guide)
│
├── 01-Cypher-Handshake/                   <- Network Forensics (802.11 / WPA Handshake)
├── 02-Fiftyville-Mystery/                 <- SQL Forensics (SQLite Database Investigation)
├── 03-Phishing-Email-Investigation/       <- Web / DOM Steganography (HTML/CSS)
│
├── 04-EVM-Sentinel-Protocol/              <- EVM: Module Verification & Trust Boundaries
├── 05-EVM-Score-Oracle/                   <- EVM: Oracle Pricing & Dynamic Metric Manipulation
├── 06-EVM-Red-Memory/                     <- EVM: Transient Storage (Cancun TSTORE/TLOAD)
├── 07-EVM-Precompile-20/                  <- EVM: Custom Precompile State Manipulation
├── 08-EVM-Pigeon-Relay/                   <- EVM: Execution Delegation & Smart Wallet Hijack
├── 09-EVM-Overseer/                       <- EVM: Inline Assembly & Storage Pointer Collisions
│
├── 10-Corrupted-Document-Recovery/        <- Forensics: Sabotaged PDF Carving & Stream Repair
├── 11-Hash-Analysis/                      <- Crypto: Font CMap Encoding & Hash Cracking
├── 12-LSB-Steganography/                  <- Stego: Spatial LSB Bitplane Decoding
├── 13-Njeromin-Steganography/             <- Stego: High-Resolution Pixel Extraction
├── 14-Tokyo-Metro-Statement-Analysis/     <- OSINT: Japanese Transit Certificate Deduction
│
├── 15-EVM-Balance-Proof/                  <- EVM: EIP-4788 Beacon Roots & SSZ Merkle Proofs
├── 16-EVM-Blackout/                       <- EVM: Access Control & Caller Blacklist Evasion
├── 17-EVM-Cheese-Lending/                 <- EVM: Lending Pool Invariants & Oracle Exploits
├── 18-EVM-Encoded-Spell/                  <- EVM: Non-Standard ABI Encoding & Calldata Crafting
├── 19-EVM-VM-Interpreter/                 <- EVM: Virtual Machine in Solidity / Sandbox Escape
├── 20-EVM-Fixed-Deposits/                 <- EVM: Vault Share Dilution & Batch Settlement
├── 21-EVM-Infinity-Send/                  <- EVM: Forwarding Calldata & Downstream Reverts
├── 22-EVM-Liquid-Omens/                   <- EVM: Liquidation Engine & Bad Debt Clearing
├── 23-EVM-Ludopathy/                      <- EVM: Predictable On-Chain Randomness & Casino Drain
└── 24-EVM-Meridian-Credits/               <- EVM: Smart Accounts, CannonGuard & Recovery Bypass
```

---

## 📜 Rules of Engagement

1. **Fair Play**: Sharing flags, solution scripts, or writeups during the competition window is strictly forbidden.
2. **Infrastructure Scope**: Do not attack, flood, or denial-of-service the competition platform, scoring server, RPC endpoints, or other participants. Only interact with your dedicated challenge instances.
3. **Local First**: Prototype and test your exploits locally using Foundry or local test harnesses before broadcasting on live RPCs.
4. **Responsible Disclosure**: If you discover a bug or unintended vulnerability in the CTF infrastructure, please report it immediately to the organizers.

---

## ❓ Troubleshooting & FAQs

### Q: `forge build` fails with `Source "forge-std/Test.sol" not found`
**Fix**: Install `forge-std` locally without committing:
```bash
forge install foundry-rs/forge-std@v1.7.1 --no-commit
```

### Q: In `06-EVM-Red-Memory`, the compiler complains about `tstore` or `tload`.
**Fix**: Transient storage opcodes (`TSTORE`, `TLOAD`) require the `cancun` EVM version. Add or ensure `evm_version = "cancun"` in your `foundry.toml`:
```toml
[profile.default]
evm_version = "cancun"
```

### Q: `Corrupt.pdf` fails to open in Acrobat / Chrome.
**Fix**: That is the challenge objective! Open the file in a hex editor (e.g. ImHex), inspect corrupted dictionary tags (e.g., `/Typ3`, damaged `/Length`, broken stream markers), fix the byte offsets, and uncompress the streams.

### Q: How do I test with mock balances or impersonate accounts locally?
**Fix**: In Foundry tests, use cheatcodes:
```solidity
vm.prank(attackerAddress);
vm.deal(attackerAddress, 10 ether);
```

---

<div align="center">
  <sub>Good luck, hack ethically, and may your exploits land on the first broadcast! 🚀</sub>
</div>
