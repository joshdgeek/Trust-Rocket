//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Trust} from "../src/trust.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployTrust is Script {
    function run() external {
        vm.startBroadcast();

        // Your contract deployment and other logic here.
        Trust trust = new Trust();
        console.log("Trust contract deployed at:", address(trust));
        // Ensure `vm.stopBroadcast();` is reachable

        vm.stopBroadcast();
    }
}
