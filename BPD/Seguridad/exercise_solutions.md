# 🎯 Soluciones Completas de los Ejercicios

## 🚀 SOLUCIÓN EJERCICIO 1: Control de Acceso

### 📁 `contracts/Exercise1_AccessControl.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleOwnership {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    // ✅ SOLUCIÓN: Modifier para control de acceso
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    // ✅ SOLUCIÓN: Aplicar modifier a función crítica
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address"); // Validación adicional
        owner = newOwner;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
}
```

### 📝 **Explicación de la solución:**
- **Modifier `onlyOwner()`:** Verifica que `msg.sender == owner`
- **Aplicación del modifier:** Se agrega a `changeOwner()`
- **Validación adicional:** Rechaza `address(0)` como nuevo owner
- **El `_;`** en el modifier es donde se ejecuta la función original

---

## 🚀 SOLUCIÓN EJERCICIO 2: Validación de Entradas

### 📁 `contracts/Exercise2_InputValidation.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleDeposits {
    mapping(address => uint256) public balances;
    
    // ✅ SOLUCIÓN: Validar entrada al principio de la función
    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
```

### 📝 **Explicación de la solución:**
- **`require(msg.value > 0, ...)`:** Verifica que el valor enviado sea mayor a 0
- **Ubicación:** La validación va **al principio** de la función
- **Mensaje claro:** Explica por qué falló la verificación
- **Fail fast:** Si la validación falla, la función se revierte inmediatamente

---

## 🚀 SOLUCIÓN EJERCICIO 3: Patrón CEI

### 📁 `contracts/Exercise3_CEIPattern.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleWithdrawals {
    mapping(address => uint256) public balances;
    
    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
    }
    
    // ✅ SOLUCIÓN: Implementar patrón CEI
    function withdraw(uint256 amount) public {
        // C - CHECKS: Verificaciones primero
        require(amount > 0, "Invalid amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // E - EFFECTS: Cambios de estado ANTES de interacciones
        balances[msg.sender] -= amount;
        
        // I - INTERACTIONS: Llamadas externas AL FINAL
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
```

### 📝 **Explicación de la solución:**
- **Checks (C):** Todas las verificaciones van primero
- **Effects (E):** `balances[msg.sender] -= amount` ANTES del transfer
- **Interactions (I):** `call()` va al final
- **¿Por qué funciona?** Si hay reentrada, el balance ya está actualizado

---

## 🚀 SOLUCIÓN EJERCICIO 4: Patrón Pull

### 📁 `contracts/Exercise4_PullPattern.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleEmergency {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingWithdrawals; // ✅ SOLUCIÓN: Mapping para pending
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
    
    // ✅ SOLUCIÓN: emergencyWithdraw con patrón Pull
    function emergencyWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        
        // En lugar de transfer directo, marcar como pendiente
        pendingWithdrawals[owner] += amount;
    }
    
    // ✅ SOLUCIÓN: Función para ver pending withdrawals
    function getPendingWithdrawal() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }
    
    // ✅ SOLUCIÓN: Función para retirar pending
    function withdrawPending() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawal");
        
        // IMPORTANTE: Limpiar ANTES de transferir
        pendingWithdrawals[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
```

### 📝 **Explicación de la solución:**
- **Mapping `pendingWithdrawals`:** Almacena cuánto puede retirar cada usuario
- **`emergencyWithdraw()`:** Marca fondos como pendientes, no transfiere directamente
- **`withdrawPending()`:** Usuario retira cuando quiere
- **Orden seguro:** Limpiar pending ANTES de transferir

---

## 🚀 SOLUCIÓN EJERCICIO 5: Integración Final

### 📁 `contracts/Exercise5_SecureBank.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SecureBank {
    // ✅ Variables privadas con visibilidad correcta
    mapping(address => uint256) private balances;
    mapping(address => uint256) private pendingWithdrawals;
    address private owner;
    uint256 private totalFunds;
    bool private locked; // Para nonReentrant
    
    // ✅ Eventos para transparencia
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event WithdrawalInitiated(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
        locked = false;
    }
    
    // ✅ MODIFIER: Control de acceso
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    // ✅ MODIFIER: Prevenir reentrada
    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    // ✅ MODIFIER: Validar direcciones
    modifier validAddress(address addr) {
        require(addr != address(0), "Invalid address");
        _;
    }
    
    // ✅ FUNCIÓN: Depósito con validación
    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0");
        
        balances[msg.sender] += msg.value;
        totalFunds += msg.value;
        
        emit Deposit(msg.sender, msg.value);
    }
    
    // ✅ FUNCIÓN: Withdraw con CEI + nonReentrant
    function withdraw(uint256 amount) public nonReentrant {
        // C - Checks
        require(amount > 0, "Invalid amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // E - Effects
        balances[msg.sender] -= amount;
        totalFunds -= amount;
        
        // I - Interactions
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
    
    // ✅ FUNCIÓN: Iniciar retiro (patrón pull - paso 1)
    function initiateWithdrawal(uint256 amount) public nonReentrant {
        require(amount > 0, "Invalid amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // Effects: Actualizar estado ANTES
        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;
        totalFunds -= amount;
        
        emit WithdrawalInitiated(msg.sender, amount);
    }
    
    // ✅ FUNCIÓN: Retirar pending (patrón pull - paso 2)
    function withdrawPending() public nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawal");
        
        // Effect: Limpiar ANTES
        pendingWithdrawals[msg.sender] = 0;
        
        // Interaction: Transferir
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
    
    // ✅ FUNCIÓN: Emergency withdraw seguro
    function emergencyWithdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        
        // Patrón Pull: marcar como pendiente
        pendingWithdrawals[owner] += contractBalance;
    }
    
    // ✅ FUNCIÓN: Transfer de admin con validaciones completas
    function adminTransfer(address from, address to, uint256 amount) 
        public 
        onlyOwner 
        validAddress(from)
        validAddress(to)
    {
        require(amount > 0, "Invalid amount");
        require(from != to, "Cannot transfer to self");
        require(balances[from] >= amount, "Insufficient balance");
        
        // Verificación de overflow
        require(balances[to] + amount >= balances[to], "Overflow detected");
        
        balances[from] -= amount;
        balances[to] += amount;
        
        emit Withdrawal(from, amount);
        emit Deposit(to, amount);
    }
    
    // ✅ FUNCIÓN: Cambiar owner seguro
    function changeOwner(address newOwner) public onlyOwner validAddress(newOwner) {
        require(newOwner != owner, "Same owner");
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    // ✅ FUNCIONES VIEW: Solo información necesaria
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    function getPendingWithdrawal() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    // ✅ FUNCIÓN: Solo owner puede ver total funds
    function getTotalFunds() public view onlyOwner returns (uint256) {
        return totalFunds;
    }
    
    // ✅ FUNCIONES ADICIONALES: Para debugging y admin
    function getBalanceOf(address user) public view onlyOwner returns (uint256) {
        return balances[user];
    }
    
    function getPendingWithdrawalOf(address user) public view onlyOwner returns (uint256) {
        return pendingWithdrawals[user];
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function isLocked() public view returns (bool) {
        return locked;
    }
}
```

---

## 📋 RESUMEN DE CONCEPTOS IMPLEMENTADOS

### ✅ **Control de Acceso**
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
}
```

### ✅ **Validación de Entradas**
```solidity
require(msg.value > 0, "Must deposit more than 0");
require(amount > 0, "Invalid amount");
require(from != address(0), "Invalid address");
```

### ✅ **Patrón CEI (Checks-Effects-Interactions)**
```solidity
// 1. Checks
require(balances[msg.sender] >= amount, "Insufficient balance");

// 2. Effects  
balances[msg.sender] -= amount;

// 3. Interactions
msg.sender.call{value: amount}("");
```

### ✅ **Prevención de Reentrada**
```solidity
modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}
```

### ✅ **Patrón Pull vs Push**
```solidity
// ❌ Push (peligroso)
payable(user).transfer(amount);

// ✅ Pull (seguro)
pendingWithdrawals[user] += amount; // Marcar
// Usuario retira después con withdrawPending()
```

### ✅ **Visibilidad Correcta**
```solidity
mapping(address => uint256) private balances; // No public
address private owner; // No public
```

### ✅ **Eventos para Transparencia**
```solidity
event Deposit(address indexed user, uint256 amount);
emit Deposit(msg.sender, msg.value);
```

---

## 🎯 PUNTOS CLAVE PARA RECORDAR

### 🔒 **Seguridad:**
1. **Siempre validar entradas** al principio de las funciones
2. **Usar CEI pattern** en funciones que transfieren valor
3. **Implementar control de acceso** en funciones críticas
4. **Preferir Pull over Push** para transferencias

### 📝 **Buenas Prácticas:**
1. **Variables private** por defecto
2. **Eventos** para tracking de operaciones importantes
3. **Modifiers reutilizables** para lógica común
4. **Mensajes de error descriptivos** en require()

### 🎓 **Patrones Aprendidos:**
- **onlyOwner** → Control de acceso
- **nonReentrant** → Prevención de reentrada  
- **validAddress** → Validación de direcciones
- **CEI** → Orden seguro de operaciones
- **Pull withdrawals** → Transferencias seguras

**¡Estos contratos implementan todas las buenas prácticas de seguridad fundamentales en Solidity!** 🚀