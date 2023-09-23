const { assert } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
!developmentChains.includes(network.name)
    ? describe.skip
    : describe("ReferralSystem Unit Tests", function () {
          let referral, deployer, yongToken

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              await deployments.fixture(["token", "referralSystem"])
              referral = await ethers.getContract("ReferralSystem")
              yongToken = await ethers.getContract("YongToken")
          })

          describe("Constructor", () => {
              it("Initializes the Recommender Correctly.", async () => {
                  const token = await referral.getToken()
                  assert.equal(token, yongToken.target)
              })
          })

          //   describe("setRootHash", () => {
          //       it("Allows users to mint an NFT, and updates appropriately", async () => {
          //           const tokenURI = await basicNft.tokenURI(0)
          //           const tokenCounter = await basicNft.getTokenCounter()

          //           assert.equal(tokenCounter.toString(), "1")
          //           assert.equal(tokenURI, await basicNft.TOKEN_URI())
          //       })

          //       it("Show the correct balance and owner of an NFT", async () => {
          //           const deployerAddress = deployer.address
          //           const deployerBalance = await basicNft.balanceOf(deployerAddress)
          //           const owner = await basicNft.ownerOf("0")

          //           assert.equal(deployerBalance.toString(), "1")
          //           assert.equal(owner, deployerAddress)
          //       })
          //   })
      })
