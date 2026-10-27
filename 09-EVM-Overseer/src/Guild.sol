// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {IFolk} from "./interfaces/IFolk.sol";
import {IOverseer} from "./interfaces/IOverseer.sol";
import {OverseerEye} from "./OverseerEye.sol";

contract Guild is OverseerEye, IFolk {
    enum Verdict {
        None,
        Aye,
        Nay,
        Abstain
    }

    struct CouncilRules {
        uint256 verdictThreshold;
        uint256 duration;
    }

    struct DecreeParameters {
        uint256 startDate;
        uint256 lastDate;
        uint256 verdictThreshold;
    }

    struct Tally {
        uint256 aye;
        uint256 nay;
        uint256 abstain;
    }

    struct Edict {
        address to;
        uint256 value;
        bytes data;
    }

    struct Decree {
        bool enacted;
        address proposer;
        DecreeParameters parameters;
        Tally tally;
        Edict[] edicts;
        mapping(address => Verdict) verdicts;
    }

    error Trespasser();
    error ForbiddenAct();
    error UnworthyFolk();
    error InvalidDecree();
    error CannotCastVerdict();
    error CannotEnactDecree();
    error EdictFailed();
    error InvalidCouncilRule();
    error InvalidFolkForRank();

    uint256 public constant MINIMUM_DURATION = 1;

    bytes32 public constant OVERSEER_ROLE = keccak256("OVERSEER");
    bytes32 public constant ELDER = keccak256("ELDER");
    bytes32 public constant GUILD_ROLE = keccak256("GUILD");

    bytes32 public constant DECREE_PROPOSED = keccak256("DECREE_PROPOSED");
    bytes32 public constant DECREE_VOTED = keccak256("DECREE_VOTED");
    bytes32 public constant DECREE_ENACTED = keccak256("DECREE_ENACTED");
    bytes32 public constant DECREE_TERMS_SET = keccak256("DECREE_TERMS_SET");
    bytes32 public constant ELDER_APPOINTED = keccak256("ELDER_APPOINTED");
    bytes32 public constant ELDER_DISMISSED = keccak256("ELDER_DISMISSED");

    address public immutable PLAYER;
    bytes16 public badge;

    CouncilRules internal _councilRules;
    uint256 public totalElders;
    mapping(bytes16 => Decree) internal _decrees;

    constructor(
        address _player,
        IOverseer _overseer,
        CouncilRules memory _initialRules,
        address[] memory _initialElders
    ) OverseerEye(_overseer) {
        PLAYER = _player;
        badge = _overseer.enroll();

        for (uint256 i; i < _initialElders.length; i++) {
            _addElder(_initialElders[i]);
        }

        _updateCouncilRules(_initialRules);

        _grantRank(OVERSEER_ROLE, address(_overseer));
        _grantRank(GUILD_ROLE, address(this));
    }

    function write(bytes16 _fromBadge, bytes32 _activity, bytes32 _subject, bytes calldata _data) external override {
        if (!hasRank(OVERSEER_ROLE, msg.sender)) revert Trespasser();
        address _fromFolk = overseer.badgeToFolk(_fromBadge);

        if (_activity == DECREE_PROPOSED) {
            _proposeDecree(_fromFolk, _data);
        } else if (_activity == DECREE_VOTED) {
            _castVerdict(_fromFolk, _data);
        } else if (_activity == DECREE_ENACTED) {
            _enactDecree(_data);
        } else {
            revert ForbiddenAct();
        }
    }

    function addElder(address _newElder) public {
        if (!hasRank(GUILD_ROLE, msg.sender)) revert Trespasser();
        _addElder(_newElder);
    }

    function removeElder(address _oldElder) public {
        if (!hasRank(GUILD_ROLE, msg.sender)) revert Trespasser();
        _removeElder(_oldElder);
    }

    function updateCouncilRules(CouncilRules calldata _newRules) public {
        if (!hasRank(GUILD_ROLE, msg.sender)) revert Trespasser();
        _updateCouncilRules(_newRules);
    }

    function isVerdictThresholdReached(bytes16 _decreeId) public view returns (bool) {
        Decree storage decree_ = _decrees[_decreeId];
        if (block.number <= decree_.parameters.lastDate) return false;
        if (decree_.tally.aye >= decree_.parameters.verdictThreshold) return true;
        return false;
    }

    function councilRules() public view returns (CouncilRules memory) {
        return _councilRules;
    }

    function getDecreeInfo(
        bytes16 _decreeId
    )
        public
        view
        returns (
            bool _enacted,
            address _proposer,
            DecreeParameters memory _parameters,
            Tally memory _tally,
            Edict[] memory _edicts
        )
    {
        Decree storage d = _decrees[_decreeId];
        _enacted = d.enacted;
        _proposer = d.proposer;
        _parameters = d.parameters;
        _tally = d.tally;
        _edicts = d.edicts;
    }

    function getDecreeVerdict(bytes16 _decreeId, address _folk) external view returns (Verdict) {
        return _decrees[_decreeId].verdicts[_folk];
    }

    function _updateCouncilRules(CouncilRules memory _newRules) internal {
        if (_newRules.verdictThreshold > totalElders) revert InvalidCouncilRule();
        if (_newRules.duration < MINIMUM_DURATION) revert InvalidCouncilRule();
        _councilRules = _newRules;
    }

    function _proposeDecree(address _fromFolk, bytes calldata _data) internal {
        (bytes16 _decreeId, Edict[] memory _edicts) = abi.decode(_data, (bytes16, Edict[]));
        Decree storage decree_ = _decrees[_decreeId];
        if (decree_.parameters.startDate != 0) revert InvalidDecree();
        if (!hasRank(ELDER, _fromFolk)) revert UnworthyFolk();

        decree_.proposer = _fromFolk;
        decree_.parameters.startDate = block.number;
        decree_.parameters.lastDate = block.number + _councilRules.duration;
        decree_.parameters.verdictThreshold = _councilRules.verdictThreshold;

        for (uint256 i; i < _edicts.length; i++) {
            decree_.edicts.push(_edicts[i]);
        }

        _herald(
            DECREE_TERMS_SET,
            bytes32(_decreeId),
            abi.encode(decree_.parameters.startDate, decree_.parameters.lastDate, decree_.parameters.verdictThreshold)
        );
    }

    function _castVerdict(address _fromFolk, bytes calldata _data) internal {
        (bytes16 _decreeId, Verdict _verdict) = abi.decode(_data, (bytes16, Verdict));
        if (!_canVote(_fromFolk, _decreeId, _verdict)) revert CannotCastVerdict();

        Decree storage decree_ = _decrees[_decreeId];

        Verdict prev = decree_.verdicts[_fromFolk];
        if (prev == Verdict.Aye) {
            decree_.tally.aye--;
        } else if (prev == Verdict.Nay) {
            decree_.tally.nay--;
        } else if (prev == Verdict.Abstain) {
            decree_.tally.abstain--;
        }

        if (_verdict == Verdict.Aye) {
            decree_.tally.aye++;
        } else if (_verdict == Verdict.Nay) {
            decree_.tally.nay++;
        } else if (_verdict == Verdict.Abstain) {
            decree_.tally.abstain++;
        }

        decree_.verdicts[_fromFolk] = _verdict;
    }

    function _enactDecree(bytes calldata _data) internal {
        bytes16 _decreeId = abi.decode(_data, (bytes16));
        Decree storage decree_ = _decrees[_decreeId];
        if (decree_.enacted) revert CannotEnactDecree();
        if (decree_.parameters.startDate == 0) revert CannotEnactDecree();
        if (!isVerdictThresholdReached(_decreeId)) revert CannotEnactDecree();

        decree_.enacted = true;

        Edict[] memory edicts = decree_.edicts;
        for (uint256 i; i < edicts.length; i++) {
            (bool success,) = edicts[i].to.call{value: edicts[i].value}(edicts[i].data);
            if (!success) revert EdictFailed();
        }
    }

    function _addElder(address _newElder) internal {
        if (hasRank(ELDER, _newElder)) revert InvalidFolkForRank();
        bytes16 _folkBadge = _grantRank(ELDER, _newElder);
        totalElders++;
        _herald(ELDER_APPOINTED, bytes32(_folkBadge), abi.encode(_newElder));
    }

    function _removeElder(address _oldElder) internal {
        if (!hasRank(ELDER, _oldElder)) revert InvalidFolkForRank();
        if (_councilRules.verdictThreshold == totalElders) revert InvalidCouncilRule();
        bytes16 _folkBadge = _revokeRank(ELDER, _oldElder);
        totalElders--;
        _herald(ELDER_DISMISSED, bytes32(_folkBadge), abi.encode(_oldElder));
    }

    function _herald(bytes32 _activity, bytes32 _subject, bytes memory _data) internal {
        overseer.oversee(badge, badge, _activity, _subject, _data);
    }

    function _canVote(address _folk, bytes16 _decreeId, Verdict _verdict) internal view returns (bool) {
        Decree storage decree_ = _decrees[_decreeId];
        if (decree_.parameters.startDate == 0) return false;
        if (block.number > decree_.parameters.lastDate) return false;
        if (decree_.enacted) return false;
        if (_verdict == Verdict.None) return false;
        if (!hasRank(ELDER, _folk)) return false;
        return true;
    }

    receive() external payable {}
}
