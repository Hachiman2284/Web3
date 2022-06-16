// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public cryptoDevTokenAddress;

    constructor(address _CryptoDevToken) ERC20("CryptoDev LP Token", "CDLP") {
        require(
            _CryptoDevToken != address(0),
            "Token address passed is a null address"
        );
        cryptoDevTokenAddress = _CryptoDevToken;
    }

    //Function to get the balance of Crypto Dev tokens held by the contract
    function getReserve() public view returns (uint256) {
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }

    //Implementing the adding liquidity function
    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        uint256 liquidity;
        uint256 ethBalance = address(this).balance;
        uint256 cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

        if (cryptoDevTokenReserve == 0) {
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint256 ethReserve = ethBalance - msg.value;
            uint256 cryptoDevTokenAmount = (msg.value / ethReserve) *
                cryptoDevTokenReserve;
            require(
                _amount >= cryptoDevTokenAmount,
                "Amount being sent is less than the required CD tokens"
            );
            cryptoDevToken.transferFrom(
                msg.sender,
                address(this),
                cryptoDevTokenAmount
            );
            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    //Implementing removing liquidity function
    function removeLiquidity(uint256 _amount)
        public
        returns (uint256, uint256)
    {
        require(_amount > 0, "Amount should be greater than 0");
        uint256 ethReserve = address(this).balance;
        uint256 _totalSupply = totalSupply();
        // The amount of Eth that would be sent back to the user is based
        // on a ratio
        // Ratio is -> (Eth sent back to the user) / (current Eth reserve)
        // = (amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
        // Then by some maths -> (Eth sent back to the user)
        // = (current Eth reserve * amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
        uint256 ethAmount = (ethReserve * _amount) / _totalSupply;
        // The amount of Crypto Dev token that would be sent back to the user is based
        // on a ratio
        // Ratio is -> (Crypto Dev sent back to the user) / (current Crypto Dev token reserve)
        // = (amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
        // Then by some maths -> (Crypto Dev sent back to the user)
        // = (current Crypto Dev token reserve * amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
        uint256 cryptoDevTokenAmount = (getReserve() * _amount) / _totalSupply;
        //Burn the LP tokens from the user's wallet
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
        return (ethAmount, cryptoDevTokenAmount);
    }

    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(
            inputReserve > 0 && outputReserve > 0,
            "Invalid reserve amounts"
        );
        //charging a fee of 1 %
        uint256 inputAmountWithFee = 99 * inputAmount;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (100 * inputReserve) + inputAmountWithFee;
        return numerator / denominator;
    }

    function ethToCryptoDevToken(uint256 _mintTokens) public payable {
        uint256 tokenReserve = getReserve();
        // call the `getAmountOfTokens` to get the amount of Crypto Dev tokens
        // that would be returned to the user after the swap
        // Notice that the `inputReserve` we are sending is equal to
        // `address(this).balance - msg.value` instead of just `address(this).balance`
        // because `address(this).balance` already contains the `msg.value` user has sent in the given call
        // so we need to subtract it to get the actual input reserve
        uint256 tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(tokensBought >= _mintTokens, "Insufficient output amount");
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
    }

    function cryptoDevTokenToEth(uint256 _tokensSold, uint256 _mintEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );
        require(ethBought >= _mintEth, "Insufficient output amount");
        ERC20(cryptoDevTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
        payable(msg.sender).transfer(ethBought);
    }
}
