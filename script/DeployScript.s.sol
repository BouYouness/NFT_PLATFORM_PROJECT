// SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/MyArtNFT.sol";
import "../src/ArtMarketplace.sol";

contract DeployScript is Script {
    MyArtNFT nft;

    function setUp() public {
        nft = new MyArtNFT();
    }

    function run() external {
        vm.startBroadcast();
        new MyArtNFT();
        new ArtMarketplace(address(nft));
        vm.stopBroadcast();
    }
}
