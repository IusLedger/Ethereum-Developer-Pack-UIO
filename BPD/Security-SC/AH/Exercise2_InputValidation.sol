// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleDeposits {
    mapping(address => uint256) public balances;

    modifier onlyIfNotZero(){
        require(msg.value != 0, "No se puede depositar 0 ETH");
        _;
    }
    
    // 🚨 PROBLEMA: ¿Qué pasa si alguien "deposita" 0 ETH?
    function deposit() public payable onlyIfNotZero{
        balances[msg.sender] += msg.value;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}