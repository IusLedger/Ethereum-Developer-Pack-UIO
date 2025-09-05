# Soluciones Completas - Optimización de Gas en Solidity

## SOLUCIÓN EJERCICIO 1: Optimización de Bucles

### Código Optimizado
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract OptimizedAirdrop {
    mapping(address => uint256) public balances;
    uint256 public totalSupply = 1000000;
    
    // Límite máximo para evitar out-of-gas
    uint256 public constant MAX_RECIPIENTS = 50;
    
    // Función principal optimizada
    function airdrop(address[] memory recipients, uint256 amount) public {
        // Validaciones de entrada
        require(recipients.length > 0, "No recipients provided");
        require(recipients.length <= MAX_RECIPIENTS, "Too many recipients");
        require(amount > 0, "Amount must be greater than 0");
        
        // Ejecutar airdrop
        for(uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            balances[recipients[i]] += amount;
            totalSupply += amount;
        }
    }
    
    // Función de estimación de gas
    function estimateAirdropGas(uint256 recipientCount) public pure returns (uint256) {
        require(recipientCount <= MAX_RECIPIENTS, "Too many recipients for estimation");
        
        // Gas base para la transacción
        uint256 baseGas = 30000;
        // Gas aproximado por cada destinatario (escritura en mapping)
        uint256 gasPerRecipient = 20000;
        
        return baseGas + (recipientCount * gasPerRecipient);
    }
    
    // Función de transparencia para mostrar costos
    function getAirdropCost(uint256 recipientCount, uint256 gasPriceGwei) 
        public pure returns (uint256 gasEstimate, uint256 costWei) {
        
        gasEstimate = estimateAirdropGas(recipientCount);
        costWei = gasEstimate * gasPriceGwei * 1e9; // Convertir gwei a wei
        
        return (gasEstimate, costWei);
    }
    
    // Función para verificar si una operación es viable
    function isAirdropViable(uint256 recipientCount, uint256 maxGasBudget) 
        public pure returns (bool) {
        
        uint256 estimatedGas = estimateAirdropGas(recipientCount);
        return estimatedGas <= maxGasBudget;
    }
    
    // Función adicional para obtener información de storage
    function getStorageInfo() public pure returns (string memory) {
        return "Airdrop optimizado con límites de gas y estimaciones";
    }
}
```

---

## SOLUCIÓN EJERCICIO 2: Eficiencia de Tipos de Datos

### Código Optimizado
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract EfficientStorage {
    // SLOT 1 (32 bytes): uint256 completo
    uint256 public largeNumber;      // 32 bytes = slot completo
    
    // SLOT 2 (32 bytes): dos uint128 juntos
    uint128 public mediumNumber;     // 16 bytes
    uint128 public anotherMedium;    // 16 bytes
    // Total slot 2: 32 bytes (eficiente)
    
    // SLOT 3 (32 bytes): address + dos bools
    address public owner;            // 20 bytes
    bool public isActive;            // 1 byte  
    bool public isPaused;            // 1 byte
    // Total slot 3: 22 bytes (10 bytes libres, pero aceptable)
    
    constructor() {
        largeNumber = 1000000;
        mediumNumber = 50000;
        anotherMedium = 25000;
        owner = msg.sender;
        isActive = true;
        isPaused = false;
    }
    
    // Función para mostrar el ahorro de gas
    function getStorageInfo() public pure returns (string memory) {
        return "Storage optimizado: 6 slots -> 3 slots = 50% menos gas en escrituras";
    }
    
    // Funciones adicionales para testing
    function updateLargeNumber(uint256 newValue) public {
        largeNumber = newValue;
    }
    
    function updateMediumNumbers(uint128 newMedium1, uint128 newMedium2) public {
        mediumNumber = newMedium1;
        anotherMedium = newMedium2;
    }
    
    function updateFlags(bool newActive, bool newPaused) public {
        isActive = newActive;
        isPaused = newPaused;
    }
}
```

---

