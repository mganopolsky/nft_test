const { network, ethers } = require("hardhat");
const { tempCacheDir } = require("solidity-coverage/plugins/resources/nomiclabs.utils");

module.exports = async function (hre) {
    const { getNamedAccounts, deployments } = hre
    const { deployer } = await getNamedAccounts
    const { deploye, log } = deployments
    const chainId = network.config.chainId
    const FUND_AMMOUNT = "10000000000000000"

    let vrfCoordinatorV2Address, subscriptionId

    let tokenUris = [
        "ipfs://QmaVkBn2tKmjbhphU7eyztbvSQU5EXDdqRyXZtRhSGgJGo",
        "ipfs://QmYQC5aGZu2PTH8XzbJrbDnvhj3gVs7ya33H9mqUNvST3d",
        "ipfs://QmZYmH5iDbD6v3U2ixoVAjioSzvWJszDzYdbeCLquGSpVm",
    ]

    //if we are working on a testnet or a mainnet, 
    // those addresses will exist; 
    // on a local chain, they will not, so we have to mock them

    if (chainId == 33137) {
        //make a fake node - mock it
        //use the real nodes
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const tx = await vrfCoordinatorV2Mock.createSubscription()
        const txReceipt = await tx.wait(1)
        subscriptionId = txReceipt.events[0].args.subscriptionId
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMMOUNT)
    } else {
        //use the real nodes
        vrfCoordinatorV2Address = "0x6168499c0cFfCaCD319c818142124B7A15E857ab"
        //looking for the chainlink subscriptionId we created w/vrf/chain.link
        subscriptionId = "4182"
    }

    args = [
        vrfCoordinatorV2Address,
        "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        subscriptionId,
        "50000",
        // list of dogs
        tokenUris,
    ]

    const randomIpfsNft = await deploy("RandomIpfsNft", {
        from: deployer,
        args: args,
        log: true,
    })

    console.log("Deployed NFT with address" , randomIpfsNft.address);
}