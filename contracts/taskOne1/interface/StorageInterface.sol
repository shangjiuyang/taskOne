// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
import "./TokenInterfaceV5.sol";

interface StorageInterface {
    function gov() external view returns (address);

    function callbacks() external view returns (address);

    function handleTokens(address, uint, bool) external;

    function token() external view returns (TokenInterfaceV5);
}
