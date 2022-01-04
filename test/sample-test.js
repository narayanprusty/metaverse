const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Identity", function () {
  it("Should return the owner of the identity contract", async function () {
    const Identity = await ethers.getContractFactory("Identity");
    const identity = await Identity.deploy();
    await identity.deployed();

    
    expect(await identity.owner()).to.equal((await ethers.getSigners())[0].address);
    // expect(await identity.owner()).to.equal();

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
