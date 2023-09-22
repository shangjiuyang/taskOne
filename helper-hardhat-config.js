const { ethers } = require("hardhat")

const networkConfig = {
    11155111: {},
    31337: { name: "localhost" },
    80001: { name: "mumbai", yongTokenAddress: "0x" },
}

module.exports = {
    networkConfig,
}
