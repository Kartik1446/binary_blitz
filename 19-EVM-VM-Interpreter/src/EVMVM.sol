pragma solidity 0.8.33;

contract EVMVM {

    struct Data {
        bool initialised;
        bytes32[] stack;
        bytes32[] mem;
    }

    address public owner;
    address public CURRENT_USER;
    uint    public total_users;

    mapping (address => Data) public user_data;

    uint constant public MAX_USERS      = 1;
    uint constant public MAX_MEM_LEN    = (1 << 224) - 1;

    constructor() {
        owner = msg.sender;
    }

    function is_initialised(address user) external view returns (bool) {
        return user_data[user].initialised;
    }

    function get_stack(address user) external view returns (bytes32[] memory) {
        return user_data[user].stack;
    }

    function get_stack_length(address user) external view returns (uint) {
        return user_data[user].stack.length;
    }

    function get_stack_value(address user, uint p) external view returns (bytes32) {
        return user_data[user].stack[p];
    }

    function get_mem(address user) external view returns (bytes32[] memory) {
        return user_data[user].mem;
    }

    function get_mem_length(address user) external view returns (uint) {
        return user_data[user].mem.length;
    }

    function get_mem_value(address user, uint p) external view returns (bytes32) {
        return user_data[user].mem[p];
    }

    function create_user() external payable {
        require(total_users < MAX_USERS, "MAX_USERS");
        require(!user_data[msg.sender].initialised, "ALREADY_INITIALISED");
        total_users += 1;
        user_data[msg.sender].initialised = true;
    }

    function delete_user(address user) external {
        require(msg.sender == owner, "ONLY_OWNER");
        require(user_data[user].initialised, "NOT_INITIALISED");
        total_users -= 1;
        delete user_data[user];
    }

    function run(bytes calldata input) external {
        _run(msg.sender, input);
    }

    function run_for(bytes calldata input, bytes calldata sig) external {
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(sig, (uint8, bytes32, bytes32));
        address user = ecrecover(_hash_input(input), v, r, s);
        _run(user, input);
    }

    function _hash_input(bytes calldata input) private returns (bytes32) {
        return keccak256(abi.encodePacked(
            address(this),
            "runFor(bytes,bytes)",
            input
        ));
    }

    function _run(address user, bytes calldata input) private {
        require(CURRENT_USER == address(0), "REENTRANT");
        CURRENT_USER = user;

        for (uint ptr; ptr < input.length; ptr += 1) {
            if (input[ptr] == OPCODE_POP) {
                _pop();
            } else if (input[ptr] == OPCODE_PUSH) {
                require(ptr + 32 < input.length, "OUT_OF_BOUNDS");
                _push(bytes32(input[ptr + 1 : ptr + 33]));
                ptr += 32;
            } else if (input[ptr] == OPCODE_ADD) {
                _add();
            } else if (input[ptr] == OPCODE_SUB) {
                _sub();
            } else if (input[ptr] == OPCODE_MUL) {
                _mul();
            } else if (input[ptr] == OPCODE_DIV) {
                _div();
            } else if (input[ptr] == OPCODE_MOD) {
                _mod();
            } else if (input[ptr] == OPCODE_EXP) {
                _exp();
            } else if (input[ptr] == OPCODE_NOT) {
                _not();
            } else if (input[ptr] == OPCODE_LT) {
                _lt();
            } else if (input[ptr] == OPCODE_LTE) {
                _lte();
            } else if (input[ptr] == OPCODE_GT) {
                _gt();
            } else if (input[ptr] == OPCODE_GTE) {
                _gte();
            } else if (input[ptr] == OPCODE_EQ) {
                _eq();
            } else if (input[ptr] == OPCODE_AND) {
                _and();
            } else if (input[ptr] == OPCODE_OR) {
                _or();
            } else if (input[ptr] == OPCODE_XOR) {
                _xor();
            } else if (input[ptr] == OPCODE_DUP) {
                _dup();
            } else if (input[ptr] == OPCODE_SHL) {
                _shl();
            } else if (input[ptr] == OPCODE_SHR) {
                _shr();
            } else if (input[ptr] == OPCODE_ALLOC) {
                _alloc();
            } else if (input[ptr] == OPCODE_DEALLOC) {
                _alloc();
            } else if (input[ptr] == OPCODE_READ) {
                _read();
            } else if (input[ptr] == OPCODE_WRITE) {
                _write();
            } else if (input[ptr] == OPCODE_COPY) {
                _copy();
            } else {
                revert("INVALID OPCODE");
            }
        }

        CURRENT_USER = address(0);
    }

    function _stackSlot() private returns (bytes32 s, bytes32 ds, uint256 len) {
        require(user_data[CURRENT_USER].initialised, "NOT_INITIALISED");
        bytes32[] storage stack = user_data[CURRENT_USER].stack;
        assembly {
            s := stack.slot
            len := sload(s)
        }
        ds = keccak256(abi.encodePacked(s));
    }

    function _memSlot() private returns (bytes32 s, bytes32 ds, uint256 len) {
        require(user_data[CURRENT_USER].initialised, "NOT_INITIALISED");
        bytes32[] storage mem = user_data[CURRENT_USER].mem;
        assembly {
            s := mem.slot
            len := sload(s)
        }
        ds = keccak256(abi.encodePacked(s));
    }

    bytes1 constant OPCODE_POP = 0x01;
    function _pop() private returns (bytes32 v) {
        (bytes32 s, bytes32 ds, uint256 len) = _stackSlot();
        require(len > 0, "NOTHING TO POP");
        assembly {
            v := sload(add(ds, sub(len, 0x1)))
            sstore(s, sub(len, 0x1))
        }
    }

    bytes1 constant OPCODE_PUSH = 0x02;
    function _push(bytes32 v) private {
        (bytes32 s, bytes32 ds, uint256 len) = _stackSlot();
        assembly {
            sstore(add(ds, len), v)
            sstore(s, add(len, 0x1))
        }
    }

    function _pop2() private returns (bytes32 v1, bytes32 v2) {
        v1 = _pop();
        v2 = _pop();
    }

    function _pop3() private returns (bytes32 v1, bytes32 v2, bytes32 v3) {
        v1 = _pop();
        v2 = _pop();
        v2 = _pop();
    }

    function _peek() private returns (bytes32 v) {
        (bytes32 s, bytes32 ds, uint256 len) = _stackSlot();
        assembly {
            v := sload(add(ds, sub(len, 0x1)))
        }
    }

    bytes1 constant OPCODE_ADD = 0x03;
    function _add() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := add(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_SUB = 0x04;
    function _sub() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := sub(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_MUL = 0x05;
    function _mul() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := mul(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_DIV = 0x06;
    function _div() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := div(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_MOD = 0x07;
    function _mod() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := mod(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_EXP = 0x08;
    function _exp() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := exp(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_NOT = 0x09;
    function _not() private {
        bytes32 p = _pop(); bytes32 v;
        assembly { v := not(p) }
        _push(v);
    }

    bytes1 constant OPCODE_LT = 0x0a;
    function _lt() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := lt(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_LTE = 0x0b;
    function _lte() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := or(lt(p, q), eq(p, q)) }
        _push(v);
    }

    bytes1 constant OPCODE_GT = 0x0c;
    function _gt() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := gt(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_GTE = 0x0d;
    function _gte() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := or(gt(p, q), eq(p, q)) }
        _push(v);
    }

    bytes1 constant OPCODE_EQ = 0x0e;
    function _eq() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := eq(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_AND = 0x0f;
    function _and() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := and(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_OR = 0x10;
    function _or() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := or(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_XOR = 0x11;
    function _xor() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := xor(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_DUP = 0x12;
    function _dup() private {
        bytes32 p = _peek();
        _push(p);
    }

    bytes1 constant OPCODE_SHL = 0x13;
    function _shl() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := shl(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_SHR = 0x14;
    function _shr() private {
        (bytes32 p, bytes32 q) = _pop2(); bytes32 v;
        assembly { v := shr(p, q) }
        _push(v);
    }

    bytes1 constant OPCODE_ALLOC = 0x15;
    function _alloc() private {
        (bytes32 s, bytes32 ds, uint256 len) = _memSlot();
        bytes32 v = _pop();
        require(len + uint(v) <= MAX_MEM_LEN, "MAX_MEM_LEN");
        require(uint(ds) + len + uint(v) > uint(ds), "NO_INCREASE");
        assembly { sstore(s, add(len, v)) }
    }

    bytes1 constant OPCODE_DEALLOC = 0x16;
    function _dealloc() private {
        (bytes32 s,, uint256 len) = _memSlot();
        bytes32 v = _pop();
        require(uint(v) <= len, "LT_ZERO");
        assembly { sstore(s, sub(len, v)) }
    }

    bytes1 constant OPCODE_READ = 0x17;
    function _read() private {
        (, bytes32 ds, uint256 len) = _memSlot();
        bytes32 p = _pop(); bytes32 v;
        require(uint(p) < len, "UNAUTHORIZED");
        assembly { v := sload(add(ds, p)) }
        _push(v);
    }

    bytes1 constant OPCODE_WRITE = 0x18;
    function _write() private {
        (, bytes32 ds, uint256 len) = _memSlot();
        (bytes32 p, bytes32 q) = _pop2();
        require(uint(p) < len, "UNAUTHORIZED");
        assembly { sstore(add(ds, p), q) }
    }

    bytes1 constant OPCODE_COPY = 0x19;
    function _copy() private {
        (, bytes32 ds, uint256 len) = _memSlot();
        (bytes32 p, bytes32 q, bytes32 r) = _pop3();
        for (uint i = 0; i < uint(r); i++) {
            assembly { sstore(add(q, i), sload(add(p, i))) }
        }
    }
}
