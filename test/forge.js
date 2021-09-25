const { expect } = require("chai");
const { ethers, upgrades, BlockTag } = require("hardhat");

let NFT100Factory;
let factoryInstance;

const FactoryAddress = "0x7bce4113838bC9609A0A96149c61B0ae811421b2";
const kacoNftAddress = "0x46F36F9FE211600417D9d24c014a154052ABC960";
// const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";

//change to your own addresses and kacoId
const testAddress = "0xFB83a67784F110dC658B19515308A7a95c2bA33A";
const anotherAddress = "0x56eD0B8e8463c366E6c580fAC7BB6779700C3c22";
const kacoId = 2;
const amount = 1;
 
// Start test block
describe('Factory (proxy)', function () {
  beforeEach(async function () {
    NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    factoryInstance = NFT100Factory.attach(FactoryAddress);
  });
 
  // Test case
  it('KACO NFT', async function () {
    const kacoPairFactory = await ethers.getContractFactory("NFT100Pair1155");
    const kacoPair = kacoPairFactory.attach(await factoryInstance.nftToToken(kacoNftAddress));

    console.log("lockInfos: ", await kacoPair.getLockInfos());

    const kacoNft = await ethers.getContractAt("@openzeppelin/contracts/token/ERC1155/IERC1155.sol:IERC1155", kacoNftAddress, await ethers.getSigner(testAddress));
    // console.log("owner of id: ", await kacoNft.ownerOf(kacoId));

    // const provider = ethers.getDefaultProvider();
    // let unclockBlock = await provider.getBlockNumber();
    const unclockBlock = 11197213 + 28800;
    console.log("latest block: ", unclockBlock)

    // console.log("methods: ",Object.keys(kacoNft));

    let data = ethers.utils.solidityPack(["address", "address", "uint24"], [testAddress, testAddress, unclockBlock]);
    console.log("data: ", data);
    // let param = ethers.utils.defaultAbiCoder.encode(["address", "address", "uint256", "bytes"], [testAddress, kacoPair.address, kacoId, data]);
    // console.log("param: ", param);
    console.log("r: ", await kacoNft['safeTransferFrom(address,address,uint256,uint256,bytes)'](testAddress, kacoPair.address, kacoId, amount, data));

    sleep(30000);
    console.log("lockInfos: ", await kacoPair.getLockInfos());
    expect();
  });
});

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
