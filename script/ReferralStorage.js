const MerkleTree = require("merkletreejs").default
const keccak256 = require("keccak256")
const mongoose = require("mongoose")

mongoose.connect("mongodb://localhost:27017/referral")
mongoose.connection.on("connected", () => console.log("连接成功"))
mongoose.connection.on("error", (err) => console.log(err))

const Schema = mongoose.Schema
const referralSchema = new Schema({
    recommenderAddress: String,
    referredAddress: String,
    reward: Number,
})

const ReferralModel = mongoose.model("referral", referralSchema)

let merkleTree, rootHash

addRecommendation("0x1", "0x2", 45)

//添加推荐关系
async function addRecommendation(recommenderAddress, referredAddress, reward) {
    try {
        const referrals = await ReferralModel.count({
            $or: [{ recommenderAddress: referredAddress }, { referredAddress: referredAddress }],
        })
        if (referrals > 0) {
            console.log("已经存在推荐关系")
            return
        }
        const referralData = new ReferralModel({
            recommenderAddress: recommenderAddress,
            referredAddress: referredAddress,
            reward: reward,
        })
        await referralData.save()
        await createMerkleTree()
        console.log("数据已成功保存到 MongoDB")
    } catch (error) {
        console.error("保存数据时发生错误：", error)
    } finally {
        mongoose.disconnect().then(() => {
            console.log("MongoDB连接已关闭")
        })
    }
}

//创建默克尔树
async function createMerkleTree() {
    try {
        // 查询全部数据并提取两个字段
        const referrals = await ReferralModel.find({}, "recommenderAddress referredAddress reward")
        if (referrals.length > 0) {
            const data = referrals.map((referral) => {
                return keccak256(`${referral.recommenderAddress}${referral.referredAddress}`)
            })
            // 构建默克尔树
            merkleTree = new MerkleTree(data, keccak256, { sortPairs: true })
            rootHash = merkleTree.getRoot().toString("hex")
        } else {
            console.log("没有数据")
        }
    } catch (err) {
        console.error("查询数据时发生错误：", err)
        throw err
    } finally {
        mongoose.disconnect().then(() => {
            console.log("MongoDB连接已关闭")
        })
    }
}

module.exports = {
    merkleTree,
    rootHash,
}
