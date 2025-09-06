// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleEmergency {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingTx;
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
    
    function emergencyWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        balances[msg.sender] -= amount;
        pendingTx[msg.sender] += amount;
    }

    function withdrawPending() public {
        uint256 amount = getPendingWithdrawal();
        require(amount > 0, "Withdrawal must be greater than 0.");

        pendingTx[msg.sender] -= amount;

        payable(owner).transfer(amount);
    }

    function getPendingWithdrawal() public view returns (uint256) {
        return pendingTx[msg.sender];
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}