// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./MyArtNFT.sol";

contract ArtMarketplace is ReentrancyGuard {

    struct Listing{
        uint256 price;
        address seller;
    }

    mapping(uint256 => Listing) public listings;

    MyArtNFT private nftContract;

    event NFTListed(uint256 indexed tokenId, uint256 price, address indexed seller);
    event NFTSold(uint256 indexed tokenId, uint256 price, address indexed buyer);


    constructor(address _nftContract){
        nftContract = MyArtNFT(_nftContract);
    }
    
    //Listing an nft with nonReentrant protection
    function listNFT(uint256 tokenId, uint256 price) public nonReentrant{
        //Checks
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not Owner");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");
        
        //Effects 
        listings[tokenId] = Listing(price , msg.sender);
        emit NFTListed(tokenId, price, msg.sender);
    }
    
    // Buying an NFT with nonReentrant protection and Checks-Effects-Interactions pattern
    function buyNFT(uint256 tokenId) public payable nonReentrant {
        Listing memory listing = listings[tokenId];
        
        //Checks 
        require(msg.value == listing.price, "incorrect price");
        require(listing.seller !=address(0), "Token not Listed");
        
        //Effects
        delete listings[tokenId];

        //Interactions
        nftContract.safeTransferFrom(listing.seller, msg.sender, tokenId);
        payable(listing.seller).transfer(msg.value);
        
        emit NFTSold(tokenId, msg.value ,msg.sender);
        
    }

}