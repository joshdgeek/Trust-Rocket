//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Trust {
    address public admin_owner;
    address[] public customerWallets;
    mapping(address => uint) public merchantBalance;

    constructor() {
        //set admin control
        admin_owner = msg.sender;
    }

    //EVENTS to log payment confirmations
    event paymentRecieved(
        address indexed buyer,
        address indexed merchant,
        uint amount,
        string product_ID
    );

    event releaseMerchantFunds(address indexed merchant, uint amount);
    event refundCustomerFunds(
        address indexed merchant,
        address indexed customer,
        uint amount
    );

    // function to make payment by taking in the merchant's address, price of product and product ID
    function makePayment(
        address _merchant,
        uint priceofStock,
        string memory _product
    ) public payable {
        require(msg.value == priceofStock, "incorrect amount");

        //ADD customer's address to the customers array
        customerWallets.push(msg.sender);

        // Updates the merchants balance held on the contract
        merchantBalance[_merchant] += msg.value;

        //emit the confirmation of the payment made by the customer
        emit paymentRecieved(msg.sender, _merchant, priceofStock, _product);
    }

    //function to get price
    function getPrice() public view returns (int) {
        AggregatorV3Interface getPriceData = AggregatorV3Interface(
            0x001382149eBa3441043c1c66972b4772963f5D43
        );
        (, int answer, , , ) = getPriceData.latestRoundData();
        return answer;
    }

    //Merchant withdraw
    function merchantWithdraw() external nonReentrant {
        //check if merchant balance is less zero
        require(merchantBalance[msg.sender] > 0, "zero balance do not apply");

        // creates a variable for the value of the merchant account stored on-chain
        uint amount = merchantBalance[msg.sender];

        //send transaction to merchant wallet
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer failed");

        //RESET merchant balance
        merchantBalance[msg.sender] = 0;

        // emit event
        emit releaseMerchantFunds(msg.sender, amount);
    }

    //Refund customers
    function refundCustomer(
        address _customerAddress,
        address _merchantAddress,
        uint amount
    ) public onlyOwner {
        require(
            merchantBalance[_merchantAddress] >= amount,
            "Insufficient merchant balance"
        );

        merchantBalance[_merchantAddress] -= amount;
        (bool success, ) = payable(_customerAddress).call{value: amount}("");
        require(success, "transfer failed");

        emit refundCustomerFunds(_merchantAddress, _customerAddress, amount);
    }

    // modifiers
    modifier onlyOwner() {
        require(msg.sender == admin_owner);
        _;
    }

    modifier adminTransfer() {
        require(address(this).balance > 0, "insufficient amount");
        _;
    }
}
