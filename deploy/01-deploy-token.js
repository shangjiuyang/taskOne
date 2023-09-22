const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    arguments = []
    const ourToken = await deploy("YongToken", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    log(`ourToken deployed at ${ourToken.address}`)

    await verify(ourToken.address, arguments)
    // if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
    // }
}

module.exports.tags = ["token", "all"]
