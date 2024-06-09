// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/MyArtNFT.sol";
import "../src/ArtMarketplace.sol";

contract ArtMarketplaceTest is Test {
    MyArtNFT nft;
    ArtMarketplace marketplace;
    address owner;
    address seller;
    address buyer;

    function setUp() public {
        owner = address(this);
        seller = address(0x123);
        buyer = address(0x456);

        //deploy myartnft and artmarketplace contracts
        nft = new MyArtNFT();
        marketplace = new ArtMarketplace(address(nft));

        //Transfer ownership of the nft contract to the seller 
        nft.transferOwnership(seller);
    }

    function testBuyNFT() public {
        
        //seller mint an nft 
        vm.startPrank(seller);
        uint256 tokenId = nft.mintNFT(seller,"Art Ttile", "Art Description", "https://example.com/metadata");
        nft.setApprovalForAll(address(marketplace), true);

        //seller lists the nft on the martketplace
        uint256 price = 1 ether;
        marketplace.listNFT(tokenId, price);
        vm.stopPrank();

        //Buyer buy the nft
        vm.deal(buyer, 1 ether );
        vm.prank(buyer);
        marketplace.buyNFT{value: 1 ether}(tokenId);
        
        //verify that the buyer now owns the nft
        assertEq(nft.ownerOf(tokenId), buyer);

        //verify that the listing was removed
        (, address sellerAddress) = marketplace.listings(tokenId);
        assertEq(sellerAddress, address(0));

        //verify that the seller received the payment
        assertEq(seller.balance, 1 ether);

    }

    function testFailBuyNFTIncorrectPrice() public {
        //seller mint an nft
        vm.startPrank(seller);
        uint256 tokenId = nft.mintNFT(seller, "Art Title ", "Art Description", "https://example.com/metadata");
        nft.setApprovalForAll(address(marketplace), true);

        //Seller lists the nft on the marketplace
        uint256 price = 1 ether;
        marketplace.listNFT(tokenId, price);
        vm.stopPrank();

        //Buyer attempts to buy the Nft 
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        marketplace.buyNFT{value:0.5 ether}(tokenId);
    }

     function testFailBuyNFTNonExistentListing() public {
        //Buyer attemps to buy a non-existent listing
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        marketplace.buyNFT{value: 1 ether}(0); 
    }

}

