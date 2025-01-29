# Trust-Rocket Smart Contract 🛡️  

**Trust-Rocket** is a Solidity smart contract designed to facilitate secure and efficient payments between buyers and merchants. It incorporates platform fee management, merchant fund withdrawal, customer refunds, and contract pausing mechanisms. Built using Solidity `0.8.18`, it leverages Foundry for testing and deployment.

---

## Features  

- **Payment Processing**: Handles payments from buyers to merchants with a small platform fee.  
- **Merchant Fund Withdrawal**: Merchants can securely withdraw their earnings.  
- **Customer Refunds**: Admins can issue refunds from the merchant's balance.  
- **Platform Fee Management**: Admin can withdraw accumulated platform fees.  
- **Pause Functionality**: The admin can pause contract operations for security or maintenance.  
- **Security**: Implements OpenZeppelin's `ReentrancyGuard` to prevent reentrancy attacks.  

---

## Prerequisites  

Before deploying or testing the contract, ensure you have the following:  

- **Foundry Framework**: Installed via [`foundryup`].
- **Solidity Compiler**: Foundry automatically handles this.  
- **Ethereum Wallet**: For testing on testnets (e.g., MetaMask).  

---

## Getting Started  

Clone the repository and set up the project:  

```bash  
git clone <repository-url>  
cd trust-smart-contract  
forge install  
