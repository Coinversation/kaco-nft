
async function main() {
    const factoryAddress = "0x7bce4113838bC9609A0A96149c61B0ae811421b2";
    const alpacaNftAddress = "0xe85d7b8f4c0c13806e158a1c9d7dcb33140cdc46";
    const kacoNftAddress = "0x46F36F9FE211600417D9d24c014a154052ABC960";
    const pancakeNftAddress = "0xdf7952b35f24acf7fc0487d01c8d5690a60dba07";
    const alpieNftAddress = "0x57A7c5d10c3F87f5617Ac1C60DA60082E44D539e";
    const moonpotAddress = "0x6798f4E7dA4Fc196678d75e289A9d4801C3C849E";

    // const NFT = await ethers.getContractFactory("ERC721PresetMinterPauserAutoId");
    // console.log("NFT Deploying...");
    // const nftInstance = await NFT.deploy("KACO NFT", "KAKA", "https://graphigo.prd.galaxy.eco/metadata/0x46F36F9FE211600417D9d24c014a154052ABC960/");
    // console.log("nft deployed to:", nftInstance.address);

    // const NFT1155 = await ethers.getContractFactory("ERC1155PresetMinterPauser");
    // console.log("NFT1155 Deploying...");
    // const nftInstance1155 = await NFT1155.deploy("https://graphigo.prd.galaxy.eco/metadata/0xe85d7B8f4c0C13806E158a1c9D7Dcb33140cdc46/{id}.json");
    // console.log("nft1155 deployed to:", nftInstance1155.address);

    // await sleep(60000);
    // await hre.run("verify:verify", {
    //   address: nftInstance1155.address,
    //   contract: "contracts/ERC1155PresetMinterPauser.sol:ERC1155PresetMinterPauser",
    //   constructorArguments: ["https://graphigo.prd.galaxy.eco/metadata/0xe85d7B8f4c0C13806E158a1c9D7Dcb33140cdc46/{id}.json"]
    // });

    const NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    const factory = NFT100Factory.attach(factoryAddress);

    console.log("creating nft100Pair...")
    await factory.nft100Pair("MOONPOT NFT", "KPOT", moonpotAddress, 1155);

    await sleep(40000)
    console.log("nftToToken...")
    const nftPair = await factory.nftToToken(moonpotAddress)
    console.log("nftPair deployed to:", nftPair);

    // await sleep(60000);
    // await hre.run("verify:verify", {
    //   address: alpaca,
    //   contract: "contracts/proxy/BeaconProxy.sol:BeaconProxy",
    //   constructorArguments: ["0xF0fb79bEa522AA1BA72Bc8B08523bC76876FCddf", "0x"]
    // });


    // await factory.nft100Pair("KACO NFT100", "K-KACO", kacoNftAddress, 721);

    // await sleep(30000)
    // const kaco = await factory.nftToToken(kacoNftAddress)
    // console.log("kaco deployed to:", kaco);
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
  