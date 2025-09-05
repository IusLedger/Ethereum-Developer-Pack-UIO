// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SecureBank - Contrato bancario con buenas prácticas de seguridad
 * @dev Implementa todas las buenas prácticas de diseño en Solidity
 */
contract SecureBank {
    // ✅ BUENA PRÁCTICA: Variables con visibilidad explícita
    mapping(address => uint256) private balances;
    mapping(address => uint256) private pendingWithdrawals; // Para patrón Pull
    address private owner;
    uint256 private totalDeposits;
    bool private locked; // Para prevenir reentrada
    
    // ✅ BUENA PRÁCTICA: Eventos para transparencia
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // ✅ BUENA PRÁCTICA: Errores personalizados (más eficientes que strings)
    error Unauthorized();
    error InvalidAmount();
    error InsufficientBalance();
    error InvalidAddress();
    error ArrayLengthMismatch();
    error ReentrancyGuard();
    error TransferFailed();
    
    // ✅ BUENA PRÁCTICA: Modificadores para control de acceso
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    // ✅ BUENA PRÁCTICA: Modificador para prevenir reentrada
    modifier nonReentrant() {
        if (locked) revert ReentrancyGuard();
        locked = true;
        _;
        locked = false;
    }
    
    // ✅ BUENA PRÁCTICA: Validador de direcciones
    modifier validAddress(address addr) {
        if (addr == address(0)) revert InvalidAddress();
        _;
    }
    
    constructor() {
        owner = msg.sender;
        locked = false;
    }
    
    // ✅ BUENA PRÁCTICA: Control de acceso + validación + evento
    function transferOwnership(address newOwner) 
        external 
        onlyOwner 
        validAddress(newOwner) 
    {
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    // ✅ BUENA PRÁCTICA: Validación de entradas + eventos
    function deposit() external payable {
        if (msg.value == 0) revert InvalidAmount();
        
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        
        emit Deposit(msg.sender, msg.value);
    }
    
    // ✅ BUENA PRÁCTICA: Patrón Pull para withdrawals (2 pasos)
    function initiateWithdrawal(uint256 amount) external nonReentrant {
        if (amount == 0) revert InvalidAmount();
        if (balances[msg.sender] < amount) revert InsufficientBalance();
        
        // ✅ CEI Pattern: Checks-Effects-Interactions
        // Effects: Actualizamos el estado ANTES de interacciones
        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;
        totalDeposits -= amount;
        
        emit Withdrawal(msg.sender, amount);
    }
    
    // ✅ BUENA PRÁCTICA: Patrón Pull - el usuario retira cuando quiera
    function withdrawPending() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        if (amount == 0) revert InvalidAmount();
        
        // Effect: Actualizamos antes de la transferencia
        pendingWithdrawals[msg.sender] = 0;
        
        // Interaction: Transferencia al final
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            // Revertimos el cambio si falla
            pendingWithdrawals[msg.sender] = amount;
            revert TransferFailed();
        }
    }
    
    // ✅ BUENA PRÁCTICA: Solo owner + patrón Pull
    function initiateEmergencyWithdrawal() external onlyOwner {
        uint256 balance = address(this).balance;
        pendingWithdrawals[owner] += balance;
    }
    
    // ✅ BUENA PRÁCTICA: Control de acceso + validación completa
    function adminTransfer(address from, address to, uint256 amount) 
        external 
        onlyOwner 
        validAddress(from)
        validAddress(to)
    {
        if (amount == 0) revert InvalidAmount();
        if (balances[from] < amount) revert InsufficientBalance();
        if (from == to) revert InvalidAddress(); // No transferir a sí mismo
        
        // Verificación de overflow antes de sumar
        require(balances[to] + amount >= balances[to], "Overflow detected");
        
        balances[from] -= amount;
        balances[to] += amount;
    }
    
    // ✅ BUENA PRÁCTICA: Solo owner puede ver datos sensibles
    function getTotalDeposits() external view onlyOwner returns (uint256) {
        return totalDeposits;
    }
    
    // ✅ BUENA PRÁCTICA: Validación completa + manejo de errores
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) 
        external 
        nonReentrant 
    {
        if (recipients.length != amounts.length) revert ArrayLengthMismatch();
        if (recipients.length == 0) revert InvalidAmount();
        
        uint256 totalAmount = 0;
        
        // Calculamos el total primero para validar
        for (uint256 i = 0; i < amounts.length; i++) {
            if (recipients[i] == address(0)) revert InvalidAddress();
            if (amounts[i] == 0) revert InvalidAmount();
            totalAmount += amounts[i];
        }
        
        if (balances[msg.sender] < totalAmount) revert InsufficientBalance();
        
        // Realizamos las transferencias
        balances[msg.sender] -= totalAmount;
        for (uint256 i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amounts[i];
        }
    }
    
    // ✅ BUENA PRÁCTICA: Funciones view bien definidas
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
    
    function getPendingWithdrawal() external view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }
    
    function getOwner() external view returns (address) {
        return owner;
    }
    
    // ✅ BUENA PRÁCTICA: Función para verificar balance de otro usuario (útil para admin)
    function getBalanceOf(address user) external view onlyOwner returns (uint256) {
        return balances[user];
    }
}