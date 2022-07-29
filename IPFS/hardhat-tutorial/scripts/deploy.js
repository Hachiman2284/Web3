const { getContractFactory } = require("@nomiclabs/hardhat-ethers/types");
const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

async function main() {
    //IPFS CID for 'metadata' folder in Pinata for LW3Punks
    const metadataURL = "ipfs://Qmbygo38DWF1V8GttM1zy89KzyZTPU2FLUzQtiDvB7q6i5/";
    const lw3Punks = await ethers.getContractFactory("LW3Punks");
    const deployedLW3Punks = await lw3Punks.deploy(metadataURL);
    await deployedLW3Punks.deployed();
    console.log("Deployed contract address at: ", deployedLW3Punks.address);
    // print the address of the deployed contract
    console.log("Verify Contract Address:", deployedLW3Punks.address);

    console.log("Sleeping.....");
    // Wait for etherscan to notice that the contract has been deployed
    await sleep(50000);

    // Verify the contract after deploying
    await hre.run("verify:verify", {
        address: deployedLW3Punks.address,
        constructorArguments: [metadataURL],
    });
}

function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });