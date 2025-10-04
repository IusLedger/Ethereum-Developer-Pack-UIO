// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {console} from "forge-std/console.sol";

contract DeployVaultScript is Script {
    Vault public vault;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        vault = new Vault();
        
        console.log("Vault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}