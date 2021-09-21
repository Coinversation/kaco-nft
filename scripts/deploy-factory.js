
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const NFT100Factory = await ethers.getContractFactory("NFT100Factory");
  console.log("Deploying Factory...");
  const factoryInstance = await upgrades.deployProxy(NFT100Factory, []);
  console.log("factory deployed to:", factoryInstance.address);

  await sleep(60000);

  await factoryInstance.changeLogic721("0x705bBBf10A68bB5EC00e747D76E98fA4eb9dE421");
  console.log("changeLogic721.");

  await factoryInstance.changeLogic1155("0xF0fb79bEa522AA1BA72Bc8B08523bC76876FCddf");
  console.log("changeLogic1155.");
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
