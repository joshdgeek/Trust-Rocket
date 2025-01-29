//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Trust} from "../src/trust.sol";
import {DeployTrust} from "../script/DeployTrust.s.sol";

contract TrustTest is Test {
    address public admin;
    address public merchant;
    address public customer;
    Trust trust;

    function setUp() external {
        admin = address(0xad);
        merchant = address(0x1);
        customer = address(0x2);

        vm.startPrank(admin);
        // DeployTrust deployTrust = new DeployTrust();
        trust = new Trust();
        vm.stopPrank();
    }

    function testAdminControl() public view {
        assertEq(trust.admin_owner(), admin, "not admin");
    }
}
