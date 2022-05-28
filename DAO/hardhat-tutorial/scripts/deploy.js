const { ethers } = require("hardhat");
const { CRYPTODEVS_NFT_CONTRACT_ADDRESS } = require("../constants/index.js");

async function main() {

    //First deploying FakeNFTMarketplace
    const FakeNFTMarketplace = await ethers.getContractFactory("FakeNFTMarketplace");
    const fakeNFTMarketplace = await FakeNFTMarketplace.deploy();
    await fakeNFTMarketplace.deployed();
    console.log("Fake NFT Marketplace deployed at : ", fakeNFTMarketplace.address);

    //Second deploying the DAO contract
    const CryptoDevsDAO = await ethers.getContractFactory("CryptoDevsDAO");
    const cryptoDevsDAO = await CryptoDevsDAO.deploy(fakeNFTMarketplace.address, CRYPTODEVS_NFT_CONTRACT_ADDRESS);
    await cryptoDevsDAO.deployed();
    console.log("Crypto Devs DAO deployed at : ", cryptoDevsDAO.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })