
GNS文件夹原合约地址：https://polygonscan.com/address/0x0f9498b1206bf9ffde2a2321fdb56f573a052425#code

taskOne合约概述如下：

这个合约是一个推荐系统合约，旨在通过奖励机制来激励盟友（ally）和推荐者（referrer）引荐交易员（trader）使用特定交易对。以下是合约的详细说明：

### 合约概述

- **PRECISION**: 合约中使用的精度常量，通常设置为1e10，用于精确计算。

- **storageT**: 存储合约的地址，这个合约用于与其他智能合约进行交互。

- **可调整参数**:
  - `allyFeeP`: 盟友获得的推荐人费用的百分比。
  - `startReferrerFeeP`: 推荐人费用的百分比，当没有交易量被推荐时。
  - `openFeeP`: 用于推荐系统的开放费用的百分比。
  - `targetVolumeDai`: 达到最大推荐系统费用所需的总交易量，以 DAI 表示。

### 数据结构

#### `AllyDetails` 结构体
- `referrersReferred`: 被盟友推荐的推荐人列表。
- `volumeReferredDai`: 推荐人引荐的总交易量（以 DAI 表示）。
- `pendingRewardsToken`: 待分发的奖励（代币）。
- `totalRewardsToken`: 总奖励（代币）。
- `totalRewardsValueDai`: 总奖励价值（以 DAI 表示）。
- `active`: 是否激活状态。

#### `ReferrerDetails` 结构体
- `ally`: 推荐人所属的盟友地址。
- `tradersReferred`: 推荐人引荐的交易者列表。
- `volumeReferredDai`: 推荐人引荐的总交易量（以 DAI 表示）。
- `pendingRewardsToken`: 待分发的奖励（代币）。
- `totalRewardsToken`: 总奖励（代币）。
- `totalRewardsValueDai`: 总奖励价值（以 DAI 表示）。
- `active`: 是否激活状态。

### 映射

- `allyDetails`: 盟友地址到盟友详情的映射。
- `referrerDetails`: 推荐人地址到推荐人详情的映射。
- `referrerByTrader`: 交易者地址到推荐人地址的映射。
- `allies`: 盟友地址的映射，用于验证盟友身份。
- `referrers`: 推荐人地址的映射，用于验证推荐者身份。
- `traders`: 交易者地址的映射，用于验证交易者身份。

### 事件

合约定义了多个事件，用于记录合约操作和奖励分发。

### 构造函数

合约的构造函数用于初始化合约的可调整参数。

### 修饰符

- `onlyGov`: 管理者权限修饰符，用于限制只有管理员才能调用的函数。
- `onlyAlly`: 盟友权限修饰符，用于限制只有盟友才能调用的函数。
- `onlyReferrer`: 推荐者权限修饰符，用于限制只有推荐者才能调用的函数。
- `onlyTrading`: 交易员权限修饰符，用于限制只有交易员才能调用的函数。
- `onlyCallbacks`: 回调权限修饰符，用于限制只有特定回调地址才能调用的函数。

### 核心功能

合约包括以下核心功能：

- 盟友的管理，包括添加和移除盟友。
- 推荐人的管理，由盟友进行管理，包括添加和移除推荐人。
- 交易员的注册，包括将交易员与推荐人关联。
- 奖励分发，根据交易量和费用计算推荐人和盟友的奖励，并分发代币奖励。
- 奖励领取，

盟友和推荐人可以领取他们的奖励。
- 查看函数，用于查询各种信息，包括待领取的奖励和关联关系。

### 合约使用

1. 管理员（`onlyGov`）可以添加和移除盟友。
2. 盟友可以添加和移除推荐人，并将推荐人与交易员关联。
3. 交易员通过调用 `registerPotentialReferrer` 函数将自己与推荐人关联。
4. 奖励根据交易量和费用计算，并通过 `distributePotentialReward` 函数进行分发。
5. 盟友和推荐人可以通过 `claimAllyRewards` 和 `claimReferrerRewards` 函数领取奖励。
6. 可以使用查看函数查询待领取的奖励和关联关系。

### 注意事项

- 合约中使用了精确的数学计算，确保在进行数值计算时考虑精度。
- 合约中包含了权限修饰符，确保只有具有特定身份的用户可以执行相关操作。
- 奖励计算和分发逻辑需要根据具体需求进行定制，确保奖励按预期分配。
- 合约的调用需要注意 Gas 成本，特别是在进行批量操作时。
