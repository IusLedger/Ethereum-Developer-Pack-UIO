# Ejercicios de Optimización de Gas en Solidity

## Objetivo
Aprender a escribir contratos eficientes que minimicen el consumo de gas y sean transparentes con los usuarios.

---

## EJERCICIO 1: Optimización de Bucles

### Objetivo
Convertir una función con bucle ineficiente en una versión optimizada y segura.

### Código Base
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract IneffientAirdrop {
    mapping(address => uint256) public balances;
    uint256 public totalSupply = 1000000;
    
    // PROBLEMA: ¿Qué pasa si recipients tiene 10,000 direcciones?
    function airdrop(address[] memory recipients, uint256 amount) public {
        for(uint i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amount;
            totalSupply += amount;
        }
    }
}
```

### Tu Tarea
1. **Identificar el problema:** ¿Por qué esta función puede fallar?
2. **Optimizar la función:** Agregar límites y validaciones
3. **Agregar transparencia:** Función para estimar gas

### Pistas

#### Pista 1: Límite de destinatarios
```solidity
// ¿Qué validación agregarías al inicio?
require(recipients.length <= /* ¿cuántos? */, "Too many recipients");
```

#### Pista 2: Estimación de gas
```solidity
// Función para estimar gas ANTES de ejecutar
function estimateAirdropGas(uint256 recipientCount) public pure returns (uint256) {
    // Aproximación: 30,000 gas base + 20,000 gas por destinatario
    return /* ¿cómo calcularías esto? */;
}
```

#### Pista 3: Función optimizada completa
¿Cómo quedaría `airdrop()` con límites y validaciones?

---

## EJERCICIO 2: Eficiencia de Tipos de Datos

### Objetivo
Optimizar el storage de un contrato reorganizando variables para usar menos slots.

### Código Base
```solidity
contract IneffientStorage {
    // PROBLEMA: Cada variable usa un slot completo de 32 bytes
    bool public isActive;        // Usa 32 bytes, desperdicia 31
    uint256 public largeNumber;  // Usa 32 bytes ✓
    uint128 public mediumNumber; // Usa 32 bytes, desperdicia 16
    bool public isPaused;        // Usa 32 bytes, desperdicia 31
    uint128 public anotherMedium;// Usa 32 bytes, desperdicia 16
    address public owner;        // Usa 32 bytes, desperdicia 12
    
    // Total: 6 slots = gas caro para escribir/leer
}
```

### Tu Tarea
1. **Reorganizar variables** para minimizar slots de storage
2. **Mantener funcionalidad** - solo cambiar el orden/agrupación

### Pistas

#### Pista 1: ¿Qué variables pueden compartir slot?
- `bool` usa 1 byte
- `uint128` usa 16 bytes  
- `address` usa 20 bytes
- Un slot tiene 32 bytes total

#### Pista 2: Agrupación eficiente
```solidity
contract EfficientStorage {
    // SLOT 1 (32 bytes): uint256 solo
    uint256 public largeNumber;  // 32 bytes = slot completo ✓
    
    // SLOT 2 (32 bytes): ¿qué variables podrían ir juntas?
    uint128 public mediumNumber;     // 16 bytes
    uint128 public anotherMedium;    // 16 bytes
    // Total slot 2: 32 bytes ✓
    
    // SLOT 3 (32 bytes): ¿qué más puede ir junto?
    address public owner;        // 20 bytes
    bool public isActive;        // 1 byte
    bool public isPaused;        // 1 byte
    // Total slot 3: 22 bytes (10 bytes libres pero está bien)
}
```

#### Pista 3: ¿Cuántos slots ahorraste?
Originales: 6 slots → Optimizado: ¿cuántos slots?

---

## EJERCICIO 3: Funciones View y Pure

### Objetivo
Convertir funciones innecesariamente costosas en versiones view/pure gratuitas.

### Código Base
```solidity
contract ExpensiveFunctions {
    mapping(address => uint256) public balances;
    uint256 public feePercent = 3;
    uint256 public calculationResult; // ❌ Storage innecesario
    
    // PROBLEMA: Esta función MODIFICA storage solo para calcular
    function calculateFee(uint256 amount) public returns (uint256) {
        calculationResult = amount * feePercent / 100; // ❌ Escritura costosa
        return calculationResult;
    }
    
    // PROBLEMA: Esta función MODIFICA storage para leer
    function getUserBalance(address user) public returns (uint256) {
        calculationResult = balances[user]; // ❌ Escritura innecesaria
        return calculationResult;
    }
    
    // PROBLEMA: Esta función podría ser pure
    function isValidAmount(uint256 amount) public view returns (bool) {
        return amount > 0 && amount <= 1000000; // No lee storage
    }
}
```

### Tu Tarea
1. **Convertir a pure:** `calculateFee()` - solo calcula, no necesita storage
2. **Convertir a view:** `getUserBalance()` - solo lee, no modifica
3. **Mejorar a pure:** `isValidAmount()` - no necesita leer storage

### Pistas

#### Pista 1: Función pure para calculateFee
```solidity
// Pure = no lee ni modifica storage
function calculateFee(uint256 amount) public pure returns (uint256) {
    // ¿Cómo calcular 3% sin usar storage?
    return /* tu cálculo aquí */;
}
```

#### Pista 2: Función view para getUserBalance
```solidity
// View = lee storage pero no modifica
function getUserBalance(address user) public view returns (uint256) {
    // Retornar directamente sin modificar storage
    return /* ¿qué retornar? */;
}
```

#### Pista 3: ¿Por qué pure es mejor que view?
- View: lee storage = gas cuando se llama desde otro contrato
- Pure: solo calcula = sin gas extra

---

## EJERCICIO 4: Sistema de Estimaciones de Gas

### Objetivo
Crear un sistema completo que informe a los usuarios sobre costos antes de ejecutar operaciones.

### Código Base
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TransparentGasContract {
    mapping(address => uint256) public balances;
    
    // TODO: Agregar constantes para estimaciones
    // uint256 public constant BASE_GAS = ?;
    // uint256 public constant GAS_PER_TRANSFER = ?;
    // uint256 public constant MAX_GAS_LIMIT = ?;
    
    constructor() {
        balances[msg.sender] = 1000000; // Balance inicial para pruebas
    }
    
    // Función original que necesita optimización
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "Arrays must match");
        
        for(uint i = 0; i < recipients.length; i++) {
            require(balances[msg.sender] >= amounts[i], "Insufficient balance");
            balances[msg.sender] -= amounts[i];
            balances[recipients[i]] += amounts[i];
        }
    }
    
    // TODO: Implementar función con límites de gas
    // function safeBatchTransfer(address[] memory recipients, uint256[] memory amounts) public {
    //     // Agregar validaciones
    //     // Verificar límite de gas
    //     // Ejecutar transferencias
    // }
    
    // TODO: Implementar estimación básica
    // function estimateBatchTransferGas(uint256 transferCount) public pure returns (uint256) {
    //     // Calcular gas base + gas por transferencia
    // }
    
    // TODO: Implementar función de costos completa
    // function getOperationCost(uint256 transferCount, uint256 gasPriceGwei) 
    //     public pure returns (...) {
    //     // Retornar gas, costo en wei, gwei, ether
    // }
    
    // TODO: Implementar función de viabilidad
    // function isOperationViable(uint256 transferCount) public pure returns (bool viable, string memory reason) {
    //     // Verificar si la operación es viable
    // }
    
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
    
    function getMultiplePriceEstimates(uint256 transferCount) 
        public pure returns (
            uint256 gasEstimate,
            uint256 lowCost,    // 20 gwei
            uint256 mediumCost, // 50 gwei  
            uint256 highCost    // 100 gwei
        ) {
        // Esta función puede ser implementada como extensión
        gasEstimate = 21000 + (transferCount * 15000); // Estimación básica
        lowCost = gasEstimate * 20 * 1e9;
        mediumCost = gasEstimate * 50 * 1e9;
        highCost = gasEstimate * 100 * 1e9;
        
        return (gasEstimate, lowCost, mediumCost, highCost);
    }
    
    function getMaxTransfersForBudget(uint256 gasBudget) public pure returns (uint256) {
        if (gasBudget <= 21000) {
            return 0;
        }
        return (gasBudget - 21000) / 15000;
    }
}
```

