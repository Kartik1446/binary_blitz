// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {MeridianCredits} from './MeridianCredits.sol';
import {LegacyReserveOps} from './LegacyReserveOps.sol';
import {BatchExecutor} from './BatchExecutor.sol';
import {SafeSmartWallet} from './SafeSmartWallet.sol';
import {CannonGuard} from './CannonGuard.sol';
import {AccountRecoveryV1} from './AccountRecoveryV1.sol';
import {AccountRecovery} from './AccountRecovery.sol';
import {SharedEscrow} from './SharedEscrow.sol';
import {GovernanceModule} from './GovernanceModule.sol';
import {SovereignAI} from './SovereignAI.sol';

/// @title Meridian Concordat Challenge
contract Challenge {
  address public immutable PLAYER;
  // ═══════════════════════════════════════════════════════════
  // Implementation contracts
  // ═══════════════════════════════════════════════════════════
  LegacyReserveOps public immutable LEGACY_OPS;
  BatchExecutor public immutable BATCH_EXECUTOR;
  SafeSmartWallet public immutable SAFE_WALLET;
  CannonGuard public immutable CANNON_GUARD;
  AccountRecoveryV1 public immutable ACCOUNT_RECOVERY_V1;
  AccountRecovery public immutable ACCOUNT_RECOVERY_V2;
  SharedEscrow public immutable SHARED_ESCROW;
  GovernanceModule public immutable GOVERNANCE;
  SovereignAI public immutable SOVEREIGN_AI;

  // ═══════════════════════════════════════════════════════════
  // Reserve stations
  // ═══════════════════════════════════════════════════════════
  address public immutable BOREAS;
  address public immutable HELIX;
  address public immutable VORTAN;
  address public immutable DRIFT;
  address public immutable THALIAN;
  address public immutable KAEL;
  address public immutable AXIOM;

  // ═══════════════════════════════════════════════════════════
  // MRC token
  // ═══════════════════════════════════════════════════════════
  MeridianCredits public immutable MRC;

  /// @param _system The system/deployer address (used as CannonGuard commander)
  /// @param _player The player address
  /// @param _reserves Array of 7 reserve station addresses
  constructor(address _system, address _player, address[] memory _reserves) {
    PLAYER = _player;
    LEGACY_OPS = new LegacyReserveOps();
    BATCH_EXECUTOR = new BatchExecutor();
    SAFE_WALLET = new SafeSmartWallet();
    CANNON_GUARD = new CannonGuard(_system);
    ACCOUNT_RECOVERY_V1 = new AccountRecoveryV1();
    ACCOUNT_RECOVERY_V2 = new AccountRecovery();
    SHARED_ESCROW = new SharedEscrow();
    GOVERNANCE = new GovernanceModule();
    SOVEREIGN_AI = new SovereignAI();

    // Store station addresses
    BOREAS = _reserves[0];
    HELIX = _reserves[1];
    VORTAN = _reserves[2];
    DRIFT = _reserves[3];
    THALIAN = _reserves[4];
    KAEL = _reserves[5];
    AXIOM = _reserves[6];

    // Station mint allowances
    uint256[] memory allowances = new uint256[](7);
    allowances[0] = 500_000 * 10 ** 18; // Boreas Station
    allowances[1] = 500_000 * 10 ** 18; // Helix Citadel
    allowances[2] = 200_000 * 10 ** 18; // Vortan Nexus
    allowances[3] = 0; // Drift Sector
    allowances[4] = 200_000 * 10 ** 18; // Thalian Reach
    allowances[5] = 300_000 * 10 ** 18; // Kael Bastion
    allowances[6] = 300_000 * 10 ** 18; // AXIOM

    MRC = new MeridianCredits(_player, _reserves, allowances);
  }

  /// @notice Check if the challenge is solved
  function isSolved() external view returns (bool) {
    return MRC.isSolved();
  }
}
