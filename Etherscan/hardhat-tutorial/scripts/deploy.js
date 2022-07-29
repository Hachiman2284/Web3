const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

async function main() {

    const verContract = await ethers.getContractFactory("Verify");

    const deployedVerContract = await verContract.deploy();

    await deployedVerContract.deployed();

    console.log("Verify Contract Address: ", deployedVerContract.address);

    console.log("Sleeping....");

    await sleep(50000);

    await hre.run("verify:verify", {
        address: deployedVerContract.address,
        constructorArguments: [],
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
    })