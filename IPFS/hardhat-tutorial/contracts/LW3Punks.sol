// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LW3Punks is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public _price = 0.01 ether;
    uint256 public maxTokenIDs = 10;
    uint256 public tokenIDs;
    bool public _paused;
    string _baseTokenURI;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract is currently paused");
        _;
    }

    constructor(string memory baseTokenURI) ERC721("LW3Punks", "LW3P") {
        _baseTokenURI = baseTokenURI;
    }

    function mint() public payable onlyWhenNotPaused {
        require(tokenIDs < maxTokenIDs, "All LW3 Punks have been minted");
        require(msg.value >= _price, "Insufficient amount");
        tokenIDs++;
        _safeMint(msg.sender, tokenIDs);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // @dev tokenURI overides the Openzeppelin's ERC721 implementation for tokenURI function
    // This function returns the URI from where we can extract the metadata for a given tokenId
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Token does not exist");
        string memory baseTokenURI = _baseURI();
        return
            bytes(baseTokenURI).length > 0
                ? string(
                    abi.encodePacked(baseTokenURI, tokenId.toString(), ".json")
                )
                : "";
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 _balance = address(this).balance;
        (bool sent, ) = _owner.call{value: _balance}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}
