/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("@nomiclabs/hardhat-etherscan")
require("dotenv").config()
require("solidity-coverage")
require("hardhat-deploy")
const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL 
const PRIVATE_KEY = process.env.PRIVATE_KEY 
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const MUMBAI_RPC_URL = process.env.MUMBAI_RPC_URL
module.exports = {
    defaultNetwork: "localhost",
    networks: {
        localhost: {
            chainId: 31337
        },

        mumbai: {
            url: MUMBAI_RPC_URL,
            accounts: [PRIVATE_KEY],
            chainId: 80001,
            blockConfirmations: 6,
        },
        mainnet: {
            url: process.env.MAINNET_RPC_URL,
            accounts: [PRIVATE_KEY],
            chainId: 137,
            blockConfirmations: 6,
        },
        hardhat: {
            chainId: 31337,
            forking: {
                url: MAINNET_RPC_URL
            }
        },
        
    },
    solidity: {
        compilers: [
            {
                version: "0.8.15"
            },
            {
                version: "0.8.8"
            }
        ]
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY
    },
    gasReporter: {
        enabled: true,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true
        // coinmarketcap: COINMARKETCAP_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0, // here this will by default take the first account as deployer
            1: 0 // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
        }
    }
}