### Tu Tarea
1. **Crear función de estimación** de gas para `batchTransfer`
2. **Agregar límites** basados en gas estimado
3. **Función de transparencia** que muestre costo en diferentes unidades

### Tests para Verificar tu Solución
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise4_TransparentGas.sol";

contract TestExercise4 {
    TransparentGasContract gasContract;
    
    function beforeAll() public {
        gasContract = new TransparentGasContract();
    }
    
    /// Test: Debe existir función de estimación
    function testEstimationExists() public {
        uint256 estimate = gasContract.estimateBatchTransferGas(5);
        Assert.ok(estimate > 0, "Should provide gas estimation");
    }
    
    /// Test: Debe rechazar operaciones muy costosas
    function testRejectExpensiveOperations() public {
        // Crear arrays grandes que excedan el límite
        address[] memory manyRecipients = new address[](50);
        uint256[] memory amounts = new uint256[](50);
        
        for(uint i = 0; i < 50; i++) {
            manyRecipients[i] = address(uint160(i + 1));
            amounts[i] = 100;
        }
        
        try gasContract.safeBatchTransfer(manyRecipients, amounts) {
            Assert.ok(false, "Should reject expensive operations");
        } catch Error(string memory reason) {
            Assert.ok(true, "Correctly rejects expensive operations");
        }
    }
    
    /// Test: Debe proveer información de costos completa
    function testCostInformation() public {
        (uint256 gas, uint256 costWei, uint256 costGwei, uint256 costEther) = 
            gasContract.getOperationCost(3, 50);
        
        Assert.ok(gas > 0, "Should provide gas estimate");
        Assert.ok(costWei > 0, "Should provide cost in wei");
        Assert.ok(costGwei > 0, "Should provide cost in gwei");
    }
    
    /// Test: Función de viabilidad debe funcionar
    function testViabilityCheck() public {
        (bool viable, string memory reason) = gasContract.isOperationViable(5);
        Assert.ok(viable, "Small operations should be viable");
        
        (bool notViable, ) = gasContract.isOperationViable(0);
        Assert.ok(!notViable, "Zero transfers should not be viable");
    }
    
    /// Test: Transferencias válidas deben funcionar
    /// #value: 1000000000000000000
    function testValidTransfers() public payable {
        gasContract.deposit{value: 1 ether}();
        
        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        
        recipients[0] = address(0x123);
        recipients[1] = address(0x456);
        amounts[0] = 100;
        amounts[1] = 200;
        
        gasContract.safeBatchTransfer(recipients, amounts);
        
        Assert.equal(gasContract.getBalance(recipients[0]), 100, "Should transfer correctly");
    }
}
```

### Pistas

#### Pista 1: Estimación básica
```solidity
function estimateBatchTransferGas(uint256 transferCount) public pure returns (uint256) {
    // Gas base: 21,000
    // Gas por transferencia: ~15,000
    uint256 baseGas = 21000;
    uint256 gasPerTransfer = 15000;
    
    return /* ¿cómo calcular total? */;
}
```

#### Pista 2: Función con límite de gas
```solidity
function safeBatchTransfer(address[] memory recipients, uint256[] memory amounts) public {
    // 1. Estimar gas
    uint256 estimatedGas = estimateBatchTransferGas(recipients.length);
    
    // 2. Verificar límite (ej: máximo 300,000 gas)
    require(estimatedGas <= /* ¿cuánto? */, "Operation too expensive");
    
    // 3. Ejecutar transferencias (copia la lógica de batchTransfer)
}
```

#### Pista 3: Transparencia total
```solidity
function getOperationCost(uint256 transferCount, uint256 gasPriceGwei) 
    public pure returns (uint256 gasEstimate, uint256 costWei, uint256 costGwei) {
    
    gasEstimate = estimateBatchTransferGas(transferCount);
    costWei = gasEstimate * gasPriceGwei * 1e9; // gwei to wei
    costGwei = gasEstimate * gasPriceGwei;
    
    return (gasEstimate, costWei, costGwei);
}
```

---

## CHECKLIST DE VERIFICACIÓN

### Ejercicio 1 - Bucles Optimizados
- [ ] Límite máximo de destinatarios (ej: 50)
- [ ] Función de estimación de gas
- [ ] Validación de inputs
- [ ] Mensaje de error claro

### Ejercicio 2 - Storage Eficiente  
- [ ] Variables agrupadas correctamente
- [ ] Reducción de slots (de 6 a 3)
- [ ] Funcionalidad mantenida
- [ ] Comentarios explicando la optimización

### Ejercicio 3 - View/Pure
- [ ] `calculateFee()` convertida a pure
- [ ] `getUserBalance()` convertida a view  
- [ ] `isValidAmount()` mejorada a pure
- [ ] Sin modificaciones innecesarias de storage

### Ejercicio 4 - Estimaciones
- [ ] Función de estimación implementada
- [ ] Límites de gas aplicados
- [ ] Función de transparencia completa
- [ ] Múltiples unidades de costo

## REFLEXIÓN FINAL

**Pregúntate:**
1. ¿Cómo afectan estas optimizaciones a la experiencia del usuario?
2. ¿Qué otras optimizaciones podrías aplicar?
3. ¿En qué situaciones prioritizarías legibilidad vs eficiencia?

**Recuerda:**
- Gas eficiente = usuarios más felices
- Transparencia = mayor confianza  
- Límites = operaciones más seguras
- View/Pure = consultas gratuitas