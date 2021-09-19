// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
//   await hre.run('compile');

  // We get the contract to deploy
  const NFT100Pair721 = await ethers.getContractAt("NFT100Pair721", "0x232d2464211903B045a09414f47bE4C826a25cd0");
  await NFT100Pair721.multi721Deposit([2], "0xFB83a67784F110dC658B19515308A7a95c2bA33A", "0xFB83a67784F110dC658B19515308A7a95c2bA33A");
  const result = await NFT100Pair721.totalSupply();

  console.log("result:", result);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
