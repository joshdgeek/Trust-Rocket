//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Trust is ReentrancyGuard {
    address public admin_owner;

    uint256 feesInPercentage = 1; //current fee
    uint256 platformFee; // fees accumulated from transactions

    bool public isPaused;

    mapping(address => uint256) public merchantBalance;

    constructor() {
        //set admin controls
        admin_owner = msg.sender;
    }

    //EVENTS to log payment confirmations
    event paymentRecieved(address indexed buyer, address indexed merchant, uint256 amount, string product_ID);

    event releaseMerchantFunds(address indexed merchant, uint256 amount);
    event refundCustomerFunds(address indexed merchant, address indexed customer, uint256 amount);

    /// @notice  function to make payment by taking in the merchant's address, price of product and product ID
    function makePayment(address _merchant, uint256 priceofStock, string memory _product)
        public
        payable
        whenNotPaused
    {
        ///@notice run validation for incomming arguents
        require(_merchant != address(0), "Invalid merchant address");
        require(bytes(_product).length > 0, "cannot process payment for empty product");
        require(msg.value == priceofStock, "incorrect amount");

        uint256 actualFee = (feesInPercentage * msg.value) / 1000;
        uint256 amountToMerchant = msg.value - actualFee;

        merchantBalance[_merchant] += amountToMerchant;
        platformFee += actualFee;

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
        ///@notice the same mapping was called by on-purpose
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer failed");

        //RESET merchant balance
        merchantBalance[msg.sender] = 0;

        // emit event
        emit releaseMerchantFunds(msg.sender, amount);
    }

    //Refund customers
    function refundCustomer(address _customerAddress, address _merchantAddress, uint256 amount) public onlyOwner {
        require(merchantBalance[_merchantAddress] >= amount, "Insufficient merchant balance");

        merchantBalance[_merchantAddress] -= amount;

        (bool success,) = payable(_customerAddress).call{value: amount}("");
        require(success, "transfer failed");

        emit refundCustomerFunds(_merchantAddress, _customerAddress, amount);
    }

    function setPercentageFees(uint256 _feeInPercentage) public onlyOwner {
        require(_feeInPercentage <= 100, "Fee cannot exceed 100%");
        feesInPercentage = _feeInPercentage;
    }

    function withdrawPlatformFees() external onlyOwner {
        require(platformFee > 0, "No fees available");
        uint256 amount = platformFee;
        platformFee = 0;
        (bool success,) = payable(admin_owner).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    //Pause contract;
    function togglePause() public onlyOwner {
        //this changes the state of isPaused.
        isPaused = !isPaused;
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
}
