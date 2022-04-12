const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

async function main() {
    const NFT100Pair721 = await ethers.getContractFactory("NFT100Pair721");
    console.log("Pair721 Deploying...");
    const pair721Instance = await NFT100Pair721.deploy();
    console.log("Pair721 deployed to:", pair721Instance.address);

    await sleep(30000);
    await hre.run("verify:verify", {
        address: pair721Instance.address,
        contract: "contracts/NFT100Pair721.sol:NFT100Pair721"
    });


    const NFT100Pair1155 = await ethers.getContractFactory("NFT100Pair1155");
    console.log("Pair1155 Deploying...");
    const pair1155Instance = await NFT100Pair1155.deploy();
    console.log("Pair1155 deployed to:", pair1155Instance.address);

    await sleep(30000);
    await hre.run("verify:verify", {
        address: pair1155Instance.address,
        contract: "contracts/NFT100Pair1155.sol:NFT100Pair1155"
    });
}


function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
