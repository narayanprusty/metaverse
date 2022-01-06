const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Metaverse", async function () {
  let metaverse = null;
  
  it("Should test user profile creation in metaverse", async function () {
    const Metaverse = await ethers.getContractFactory("Metaverse");
    metaverse = await Metaverse.deploy("Metaverse", "META");
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

  it("Should test token data in metaverse", async function () {
    const tokenId = parseInt((await metaverse.tokenCounter()).toString()) - 1
    expect(tokenId).to.equal(0);

    const tokenData = "https://example.com/";
    const setTokenDataTx = await metaverse.setTokenData(tokenId, tokenData)
    await setTokenDataTx.wait();

    const fetchedTokenData = await metaverse.getTokenData(tokenId)

    expect(fetchedTokenData).to.equal(tokenData);
  })
});
