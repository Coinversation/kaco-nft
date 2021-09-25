// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const ethers = hre.ethers;

const alpacaNftAddress = "0x5bbA2c99ff918f030D316ea4fD77EC166DDe0aFf";
const kacoNftAddress = "0xDD7698b02213eb713C183E03e82fF1A66AF6c17E";

const userAddress = "0x9925a5a968a7291E85DF74b57F346b92D2De902C";
const nft1155IdStart = 21;

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
//   await hre.run('compile');

  const kacoNft = await ethers.getContractAt("ERC721PresetMinterPauserAutoId", kacoNftAddress);
  for (let i = 0; i < 10; i++){
    await kacoNft.mint(userAddress);
  }
  console.log("mint 10 721:");

  const alpacaNft = await ethers.getContractAt("ERC1155PresetMinterPauser", alpacaNftAddress);
  let ids = [];
  let amounts = [];
  for (let i = nft1155IdStart; i < 10; i++){
    ids.push(i);
    amounts.push(i * 100);
  }
  await alpacaNft.mintBatch(userAddress, ids, amounts, "0x");
  console.log("mint 10 1155:");

  // const NFT100Pair721 = await ethers.getContractAt("NFT100Pair721", "0x3Ff2e308012460583ff1519bd504E940A46270C6");
  // await NFT100Pair721.multi721Deposit([1], "0x");
  // console.log("multi721Deposit");

  // We get the contract to deploy
  // alpacaNft.safeTransferFrom()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
