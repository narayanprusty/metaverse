const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Identity", function () {
  it("Should return the owner of the identity contract", async function () {
    const Identity = await ethers.getContractFactory("Identity");
    const identity = await Identity.deploy("Identity", "ID");
    await identity.deployed();

    const accounts = await ethers.getSigners()
    const owner = accounts[0]
    const user = accounts[1]
    
    expect(await identity.owner()).to.equal(owner.address);

    const registerUserTx = await identity.registerUser("Narayan", 27, user.address);
    await registerUserTx.wait();

    await identity.connect(user).activateProfile({
      value: ethers.utils.parseEther("1.0")
    });

    //https://ethereum-waffle.readthedocs.io/en/latest/matchers.html#revert
    await expect(owner.sendTransaction({
      to: identity.address,
      value: ethers.utils.parseEther("1.0")
    })).to.be.reverted;
  });
});
