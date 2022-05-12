//"SPDX-License-Indentifier: MIT"
pragma solidity ^0.8.4;

contract whiteList {

    uint8 public maxWhiteListedAddresses;

    uint8 public numAddressesWhitelisted;

    mapping(address => bool) public whiteListedAddresses;

    constructor(uint8 _maxWhiteListedAddresses) {
        maxWhiteListedAddresses = _maxWhiteListedAddresses;
    }

    function addAddressToWhitelist() public {
        //msg.sender address already in the whitelist mapping or not
        require(!whiteListedAddresses[msg.sender], "Address already in the whitelist");
        require(numAddressesWhitelisted < maxWhiteListedAddresses, "Whitelist is now full");
        whiteListedAddresses[msg.sender] = true;
        numAddressesWhitelisted+=1;
    }
}