//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Trust is ReentrancyGuard {
    address public admin_owner;

    uint256 feesInPercentage = 10; //current fee

    bool public isPaused;

    mapping(address => uint256) public merchantBalance;

    constructor() {
        //set admin control
        admin_owner = msg.sender;
    }

    //EVENTS to log payment confirmations
    event paymentRecieved(
        address indexed buyer,
        address indexed merchant,
        uint256 amount,
        string product_ID
    );

    event releaseMerchantFunds(address indexed merchant, uint256 amount);
    event refundCustomerFunds(
        address indexed merchant,
        address indexed customer,
        uint256 amount
    );

    // function to make payment by taking in the merchant's address, price of product and product ID
    function makePayment(
        address _merchant,
        uint256 priceofStock,
        string memory _product
    ) public payable {
        require(_merchant != address(0), "Invalid merchant address");
        require(msg.value == priceofStock, "incorrect amount");

        uint256 actualFee = (feesInPercentage * msg.value) / 1000;
        uint256 amountToMerchant = msg.value - actualFee;

        merchantBalance[_merchant] += amountToMerchant;

        //emit the confirmation of the payment made by the customer
        emit paymentRecieved(msg.sender, _merchant, priceofStock, _product);
    }

    //Merchant withdraw
    function merchantWithdraw() external nonReentrant whenNotPaused {
        //check if merchant balance is less zero
        require(merchantBalance[msg.sender] > 0, "zero balance do not apply");

        // creates a variable for the value of the merchant account stored on-chain
        uint256 amount = merchantBalance[msg.sender];

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
        uint256 amount
    ) public onlyOwner whenNotPaused {
        require(
            merchantBalance[_merchantAddress] >= amount,
            "Insufficient merchant balance"
        );

        merchantBalance[_merchantAddress] -= amount;

        (bool success, ) = payable(_customerAddress).call{value: amount}("");
        require(success, "transfer failed");

        emit refundCustomerFunds(_merchantAddress, _customerAddress, amount);
    }

    //Pause contract;
    function togglePause() public onlyOwner {
        //this changes the state of isPaused.
        isPaused = !isPaused;
    }

    function setPercentageFees(uint _feeInPercentage) public onlyOwner {
        feesInPercentage = _feeInPercentage;
    }

    // modifiers
    modifier whenNotPaused() {
        require(!isPaused, "contract is paused");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == admin_owner);
        _;
    }

    receive() external payable {}
}
