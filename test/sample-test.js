const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

const FactoryAddress = "0xc7Dfd0e4C74466aB1161939707CEB921528c44F0";
const kacoNftAddress = "0xDD7698b02213eb713C183E03e82fF1A66AF6c17E";
const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";

const testAddress = "0xFB83a67784F110dC658B19515308A7a95c2bA33A";
 
// Start test block
describe('Factory (proxy)', function () {
  beforeEach(async function () {
    NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    factoryInstance = NFT100Factory.attach(FactoryAddress);
  });
 
  // Test case
  it('KACO NFT', async function () {
    // expect((await factoryInstance.counter()).toString()).to.equal('2');

    const kacoPairFactory = await ethers.getContractFactory("NFT100Pair721");
    const kacoPair = kacoPairFactory.attach(await factoryInstance.nftToToken(kacoNftAddress));

    console.log("lockInfos: ", await kacoPair.getLockInfos());

    const kacoNFTFactory = await ethers.getContractFactory("ERC721PresetMinterPauserAutoId");
    const kacoNft = kacoNFTFactory.attach(kacoNftAddress);
    let kacoId = 11;
    console.log("owner of id 11: ", await kacoNft.ownerOf(kacoId));

    const provider = ethers.getDefaultProvider();
    let currentBlock = await provider.getBlockNumber();
    console.log("latest block: ", currentBlock)

    // console.log("methods: ",Object.keys(kacoNft));

    let data = ethers.utils.solidityPack(["address", "address", "uint24"], [testAddress, testAddress, currentBlock + 40]);
    console.log("data: ", data);
    let param = ethers.utils.defaultAbiCoder.encode(["address", "address", "uint256", "bytes"], [testAddress, kacoPair.address, kacoId, data]);
    console.log("param: ", param);
    console.log("r: ", await kacoNft['safeTransferFrom(address,address,uint256,bytes)'](testAddress, kacoPair.address, kacoId, data));

    console.log("lockInfos: ", await kacoPair.getLockInfos());
    expect();
  });
});
