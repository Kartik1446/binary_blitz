// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/interfaces/IERC20.sol";

/// @notice Base state for CheeseLending pool. Reserve data, user supply balance, user debt (time-based interest), fixed prices, LTV. No user-facing functions.
abstract contract PoolState {
    struct ReserveData {
        address underlying;
        uint256 totalSupplied;
        uint256 totalDebt;
    }



    address[2] public assets;
    uint256 public numAssets;

    mapping(address => ReserveData) public reserves;
    mapping(address => uint256) public price; // fixed price in common unit: Gruyere=2, Emmental=1

    mapping(address => mapping(address => uint256)) public userSupplyBalance;
    mapping(address => mapping(address => uint256)) public debtPrincipal;
    mapping(address => mapping(address => uint256)) public debtLastUpdate;

    uint256 public constant RAY = 1e27;
    uint256 public constant SECONDS_PER_YEAR = 365 days;
    uint256 public constant LTV_BPS = 9900; // 99%
    uint256 public constant RATE_PER_SECOND = 1e15; // ~0.1% per second; 80% LTV position liquidatable in ~4 min

    uint256 public constant SUPPLY_CAP = 20*10**18;

    bool public flashInProgress;

    modifier invariants(address user) {
        require(!flashInProgress, "flash in progress");
        _;
        invariant(user);
    }

    function invariant(address user) internal virtual {}

    function _initReserve(address asset, uint256 assetPrice) internal {
        require(numAssets < 2, "max 2 assets");
        require(reserves[asset].underlying == address(0), "already init");
        reserves[asset] = ReserveData({
            underlying: asset,
            totalSupplied: 0,
            totalDebt:0
        });
        price[asset] = assetPrice;
        assets[numAssets] = asset;
        numAssets++;
    }

    function _getPrice(address asset) internal view returns (uint256) {
        return price[asset];
    }

    function getSupplyBalance(address user, address asset) external view returns (uint256) {
        return userSupplyBalance[user][asset];
    }

    function getDebtIncrease(address user, address asset) public view returns (uint256) {
        uint256 principal = debtPrincipal[user][asset];
        if (principal == 0) return 0;
        uint256 last = debtLastUpdate[user][asset];
        uint256 elapsed = block.timestamp - last;
        return (principal * RATE_PER_SECOND * elapsed) / 1e18;
    }

    /// @dev Current debt for user/asset including accrued interest
    function getDebt(address user, address asset) public view returns (uint256) {
        return debtPrincipal[user][asset] + getDebtIncrease(user, asset);
    }

    function _accrueDebt(address user, address asset) internal {
        uint increase = getDebtIncrease(user, asset);
        debtPrincipal[user][asset] += increase;
        reserves[asset].totalDebt += increase;

        debtLastUpdate[user][asset] = block.timestamp;
    }

    function _getCollateralValue(address user) internal view returns (uint256) {
        uint256 value = 0;
        for (uint256 i = 0; i < numAssets; i++) {
            address asset = assets[i];
            value += userSupplyBalance[user][asset] * price[asset];
        }
        return value;
    }

    function _getDebtValue(address user) internal view returns (uint256) {
        uint256 value = 0;
        for (uint256 i = 0; i < numAssets; i++) {
            address asset = assets[i];
            value += getDebt(user, asset) * price[asset];
        }
        return value;
    }

    function isHealthy(address user) public view returns(bool){
        uint debtValue = _getDebtValue(user);
        uint collateralValue = _getCollateralValue(user);
        return (collateralValue * LTV_BPS >= debtValue * 10000);
    }

    function getReserve(address asset) external view returns (ReserveData memory) {
        return reserves[asset];
    }
}
