
const hre = require("hardhat");

async function main() {
  const NFT100Factory = await ethers.getContractFactory("NFT100Factory");
  console.log("Deploying Factory...");
  const factoryInstance = await upgrades.deployProxy(NFT100Factory, []);
  console.log("factory deployed to:", factoryInstance.address);


  const NFT100Pair721 = await ethers.getContractFactory("NFT100Pair721");
  console.log("Pair721 Deploying...");
  const pair721Instance = await NFT100Pair721.deploy();
  console.log("Pair721 deployed to:", pair721Instance.address);

  await sleep(60000);

  // const factoryInstance = await ethers.getContractAt("NFT100Factory", "0x7bce4113838bC9609A0A96149c61B0ae811421b2");
  // const pair721InstanceAddress = "0x9C2b0C4252e243ADe39Ce0419C2dD8E03C6d35de";
  // const pair1155InstanceAddress = "0x51fb29fbC280431ae27C80b25DF13533387F2290";
  // console.log("start...")

  await hre.run("verify:verify", {
    address: pair721InstanceAddress,
    contract: "contracts/NFT100Pair721.sol:NFT100Pair721"
  });
  const UpgradeableBeacon = await ethers.getContractFactory("UpgradeableBeacon");
  console.log("beacon721 Deploying...");
  const beacon721 = await UpgradeableBeacon.deploy(pair721InstanceAddress);
  console.log("beacon721 deployed to:", beacon721.address);

  await factoryInstance.changeLogic721(beacon721.address);
  console.log("changeLogic721.");


  const NFT100Pair1155 = await ethers.getContractFactory("NFT100Pair1155");
  console.log("Pair1155 Deploying...");
  const pair1155Instance = await NFT100Pair1155.deploy();
  console.log("Pair1155 deployed to:", pair1155Instance.address);

  await sleep(60000);
  await hre.run("verify:verify", {
    address: pair1155Instance.address,
    contract: "contracts/NFT100Pair1155.sol:NFT100Pair1155"
  });
  const UpgradeableBeacon1155 = await ethers.getContractFactory("UpgradeableBeacon");
  console.log("beacon1155 Deploying...");
  const beacon1155 = await UpgradeableBeacon1155.deploy(pair1155InstanceAddress);
  console.log("beacon1155 deployed to:", beacon1155.address);

  await factoryInstance.changeLogic1155(beacon1155.address);
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
