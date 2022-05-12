const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {

    const whitelistContract = WHITELIST_CONTRACT_ADDRESS;

    const metadatURL = METADATA_URL;

    const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs");

    const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
        metadatURL,
        whitelistContract
    );

    console.log("Crypto Devs contract address:", deployedCryptoDevsContract.address);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    });