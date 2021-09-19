const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

let NFT100Factory;
let factoryInstance;
 
// Start test block
describe('Factory (proxy)', function () {
  beforeEach(async function () {
    NFT100Factory = await ethers.getContractFactory("NFT100Factory");
    factoryInstance = await upgrades.deployProxy(NFT100Factory);
  });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await factoryInstance.counter()).toString()).to.equal('0');
  });
});
