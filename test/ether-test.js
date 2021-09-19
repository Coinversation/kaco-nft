const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");


// Start test block
describe('Factory (proxy)', function () {
 
  // Test case
  it('encode test', async function () {
    // expect((await factoryInstance.counter()).toString()).to.equal('0');
    let abiCoder = ethers.utils.defaultAbiCoder;
    let result = abiCoder.encode(["bytes"],[])
  });
});
