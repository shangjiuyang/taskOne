const { ethers } = require("hardhat")

const networkConfig = {
    11155111: {},
    31337: { name: "localhost", yongTokenAddress: "0x5FbDB2315678afecb367f032d93F642f64180aa3" },
    80001: { name: "mumbai", yongTokenAddress: "0x27B48C36F2eDE77971DE04A4095289C11E94a882" },
}
const developmentChains = ["hardhat", "localhost"]
module.exports = {
    networkConfig,
    developmentChains,
}
