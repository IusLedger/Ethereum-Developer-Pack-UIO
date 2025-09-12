// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleDeposits {
    mapping(address => uint256) public balances;
    
    modifier checkDeposit(){
        require(msg.value > 0, "The amount should be greater than zero");
        _;
    }

    // 🚨 PROBLEMA: ¿Qué pasa si alguien "deposita" 0 ETH?
    function deposit() public payable checkDeposit{
        balances[msg.sender] += msg.value;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}