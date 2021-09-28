const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

const FactoryAddress = "0x7bce4113838bC9609A0A96149c61B0ae811421b2";
const kacoNftAddress = "0x46F36F9FE211600417D9d24c014a154052ABC960";
// const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";

const testAddress = "0xFB83a67784F110dC658B19515308A7a95c2bA33A";
const anotherAddress = "0x56eD0B8e8463c366E6c580fAC7BB6779700C3c22";
let kacoId = [2095];
 
async function main() {
    NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    factoryInstance = NFT100Factory.attach(FactoryAddress);
    const kacoNftBeacon = await factoryInstance.nftToToken(kacoNftAddress);

    const kacoPair = await ethers.getContractAt("NFT100Pair1155", kacoNftBeacon, await ethers.getSigner(testAddress));

    console.log("lockInfos: ", await kacoPair.getLockInfos());

    // const kacoNFTFactory = await ethers.getContractFactory("ERC721PresetMinterPauserAutoId");
    // const kacoNft = kacoNFTFactory.attach(kacoNftAddress);
    // console.log("owner of id: ", await kacoNft.ownerOf(kacoId));

    await kacoPair.withdraw(kacoId, [1], testAddress);
    
    sleep(30000);
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
