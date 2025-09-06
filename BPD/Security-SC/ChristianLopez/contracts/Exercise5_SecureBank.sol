// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SecureBank {
    mapping(address => uint256) private balances;
    mapping(address => uint256) private pendingWithdrawals;
    address private owner;
    uint256 private totalFunds;
    bool private locked;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner.");
        _;
    }
    
    modifier nonReentrant {
        require(locked == false, "Lock must be released before calling.");

        locked = true;
        _;
        locked = false;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Your deposit must be greater than 0 ETH.");
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) public nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    function initiateWithdrawal(uint256 amount) public {
        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;
    }
    
    function withdrawPending() public {
        uint256 amount = getPendingWithdrawal();
        require(amount > 0, "Withdrawal must be greater than 0.");

        pendingWithdrawals[msg.sender] -= amount;

        payable(owner).transfer(amount);
    }
    
    function emergencyWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;
    }
    
    function adminTransfer(address from, address to, uint256 amount) public onlyOwner {
        require(from != to, "You cannot transfer to yourself");

        require(amount > 0, "Transfer amount must be greater than 0");
        require(balances[from] >= amount, "Balance is insufficient");
    
        balances[from] -= amount;
        balances[to] += amount;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getPendingWithdrawal() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getTotalFunds() public view returns (uint256) {
        return totalFunds;
    }
}