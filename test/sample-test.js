const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

let NFT20Factory;
let factoryInstance;
 
// Start test block
describe('Factory (proxy)', function () {
  beforeEach(async function () {
    NFT20Factory = await ethers.getContractFactory("NFT20Factory");
    factoryInstance = await upgrades.deployProxy(NFT20Factory);
  });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await factoryInstance.counter()).toString()).to.equal('0');
  });
});
