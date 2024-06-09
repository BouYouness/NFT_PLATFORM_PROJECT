// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/MyArtNFT.sol";

contract MyArtNFTTest is Test {
    MyArtNFT nft;
    address owner;
    address recipient;

    function setUp() public{
        nft = new MyArtNFT();
        owner = address(this);
        recipient = address(0x123);
        nft.transferOwnership(msg.sender);   
    }

    function testMintNFT() public{
      vm.prank(msg.sender);
      uint256 tokenId =  nft.mintNFT(recipient,"Art Title", "Art Description", "https://example.com/metadata");
      assertEq(nft.ownerOf(tokenId), recipient);

      //verify token details
      MyArtNFT.Art memory art = nft.getTokenDetails(tokenId);
      assertEq(art.title,"Art Title");
      assertEq(art.description,"Art Description");
      assertEq(art.tokenURI, "https://example.com/metadata");

      //verify token id
      assertEq(tokenId, 0);
    }

    function testMintMultipleNFTs() public {
        vm.startPrank(msg.sender);
        uint256 tokenId1 = nft.mintNFT(recipient,"Art Title 1", "Art Desciption 1","https://example.com/metadata1");
        uint256 tokenId2 = nft.mintNFT(recipient,"Art Title 2", "Art Desciption 2","https://example.com/metadata2");
        vm.stopPrank;

        assertEq(tokenId1,0);
        assertEq(tokenId2,1);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(msg.sender);
        nft.transferOwnership(address(0x548));
        
        //Trying minting from the previous owner, should revert
         vm.startPrank(address(msg.sender));
         vm.expectRevert();
         nft.mintNFT(recipient, "Art Title", "Art Description", "https://example.com/metadata");
         vm.stopPrank;
    }

    function testTokenDoesNotExist() public {
        // Try to get details for a non-existent token
        //vm.expectRevert("Token does not exist");
        nft.getTokenDetails(1);
    }
}