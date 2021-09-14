# Kaco NFT

This project is based on Hardhat, Openzeppelin and inspired by NFT20.


# Hardhat Project Tasks

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run --network testnet scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network testnet --contract "contracts/NFT20Factory.sol:NFT20Factory" 0xa2835FEDCBbcE70A3e54BEe3d415946d1eeFb1C3
```


npx hardhat verify --network testnet --contract "contracts/proxy/UpgradeableBeacon.sol:UpgradeableBeacon" 0xAf9D3cD29F77eE00CD4A0a50CC8c43bC6225e173 0x428CF639D2934Ac540d3302b12e9114990c7bde3


npx hardhat verify --network testnet --contract "contracts/ERC721PresetMinterPauserAutoId.sol:ERC721PresetMinterPauserAutoId" 0x15F96408c7Ef26CE22d53c784cA9E9C970c59092 "KACO NFT" "KAKA" "https://graphigo.prd.galaxy.eco/metadata/0x46F36F9FE211600417D9d24c014a154052ABC960/"


npx hardhat verify --network testnet --contract "contracts/proxy/BeaconProxy.sol:BeaconProxy" 0x232d2464211903B045a09414f47bE4C826a25cd0 --constructor-args scripts/BeaconProxyParams.js