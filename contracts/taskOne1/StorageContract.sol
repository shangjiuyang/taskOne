// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./interface/TokenInterfaceV5.sol";

import "./interface/StorageInterface.sol";

contract StorageContract is StorageInterface {
    address public override gov;
    address public override callbacks;
    TokenInterfaceV5 public override token;

    constructor(address _gov, address _callbacks, address _token) {
        gov = _gov;
        callbacks = _callbacks;
        token = TokenInterfaceV5(_token);
    }

    modifier onlyCallbacks() {
        require(msg.sender == callbacks, "CALLBACKS_ONLY");
        _;
    }

    //管理者
    modifier onlyGov() {
        require(msg.sender == gov, "GOV_ONLY");
        _;
    }

    //处理代币
    function handleTokens(
        address recipient,
        uint256 amount,
        bool isMint
    ) external override onlyCallbacks {
        if (isMint) {
            //具体处理暂未实现
        }
    }

    // 更改回调地址的函数，只有合约部署者（gov）可以调用
    function setCallbacks(address _callbacks) external onlyGov {
        callbacks = _callbacks;
    }
}
