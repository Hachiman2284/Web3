// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    //Price of one Crypto Dev Token
    uint256 public constant tokenPrice = 0.001 ether;
    // Each NFT would give the user 10 tokens
    // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
    // is actually equal to (10 ^ -18) tokens.
    // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    // More information on this can be found in the Freshman Track Cryptocurrency tutorial.
    uint256 public constant tokensPerNFT = 10 * (10**18);
    // the max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    //CryptoDevs contract instance
    ICryptoDevs CryptoDevsNFT;
    //Mapping to track which token IDs have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    function mint(uint256 amount) public payable {
        //value of ether should be greater or equal to token price amount
        uint256 _requiredAmount = tokenPrice * amount;
        require(_requiredAmount <= msg.value, "Ether sent is incorrect");
        uint256 amountWithDecimals = amount * 10**18;
        require(
            totalSupply() + amountWithDecimals <= maxTotalSupply,
            "Exceeds max supply of tokens"
        );
        _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        require(balance > 0, "You don't own any Crypto Devs NFT");
        uint256 amount = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                amount++;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        //If all the token IDs have been claimed, revert the transaction
        require(amount > 0, "You have already claimed all the tokens");
        //Mint 10 tokens per NFT
        _mint(msg.sender, tokensPerNFT * amount);
    }

    //Function to receive Ether.msg.data must be empty
    receive() external payable {}

    //Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
