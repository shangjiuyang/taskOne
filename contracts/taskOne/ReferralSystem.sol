// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interface/StorageInterface.sol";

contract ReferralSystem {
    uint constant PRECISION = 1e10;
    StorageInterface public immutable storageT;

    // 可调整的参数
    uint public allyFeeP; // 盟友（ally）获得的推荐人费用的百分比
    uint public startReferrerFeeP; // 推荐人费用的百分比，当没有交易量被推荐时
    uint public openFeeP; // 用于推荐系统的开放费用的百分比
    uint public targetVolumeDai; // 达到最大推荐系统费用所需的总交易量（以 DAI 表示）

    struct AllyDetails {
        address[] referrersReferred; // 被盟友推荐的推荐人列表
        uint volumeReferredDai; // 推荐人引荐的总交易量（以 DAI 表示）
        uint pendingRewardsToken; // 待分发的奖励（代币）
        uint totalRewardsToken; // 总奖励（代币）
        uint totalRewardsValueDai; // 总奖励价值（以 DAI 表示）
        bool active; // 是否激活状态
    }

    struct ReferrerDetails {
        address ally; // 推荐人所属的盟友地址
        address[] tradersReferred; // 推荐人引荐的交易者列表
        uint volumeReferredDai; // 推荐人引荐的总交易量（以 DAI 表示）
        uint pendingRewardsToken; // 待分发的奖励（代币）
        uint totalRewardsToken; // 总奖励（代币）
        uint totalRewardsValueDai; // 总奖励价值（以 DAI 表示）
        bool active; // 是否激活状态
    }

    mapping(address => AllyDetails) public allyDetails; // 盟友详情
    mapping(address => ReferrerDetails) public referrerDetails; // 推荐人详情
    mapping(address => address) public referrerByTrader; // 交易者对应的推荐人

    mapping(address => bool) public allies;
    mapping(address => bool) public referrers;
    mapping(address => bool) public traders;

    // 事件
    event UpdatedAllyFeeP(uint value);
    event UpdatedStartReferrerFeeP(uint value);
    event UpdatedOpenFeeP(uint value);
    event UpdatedTargetVolumeDai(uint value);
    event AllyWhitelisted(address indexed ally);
    event AllyUnwhitelisted(address indexed ally);
    event ReferrerWhitelisted(address indexed referrer, address indexed ally);
    event ReferrerUnwhitelisted(address indexed referrer);
    event ReferrerRegistered(address indexed trader, address indexed referrer);
    event AllyRewardDistributed(
        address indexed ally,
        address indexed trader,
        uint volumeDai,
        uint amountToken,
        uint amountValueDai
    );
    event ReferrerRewardDistributed(
        address indexed referrer,
        address indexed trader,
        uint volumeDai,
        uint amountToken,
        uint amountValueDai
    );
    event AllyRewardsClaimed(address indexed ally, uint amountToken);
    event ReferrerRewardsClaimed(address indexed referrer, uint amountToken);

    constructor(
        StorageInterface _storageT,
        uint _allyFeeP,
        uint _startReferrerFeeP,
        uint _openFeeP,
        uint _targetVolumeDai
    ) {
        require(
            address(_storageT) != address(0) &&
                _allyFeeP <= 50 &&
                _startReferrerFeeP <= 100 &&
                _openFeeP <= 50 &&
                _targetVolumeDai > 0,
            "WRONG_PARAMS"
        );

        storageT = _storageT;

        allyFeeP = _allyFeeP;
        startReferrerFeeP = _startReferrerFeeP;
        openFeeP = _openFeeP;
        targetVolumeDai = _targetVolumeDai;
    }

    //管理者
    modifier onlyGov() {
        require(msg.sender == storageT.gov(), "GOV_ONLY");
        _;
    }

    //验证盟友
    modifier onlyAlly() {
        require(allies[msg.sender], "Only allies can call this function");
        _;
    }

    //验证推荐者
    modifier onlyReferrer() {
        require(referrers[msg.sender], "Only referrers can call this function");
        _;
    }

    //交易员
    modifier onlyTrading() {
        require(traders[msg.sender], "TRADING_ONLY");
        _;
    }

    modifier onlyCallbacks() {
        require(msg.sender == storageT.callbacks(), "CALLBACKS_ONLY");
        _;
    }

    //管理员添加盟友
    function whitelistAlly(address ally) external onlyGov {
        require(ally != address(0), "ADDRESS_0");

        AllyDetails storage a = allyDetails[ally];
        require(!a.active, "ALLY_ALREADY_ACTIVE");

        a.active = true;
        allies[ally] = true;

        emit AllyWhitelisted(ally);
    }

    function unwhitelistAlly(address ally) external onlyGov {
        AllyDetails storage a = allyDetails[ally];
        require(a.active, "ALREADY_UNACTIVE");

        // 检查是否有与之关联的推荐人
        require(a.referrersReferred.length == 0, "HAS_REFERRERS");

        a.active = false;
        allies[ally] = false;
        emit AllyUnwhitelisted(ally);
    }

    // 推荐人由盟友管理
    function whitelistReferrer(address referrer) external onlyAlly {
        require(referrer != address(0), "ADDRESS_0");

        ReferrerDetails storage r = referrerDetails[referrer];
        require(!r.active, "REFERRER_ALREADY_ACTIVE");

        r.active = true;
        referrers[referrer] = true;

        AllyDetails storage a = allyDetails[msg.sender];
        require(a.active, "ALLY_NOT_ACTIVE");

        r.ally = msg.sender;
        a.referrersReferred.push(referrer);

        emit ReferrerWhitelisted(referrer, msg.sender);
    }

    function unwhitelistReferrer(address referrer) external onlyAlly {
        ReferrerDetails storage r = referrerDetails[referrer];
        require(r.active, "ALREADY_UNACTIVE");

        // 检查是否有与之关联的交易员
        require(r.tradersReferred.length == 0, "HAS_TRADES");

        r.active = false;
        referrers[referrer] = false;

        emit ReferrerUnwhitelisted(referrer);
    }

    //交易员绑定推荐者
    function registerPotentialReferrer(address trader, address referrer) external onlyTrading {
        ReferrerDetails storage r = referrerDetails[referrer];

        if (referrerByTrader[trader] != address(0) || referrer == address(0) || !r.active) {
            return;
        }

        referrerByTrader[trader] = referrer;
        r.tradersReferred.push(trader);
        emit ReferrerRegistered(trader, referrer);
    }

    //奖励分发
    function distributePotentialReward(
        address trader, //- `trader`：交易员的地址，这是进行交易的用户。
        uint volumeDai, //   - `volumeDai`：交易的数量（以 DAI 衡量）  价值。
        uint pairOpenFeeP, //   - `pairOpenFeeP`：交易对的开放手续费百分比。
        uint tokenPriceDai //   - `tokenPriceDai`：代币的价格（以 DAI 衡量）。
    ) external onlyCallbacks returns (uint) {
        address referrer = referrerByTrader[trader];
        ReferrerDetails storage r = referrerDetails[referrer];

        if (!r.active) {
            return 0;
        }

        uint referrerRewardValueDai = (volumeDai *
            getReferrerFeeP(pairOpenFeeP, r.volumeReferredDai)) /
            PRECISION /
            100;

        uint referrerRewardToken = (referrerRewardValueDai * PRECISION) / tokenPriceDai;

        storageT.handleTokens(address(this), referrerRewardToken, true);

        AllyDetails storage a = allyDetails[r.ally];

        uint allyRewardValueDai;
        uint allyRewardToken;

        if (a.active) {
            allyRewardValueDai = (referrerRewardValueDai * allyFeeP) / 100;
            allyRewardToken = (referrerRewardToken * allyFeeP) / 100;

            a.volumeReferredDai += volumeDai;
            a.pendingRewardsToken += allyRewardToken;
            a.totalRewardsToken += allyRewardToken;
            a.totalRewardsValueDai += allyRewardValueDai;

            referrerRewardValueDai -= allyRewardValueDai;
            referrerRewardToken -= allyRewardToken;

            emit AllyRewardDistributed(
                r.ally,
                trader,
                volumeDai,
                allyRewardToken,
                allyRewardValueDai
            );
        }

        r.volumeReferredDai += volumeDai;
        r.pendingRewardsToken += referrerRewardToken;
        r.totalRewardsToken += referrerRewardToken;
        r.totalRewardsValueDai += referrerRewardValueDai;

        emit ReferrerRewardDistributed(
            referrer,
            trader,
            volumeDai,
            referrerRewardToken,
            referrerRewardValueDai
        );

        return referrerRewardValueDai + allyRewardValueDai;
    }

    // 查看函数
    function getReferrerFeeP(uint pairOpenFeeP, uint volumeReferredDai) public view returns (uint) {
        //最大的推荐者费用百分比，它是 pairOpenFeeP 的两倍再乘以 openFeeP 的结果，然后再除以 100。
        uint maxReferrerFeeP = (pairOpenFeeP * 2 * openFeeP) / 100;
        //最小的推荐者费用百分比，它是 maxReferrerFeeP 乘以 startReferrerFeeP 的结果再除以 100。
        uint minFeeP = (maxReferrerFeeP * startReferrerFeeP) / 100;

        uint feeP = minFeeP +
            ((maxReferrerFeeP - minFeeP) * volumeReferredDai) /
            1e18 /
            targetVolumeDai;

        return feeP > maxReferrerFeeP ? maxReferrerFeeP : feeP;
    }

    //查看奖励费用
    function getPercentOfOpenFeeP(address trader) external view returns (uint) {
        return
            getPercentOfOpenFeeP_calc(referrerDetails[referrerByTrader[trader]].volumeReferredDai);
    }

    function getPercentOfOpenFeeP_calc(uint volumeReferredDai) public view returns (uint resultP) {
        resultP =
            (openFeeP *
                (startReferrerFeeP *
                    PRECISION +
                    (volumeReferredDai * PRECISION * (100 - startReferrerFeeP)) /
                    1e18 /
                    targetVolumeDai)) /
            100;

        resultP = resultP > openFeeP * PRECISION ? openFeeP * PRECISION : resultP;
    }

    // 盟友奖励领取
    function claimAllyRewards() external onlyAlly {
        AllyDetails storage a = allyDetails[msg.sender];
        uint rewardsToken = a.pendingRewardsToken;

        require(rewardsToken > 0, "NO_PENDING_REWARDS");

        a.pendingRewardsToken = 0;
        storageT.token().transfer(msg.sender, rewardsToken);

        emit AllyRewardsClaimed(msg.sender, rewardsToken);
    }

    //推荐者奖励领取
    function claimReferrerRewards() external onlyReferrer {
        ReferrerDetails storage r = referrerDetails[msg.sender];
        uint rewardsToken = r.pendingRewardsToken;

        require(rewardsToken > 0, "NO_PENDING_REWARDS");

        r.pendingRewardsToken = 0;
        storageT.token().transfer(msg.sender, rewardsToken);

        emit ReferrerRewardsClaimed(msg.sender, rewardsToken);
    }

    // 查看待领取的盟友奖励
    function viewAllyPendingRewards() external view onlyAlly returns (uint) {
        return allyDetails[msg.sender].pendingRewardsToken;
    }

    // 查看待领取的推荐者奖励
    function viewReferrerPendingRewards() external view onlyReferrer returns (uint) {
        return referrerDetails[msg.sender].pendingRewardsToken;
    }

    //查看推荐者对应的盟友
    function getReferrerAlly(address referred) external view returns (address) {
        address ally = referrerDetails[referred].ally;
        return allyDetails[ally].active ? ally : address(0);
    }

    //查看交易员对应的推荐者
    function getTraderReferrer(address trader) external view returns (address) {
        address referrer = referrerByTrader[trader];
        return referrerDetails[referrer].active ? referrer : address(0);
    }

    //查看盟友对应的推荐者
    function getReferrersReferred(address ally) external view returns (address[] memory) {
        return allyDetails[ally].referrersReferred;
    }

    //查看推荐者对应的交易员
    function getTradersReferred(address referred) external view returns (address[] memory) {
        return referrerDetails[referred].tradersReferred;
    }
}
