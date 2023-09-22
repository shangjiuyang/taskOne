const { ethers, network } = require("hardhat")
const { merkleTree, rootHash } = require("./ReferralStorage.js")

//更新默克尔根
async function setRootHash() {
    const referralContract = await ethers.getContract("ReferralSystem")
    const solidityHash = "0x" + rootHash
    await referralContract.setRootHash(solidityHash)
}

//验证推荐关系并发放奖励
async function verifyRecommendation(recommenderAddress, referredAddress, reward) {
    const referrals = {
        recommenderAddress: recommenderAddress,
        referredAddress: referredAddress,
        reward: reward,
    }
    const referralContract = await ethers.getContract("ReferralSystem")

    const proof = merkleTree.getProof(recommenderAddress + referredAddress)
    const solidityProof = proof.map((x) => "0x" + x.data.toString("hex"))
    await referralContract.verifyRecommendation(referrals, solidityProof)
}
