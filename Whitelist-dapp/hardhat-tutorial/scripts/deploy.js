const { ethers } = require("hardhat");

async function main() {
    const whiteListContract = await ethers.getContractFactory("whiteList");

    const deployedWhitelistContract = await whiteListContract.deploy(10);

    await deployedWhitelistContract.deployed();

    console.log("Whitelist Contract Address", deployedWhitelistContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });