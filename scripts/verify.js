// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  console.log("verifying...")
  await hre.run("verify:verify", {
      address: "0x65aDc52BfD0E3d9Df80Be6E36F330E757862e2Bd",
      contract: "contracts/proxy/BeaconProxy.sol:BeaconProxy",
      constructorArguments: ["0xcd6b723AFF8F57D01FE2FFD17B72f27c2A8398D7", "0x"]
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
