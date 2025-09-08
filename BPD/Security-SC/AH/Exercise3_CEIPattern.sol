// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleWithdrawals {
    mapping(address => uint256) public balances;
    
    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
    }
    
    // 🚨 PROBLEMA: ¿Ves algún problema con el ORDEN de estas operaciones?
    function withdraw(uint256 amount) public {
                
        // check
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // ❌ PROBLEMA: ¿Esta actualización llega muy tarde?
        // Effect
        balances[msg.sender] -= amount;
        
        // Iteration
        // ❌ PELIGRO: ¿Qué pasa si esta línea permite al receptor llamar withdraw() otra vez?
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
