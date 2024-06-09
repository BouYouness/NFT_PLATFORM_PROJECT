// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract MyArtNFT is ERC721, Ownable , ReentrancyGuard {
    
    uint256 private _tokenIds;

    struct Art{
        string title;
        string description;
        string tokenURI;
    }

    mapping(uint256 => Art) public _tokenDetails;

    constructor() ERC721("MyArtNFT", "ART") Ownable(msg.sender){}
    
    //function is protected against reentrancy by using nonreentrant modifier
    function mintNFT(address recipient, string memory title, string memory description, string memory tokenURI) public nonReentrant onlyOwner returns(uint256){

        uint256 newItemId = _tokenIds;

        _mint(recipient, newItemId);

        _setTokenDetails(newItemId, title, description, tokenURI);

        _tokenIds++;
        
        return newItemId;
    }

    function _setTokenDetails(uint256 tokenId, string memory title, string memory description, string memory tokenURI) private {
        _tokenDetails[tokenId] = Art(title, description, tokenURI);
    }

    function getTokenDetails(uint256 tokenId) public view returns(Art memory){
        return _tokenDetails[tokenId];
    }

    function _baseURI() internal view virtual override returns (string memory){
        return "http://api.myartnft.com/metadata/";
    }
}
