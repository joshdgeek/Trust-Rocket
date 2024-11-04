//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Trust} from "../src/trust.sol";
import {Script} from "forge-std/Script.sol";

contract DeployTrust is Script {
    function run() external returns (Trust) {
        vm.startBroadcast();
        Trust trust = new Trust();
        return trust;
        vm.stopBroadcast();
    }
}
