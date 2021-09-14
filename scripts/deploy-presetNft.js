
async function main() {
    const NFT = await ethers.getContractFactory("ERC721PresetMinterPauserAutoId");
    console.log("NFT Deploying...");
    const nftInstance = await NFT.deploy("KACO NFT", "KAKA", "https://graphigo.prd.galaxy.eco/metadata/0x46F36F9FE211600417D9d24c014a154052ABC960/");
    console.log("nft deployed to:", nftInstance.address);
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  