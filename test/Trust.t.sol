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

    function testIncorrectPayment() public {
        vm.expectRevert();
        uint amount = 0.5 ether;
        vm.deal(customer, 1 ether);
        vm.prank(customer);
        trust.makePayment{value: 0.2 ether}(merchant, amount, "steam");
    }

    function testMerchantAccountUpdate() public {
        uint initialBalance = trust.merchantBalance(merchant);
        uint amount = 1 ether; //price of product
        vm.deal(customer, 2 ether); //fund customeracount with 2 eth
        vm.prank(customer); // set customer account to make payment

        trust.makePayment{value: amount}(merchant, amount, "Steam");

        uint newBalance = trust.merchantBalance(merchant);
        assertEq(newBalance, initialBalance + amount);
    }

    function testMerchantWithdrawal() public {
        uint amount = 1 ether;

        //fund customers wallet
        vm.deal(customer, amount);
        vm.prank(customer);
        //customer makes payment
        trust.makePayment{value: amount}(merchant, amount, "steam");

        //check if balance for the merchant address has been updated with payment
        assertEq(trust.merchantBalance(merchant), amount);

        //merchant calls the merchantWithdraw() function
        vm.prank(merchant);
        trust.merchantWithdraw();
        assertEq(trust.merchantBalance(merchant), 0);
    }

    function testOnlyAdminCanWithdrawFunds() public {
        vm.expectRevert(); // test fails if any account other than admin attempts withdrawal
        vm.prank(address(4));
        trust.merchantWithdraw();
    }

    function testRefund() public {
        uint amount = 0.2 ether;
        vm.deal(customer, 1 ether);
        vm.prank(customer);
        trust.makePayment{value: amount}(merchant, amount, "steam");

        //console.logUint(customer.balance);
        assertEq(customer.balance, 0.8 ether);
        vm.prank(admin);
        trust.refundCustomer(customer, merchant, amount);
        assertEq(customer.balance, 1 ether);
    }
}
