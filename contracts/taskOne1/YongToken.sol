// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interface/TokenInterfaceV5.sol";

contract YongToken is TokenInterfaceV5 {
    string private name = "YongToken";
    string private symbol = "YTK";
    uint8 private decimals = 18;
    uint256 public totalSupply;
    address private owner;
    uint32 private initialSupply = 1000000;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    constructor() {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function burn(address account, uint256 amount) external {
        require(msg.sender == owner, "Only owner can burn tokens");
        require(balances[account] >= amount, "Insufficient balance");

        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint tokens");

        balances[account] += amount;
        totalSupply += amount;

        emit Transfer(address(0), account, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            sender != address(0) && recipient != address(0),
            "Invalid sender or recipient address"
        );
        require(
            balances[sender] >= amount && allowed[sender][msg.sender] >= amount,
            "Insufficient balance or allowance"
        );

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function hasRole(bytes32, address) external view returns (bool) {
        return false;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowed[owner][spender];
    }
}
