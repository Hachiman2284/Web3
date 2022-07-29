// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");
const { FEE, VRF_COORDINATOR, KEY_HASH, LINK_TOKEN } = require("../constants");

async function main() {
  const randomWinner = await ethers.getContractFactory("RandomWinnerGame");
  const deployrandomWinner = await randomWinner.deploy(VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE);
  await deployrandomWinner.deployed();

  console.log("Deployed Chainlink contract at: ", deployrandomWinner.address);
  console.log("Sleeping....");
  await sleep(50000);
  await hre.run("verify:verify", {
    address: deployrandomWinner.address,
    constructorArguments: [VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE],
  });
}


function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
