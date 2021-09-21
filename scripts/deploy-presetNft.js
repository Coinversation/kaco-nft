
async function main() {
    const NFT = await ethers.getContractFactory("ERC721PresetMinterPauserAutoId");
    console.log("NFT Deploying...");
    const nftInstance = await NFT.deploy("KACO NFT", "KAKA", "https://graphigo.prd.galaxy.eco/metadata/0x46F36F9FE211600417D9d24c014a154052ABC960/");
    console.log("nft deployed to:", nftInstance.address);

    const NFT1155 = await ethers.getContractFactory("ERC1155PresetMinterPauser");
    console.log("NFT1155 Deploying...");
    const nftInstance1155 = await NFT1155.deploy("https://graphigo.prd.galaxy.eco/metadata/0xe85d7B8f4c0C13806E158a1c9D7Dcb33140cdc46/{id}.json");
    console.log("nft1155 deployed to:", nftInstance1155.address);

    await sleep(60000);
    await hre.run("verify:verify", {
      address: nftInstance1155.address,
      contract: "contracts/ERC1155PresetMinterPauser.sol:ERC1155PresetMinterPauser",
      constructorArguments: ["https://graphigo.prd.galaxy.eco/metadata/0xe85d7B8f4c0C13806E158a1c9D7Dcb33140cdc46/{id}.json"]
    });

    const NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    const factory = NFT100Factory.attach("0xc7Dfd0e4C74466aB1161939707CEB921528c44F0");

    console.log("creating nft100Pair...")
    await factory.nft100Pair("KACOxALPACA NFT100", "K-ALPACA", nftInstance1155.address, 1155);

    await sleep(30000)
    console.log("nftToToken...")
    const alpaca = await factory.nftToToken(nftInstance1155.address)
    console.log("alpaca deployed to:", alpaca);

    // await sleep(60000);
    await hre.run("verify:verify", {
      address: alpaca,
      contract: "contracts/proxy/BeaconProxy.sol:BeaconProxy",
      constructorArguments: ["0xF0fb79bEa522AA1BA72Bc8B08523bC76876FCddf", "0x"]
    });


    await factory.nft100Pair("KACOxKACO NFT100", "K-KACO", nftInstance.address, 721);

    await sleep(30000)
    const kaco = await factory.nftToToken(nftInstance.address)
    console.log("kaco deployed to:", kaco);
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
  