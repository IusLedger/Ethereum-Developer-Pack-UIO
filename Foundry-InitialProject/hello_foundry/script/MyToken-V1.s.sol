// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployScript is Script {
    MyToken public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new MyToken(
            "MyToken",
            "MT",
            18,
            1000000000000000000000
        );

        vm.stopBroadcast();
    }
}