## SOLUCIÓN EJERCICIO 3: Funciones View y Pure

### Código Optimizado
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract EfficientFunctions {
    mapping(address => uint256) public balances;
    uint256 public feePercent = 3;
    
    // ✅ PURE: Solo calcula, no accede storage
    function calculateFee(uint256 amount) public pure returns (uint256) {
        // Hardcoded 3% - no necesita leer storage
        return amount * 3 / 100;
    }
    
    // ✅ VIEW: Lee storage pero no modifica
    function getUserBalance(address user) public view returns (uint256) {
        return balances[user]; // Lectura directa, sin escritura
    }
    
    // ✅ PURE: No necesita leer storage para validación básica
    function isValidAmount(uint256 amount) public pure returns (bool) {
        return amount > 0 && amount <= 1000000; // Solo lógica, sin storage
    }
    
    // ✅ Función adicional PURE para cálculos complejos
    function calculateCompoundFee(uint256 amount, uint256 periods) public pure returns (uint256) {
        uint256 result = amount;
        for(uint i = 0; i < periods; i++) {
            result = result * 103 / 100; // 3% compuesto
        }
        return result - amount; // Solo la ganancia
    }
    
    // ✅ VIEW: Lee múltiples valores del storage
    function getAccountInfo(address user) public view returns (uint256 balance, uint256 estimatedFee) {
        balance = balances[user];
        estimatedFee = calculateFee(balance); // Llama función pure
    }
    
    // ✅ Función que SÍ necesita modificar storage (normal)
    function deposit() public payable {
        require(msg.value > 0, "Must deposit something");
        balances[msg.sender] += msg.value; // Modifica storage = costosa
    }
    
    // Función para testing
    function setBalance(address user, uint256 amount) public {
        balances[user] = amount;
    }
    
    // Demostración de diferencias de gas
    function gasDifferencesDemo() public pure returns (string memory) {
        return "Pure/View functions: FREE when called externally, minimal gas internally";
    }
}
```

---

## SOLUCIÓN EJERCICIO 4: Sistema de Estimaciones

### Código Completo
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TransparentGasContract {
    mapping(address => uint256) public balances;
    
    // Constantes para estimaciones
    uint256 public constant BASE_GAS = 21000;
    uint256 public constant GAS_PER_TRANSFER = 15000;
    uint256 public constant MAX_GAS_LIMIT = 300000;
    
    constructor() {
        balances[msg.sender] = 1000000; // Balance inicial para pruebas
    }
    
    // ✅ Función original para referencia
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "Arrays must match");
        
        for(uint i = 0; i < recipients.length; i++) {
            require(balances[msg.sender] >= amounts[i], "Insufficient balance");
            balances[msg.sender] -= amounts[i];
            balances[recipients[i]] += amounts[i];
        }
    }
    
    // ✅ Función principal con límites de gas
    function safeBatchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        // Validaciones básicas
        require(recipients.length == amounts.length, "Arrays must match");
        require(recipients.length > 0, "No recipients provided");
        
        // Estimación y límite de gas
        uint256 estimatedGas = estimateBatchTransferGas(recipients.length);
        require(estimatedGas <= MAX_GAS_LIMIT, "Operation too expensive");
        
        // Ejecutar transferencias
        for(uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            require(amounts[i] > 0, "Invalid amount");
            require(balances[msg.sender] >= amounts[i], "Insufficient balance");
            
            balances[msg.sender] -= amounts[i];
            balances[recipients[i]] += amounts[i];
        }
    }
    
    // ✅ Estimación básica de gas
    function estimateBatchTransferGas(uint256 transferCount) public pure returns (uint256) {
        return BASE_GAS + (transferCount * GAS_PER_TRANSFER);
    }
    
    // ✅ Estimación avanzada con diferentes unidades
    function getOperationCost(uint256 transferCount, uint256 gasPriceGwei) 
        public pure returns (
            uint256 gasEstimate,
            uint256 costWei,
            uint256 costGwei,
            uint256 costEther
        ) {
        
        gasEstimate = estimateBatchTransferGas(transferCount);
        costGwei = gasEstimate * gasPriceGwei;
        costWei = costGwei * 1e9; // gwei to wei
        costEther = costWei; // Para mostrar en formato ether (frontend divide por 1e18)
        
        return (gasEstimate, costWei, costGwei, costEther);
    }
    
    // ✅ Verificar viabilidad antes de ejecutar
    function isOperationViable(uint256 transferCount) public pure returns (bool viable, string memory reason) {
        uint256 estimatedGas = estimateBatchTransferGas(transferCount);
        
        if (estimatedGas > MAX_GAS_LIMIT) {
            return (false, "Operation exceeds gas limit");
        }
        
        if (transferCount == 0) {
            return (false, "No transfers to process");
        }
        
        return (true, "Operation is viable");
    }
    
    // ✅ Función para obtener múltiples precios según diferentes gas prices
    function getMultiplePriceEstimates(uint256 transferCount) 
        public pure returns (
            uint256 gasEstimate,
            uint256 lowCost,    // 20 gwei
            uint256 mediumCost, // 50 gwei  
            uint256 highCost    // 100 gwei
        ) {
        
        gasEstimate = estimateBatchTransferGas(transferCount);
        lowCost = gasEstimate * 20 * 1e9;    // 20 gwei
        mediumCost = gasEstimate * 50 * 1e9; // 50 gwei
        highCost = gasEstimate * 100 * 1e9;  // 100 gwei
        
        return (gasEstimate, lowCost, mediumCost, highCost);
    }
    
    // ✅ Función de ayuda para calcular máximo número de transferencias
    function getMaxTransfersForBudget(uint256 gasBudget) public pure returns (uint256) {
        if (gasBudget <= BASE_GAS) {
            return 0;
        }
        return (gasBudget - BASE_GAS) / GAS_PER_TRANSFER;
    }
    
    // Funciones auxiliares para testing
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
    
    function setBalance(address user, uint256 amount) public {
        balances[user] = amount;
    }
}

---

## RESUMEN DE CONCEPTOS APLICADOS

### Optimización de Bucles
- ✅ Límites máximos para prevenir out-of-gas
- ✅ Validaciones tempranas para fail-fast
- ✅ Estimaciones precisas basadas en operaciones

### Eficiencia de Storage
- ✅ Packing de variables para reducir slots
- ✅ Ahorro significativo en operaciones SSTORE
- ✅ Organización inteligente por tamaños

### Funciones View y Pure  
- ✅ Pure para cálculos sin storage
- ✅ View para lecturas sin modificaciones
- ✅ Eliminación de escrituras innecesarias

### Transparencia de Gas
- ✅ Estimaciones previas para usuarios
- ✅ Múltiples unidades de costo
- ✅ Verificación de viabilidad
- ✅ Límites dinámicos basados en gas

## MÉTRICAS DE OPTIMIZACIÓN

### Ejercicio 1: Airdrop
- **Gas sin límites:** Potencial out-of-gas con arrays grandes
- **Gas optimizado:** Máximo 30,000 + (50 × 20,000) = 1,030,000 gas
- **Mejora:** Operación predecible y segura

### Ejercicio 2: Storage
- **Slots originales:** 6 slots
- **Slots optimizados:** 3 slots  
- **Ahorro:** 50% menos gas en escrituras (SSTORE)

### Ejercicio 3: View/Pure
- **Funciones originales:** Costosas (modifican storage)
- **Funciones optimizadas:** Gratuitas externamente
- **Ahorro:** 100% en consultas frecuentes

### Ejercicio 4: Estimaciones
- **Sin estimaciones:** Usuarios operan a ciegas
- **Con estimaciones:** Transparencia total del costo
- **Beneficio:** Mejor UX y confianza del usuario

**Estas optimizaciones pueden reducir costos de gas entre 30-70% en operaciones típicas.**