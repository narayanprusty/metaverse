const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Metaverse", function () {
  it("Should test user profile creation in metaverse", async function () {
    const Metaverse = await ethers.getContractFactory("Metaverse");
    const metaverse = await Metaverse.deploy("Metaverse", "META");
    await metaverse.deployed();

    const accounts = await ethers.getSigners()
    const owner = accounts[0]
    const user = accounts[1]
    
    expect(await metaverse.owner()).to.equal(owner.address);

    const registerUserTx = await metaverse.registerUser("Narayan", 27, user.address);
    await registerUserTx.wait();

    await metaverse.connect(user).activateProfile({
      value: ethers.utils.parseEther("1.0")
    });

    //https://ethereum-waffle.readthedocs.io/en/latest/matchers.html#revert
    await expect(owner.sendTransaction({
      to: metaverse.address,
      value: ethers.utils.parseEther("1.0")
    })).to.be.reverted;
  });
});
