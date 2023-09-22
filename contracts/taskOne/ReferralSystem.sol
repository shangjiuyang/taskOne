// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/TokenInterfaceV5.sol";

contract ReferralSystem is Ownable {
    bytes32 public rootHash;
    TokenInterfaceV5 public immutable token;

    struct Referrals {
        address recommenderAddress;
        address referredAddress;
        uint reward;
    }

    mapping(address => bool) private recommendations;

    modifier isRecommender(address recommenderAddress) {
        require(
            recommenderAddress != msg.sender && !recommendations[msg.sender],
            "Only Recommender"
        );
        _;
    }

    constructor(TokenInterfaceV5 _token) {
        require(address(_token) != address(0), "WRONG_PARAMS");
        token = _token;
    }

    function setRootHash(bytes32 _rootHash) external onlyOwner {
        rootHash = _rootHash;
    }

    // 验证推荐关系哈希值并发放奖励
    function verifyRecommendation(
        Referrals memory referrals,
        bytes32[] memory _merklePath
    ) public payable isRecommender(referrals.recommenderAddress) {
        bytes memory concatenated = abi.encodePacked(
            referrals.recommenderAddress,
            referrals.referredAddress
        );
        bytes32 hashValue = keccak256(concatenated);
        require(MerkleProof.verify(_merklePath, rootHash, hashValue), "Invalid recommendation");

        //发放奖励
        uint256 reward = calculateReward();

        recommendations[msg.sender] = true;
        token.transfer(msg.sender, reward);
    }

    function calculateReward() private pure returns (uint256) {
        return 1 wei;
    }
}
