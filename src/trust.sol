//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import "@OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";

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

    //Merchant withdraw
    function merchantWithdraw() external {
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

    //allow access to admin only on calls
    modifier onlyOwner() {
        require(msg.sender == admin_owner);
        _;
    }

    modifier adminTransfer() {
        require(address(this).balance > 0, "insufficient amount");
        _;
    }
}
