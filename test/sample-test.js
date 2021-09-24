const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

const FactoryAddress = "0xc7Dfd0e4C74466aB1161939707CEB921528c44F0";
const kacoNftAddress = "0xDD7698b02213eb713C183E03e82fF1A66AF6c17E";
const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";

//change to your own addresses and kacoId
const testAddress = "0xFB83a67784F110dC658B19515308A7a95c2bA33A";
const anotherAddress = "0x56eD0B8e8463c366E6c580fAC7BB6779700C3c22";
let kacoId = 10;
 
// Start test block
describe('Factory (proxy)', function () {
  beforeEach(async function () {
    NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    factoryInstance = NFT100Factory.attach(FactoryAddress);
  });
 
  // Test case
  it('KACO NFT', async function () {
    const kacoPairFactory = await ethers.getContractFactory("NFT100Pair721");
    const kacoPair = kacoPairFactory.attach(await factoryInstance.nftToToken(kacoNftAddress));

    console.log("lockInfos: ", await kacoPair.getLockInfos());

    const kacoNft = await ethers.getContractAt("ERC721PresetMinterPauserAutoId", kacoNftAddress, await ethers.getSigner(anotherAddress));
    console.log("owner of id: ", await kacoNft.ownerOf(kacoId));

    const provider = ethers.getDefaultProvider();
    let currentBlock = await provider.getBlockNumber();
    console.log("latest block: ", currentBlock)

    // console.log("methods: ",Object.keys(kacoNft));

    let data = ethers.utils.solidityPack(["address", "address", "uint24"], [anotherAddress, testAddress, currentBlock + 28800]);
    console.log("data: ", data);
    // let param = ethers.utils.defaultAbiCoder.encode(["address", "address", "uint256", "bytes"], [testAddress, kacoPair.address, kacoId, data]);
    // console.log("param: ", param);
    console.log("r: ", await kacoNft['safeTransferFrom(address,address,uint256,bytes)'](anotherAddress, kacoPair.address, kacoId, data));

    sleep(30000);
    console.log("lockInfos: ", await kacoPair.getLockInfos());
    expect();
  });
});

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
