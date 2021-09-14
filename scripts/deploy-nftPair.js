
async function main() {
  const NFT20Pair = await ethers.getContractFactory("NFT20Pair");
  console.log("Pair Deploying...");
  const pairInstance = await NFT20Pair.deploy();
  console.log("Pair deployed to:", pairInstance.address);

  const UpgradeableBeacon = await ethers.getContractFactory("UpgradeableBeacon");
  console.log("beacon Deploying...");
  const beacon = await UpgradeableBeacon.deploy(String(pairInstance.address));
  console.log("beacon deployed to:", beacon.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
