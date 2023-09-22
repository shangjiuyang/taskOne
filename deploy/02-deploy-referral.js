const { network } = require("hardhat")
const { networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    if (chainId == 31337) {
        yongToken = await ethers.getContract("YongToken")
        yongTokenAddress = yongToken.address
    } else {
        yongTokenAddress = networkConfig[chainId].yongTokenAddress
    }

    arguments = [yongTokenAddress]
    const referralSystem = await deploy("ReferralSystem", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(referralSystem.address, arguments)
    }
}

module.exports.tags = ["referral", "all"]
