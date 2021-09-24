const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

const FactoryAddress = "0xc7Dfd0e4C74466aB1161939707CEB921528c44F0";
const kacoNftAddress = "0xDD7698b02213eb713C183E03e82fF1A66AF6c17E";
const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";

const testAddress = "0xFB83a67784F110dC658B19515308A7a95c2bA33A";
const anotherAddress = "0x56eD0B8e8463c366E6c580fAC7BB6779700C3c22";
let kacoId = [10];
 
async function main() {
    NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    factoryInstance = NFT100Factory.attach(FactoryAddress);
    const kacoNftBeacon = await factoryInstance.nftToToken(kacoNftAddress);

    const kacoPair = await ethers.getContractAt("NFT100Pair721", kacoNftBeacon, await ethers.getSigner(testAddress));

    console.log("lockInfos: ", await kacoPair.getLockInfos());

    const kacoNFTFactory = await ethers.getContractFactory("ERC721PresetMinterPauserAutoId");
    const kacoNft = kacoNFTFactory.attach(kacoNftAddress);
    console.log("owner of id: ", await kacoNft.ownerOf(kacoId));

    await kacoPair.withdraw(kacoId, [1], testAddress);
    
    sleep(60000);
    console.log("owner of id: ", await kacoNft.ownerOf(kacoId));
    console.log("lockInfos: ", await kacoPair.getLockInfos());
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