// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint256) balances;
    address owner;
    uint256 totalDeposits;
    
    constructor() {
        owner = msg.sender;
    }
    
    // ❌ PROBLEMA 1: Función sin control de acceso
    function setOwner(address newOwner) public {
        owner = newOwner; // Cualquiera puede cambiar el propietario
    }
    
    // ❌ PROBLEMA 2: Sin validación de entradas
    function deposit() public payable {
        balances[msg.sender] += msg.value; // No valida si msg.value > 0
        totalDeposits += msg.value;
    }
    
    // ❌ PROBLEMA 3: Vulnerable a reentrada + Push pattern
    function withdraw(uint256 amount) public {
        // No sigue el patrón CEI (Checks-Effects-Interactions)
        require(balances[msg.sender] >= amount); // Check
        
        // ⚠️ PELIGRO: Interacción ANTES de actualizar el estado
        (bool success, ) = msg.sender.call{value: amount}(""); // Interaction
        require(success, "Transfer failed");
        
        // Effect viene después de la interacción (MAL ORDEN)
        balances[msg.sender] -= amount; // Effect
        totalDeposits -= amount;
    }
    
    // ❌ PROBLEMA 4: Función pública que debería ser interna
    function emergencyWithdraw() public {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance); // Puede fallar y bloquear el contrato
    }
    
    // ❌ PROBLEMA 5: Sin validación + visibilidad incorrecta
    function adminTransfer(address from, address to, uint256 amount) public {
        // Sin verificar si es admin
        // Sin validar direcciones
        balances[from] -= amount; // Puede causar underflow
        balances[to] += amount;   // Puede causar overflow
    }
    
    // ❌ PROBLEMA 6: Función que expone datos internos sin restricción
    function getTotalDeposits() public view returns (uint256) {
        return totalDeposits; // Debería ser solo para el owner
    }
    
    // ❌ PROBLEMA 7: Sin manejo de errores adecuado
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        // No valida que los arrays tengan la misma longitud
        for (uint i = 0; i < recipients.length; i++) {
            balances[msg.sender] -= amounts[i]; // Sin verificar balance suficiente
            balances[recipients[i]] += amounts[i]; // Sin validar dirección
        }
    }
    
    // Función para ver balance (correcta)
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}