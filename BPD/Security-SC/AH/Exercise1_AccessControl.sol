// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleOwnership {
    address public owner;

    event ShowOwner(address owner);

    modifier onlyOwner(){
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // 🚨 PROBLEMA: ¿Quién puede cambiar el owner actualmente?
    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
}