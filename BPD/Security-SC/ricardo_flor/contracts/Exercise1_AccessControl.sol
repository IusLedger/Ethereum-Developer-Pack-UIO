// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleOwnership {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier verifyOwner() {
        require(msg.sender==owner, "No es el owner, no puede cambiar el contrato");
        _;
    }  
    // 🚨 PROBLEMA: ¿Quién puede cambiar el owner actualmente?
    function changeOwner(address newOwner) public verifyOwner{
        owner = newOwner;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
}