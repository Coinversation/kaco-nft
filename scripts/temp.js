const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

const FactoryAddress = "0x7bce4113838bC9609A0A96149c61B0ae811421b2";
const kacoNftAddress = "0x46F36F9FE211600417D9d24c014a154052ABC960";
const cakeNftAddress = "0xdf7952b35f24acf7fc0487d01c8d5690a60dba07";

const kacoNftPairAddress = "0x65aDc52BfD0E3d9Df80Be6E36F330E757862e2Bd";
const cakeNftPairAddress = "0xa70c4580F1e00C1d7A9D0280832c0D513a6D530F";
const alpacaNftPairAddress = "0xBd6D17123Ec731adFf1cE2F9f7Af1aBC26E5EBfd";

// const FactoryAddress = "0x7C3343Ddb7Fd5cD2C8A421C5C22C44c396AD50B2";
// const kacoNftAddress = "0xDD7698b02213eb713C183E03e82fF1A66AF6c17E";
// const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";

const testAddress = "0xFB83a67784F110dC658B19515308A7a95c2bA33A";
const anotherAddress = "0x56eD0B8e8463c366E6c580fAC7BB6779700C3c22";
let kacoId = [10];

async function main() {
  // const factoryInstance = await ethers.getContractAt("NFT100Factory", FactoryAddress);
  // const kacoNftBeacon = await factoryInstance.nftToToken(kacoNftAddress);
  const kacoPair = await ethers.getContractAt("NFT100Pair1155", kacoNftPairAddress, await ethers.getSigner(testAddress));

  console.log("supply: ", await kacoPair.totalSupply());
  console.log("lockInfos: ", await kacoPair.getLockInfos(0));
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
