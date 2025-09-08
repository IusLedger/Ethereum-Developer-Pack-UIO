// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleEmergency {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingWithdrawals;
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
    }
    
    // 🚨 PROBLEMA: ¿Qué pasa si transfer() falla? ¿Se bloquea toda la función?
    function emergencyWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        balances[owner] -= amount;
        pendingWithdrawals[msg.sender] += amount;
    }

    function withdrawPending() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawal");
        pendingWithdrawals[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success, "Transfer failed.");
    }

    function getPendingWithdrawal() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}