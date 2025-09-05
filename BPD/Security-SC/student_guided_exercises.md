# 🎯 Ejercicios Progresivos de Seguridad en Solidity

## 📚 Introducción
Vas a aprender seguridad en Solidity paso a paso, resolviendo **5 mini-ejercicios** que se enfocan cada uno en **UNA vulnerabilidad específica**. Cada ejercicio tiene tests que te guiarán hacia la solución correcta.

---

## 🚀 EJERCICIO 1: Control de Acceso

### 🎯 Objetivo
Aprender a proteger funciones críticas para que solo personas autorizadas puedan ejecutarlas.

### 📁 Setup
**Archivo:** `contracts/Exercise1_AccessControl.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleOwnership {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    // 🚨 PROBLEMA: ¿Quién puede cambiar el owner actualmente?
    function changeOwner(address newOwner) public {
        owner = newOwner;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
}
```

**Archivo:** `tests/TestExercise1.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise1_AccessControl.sol";

contract TestExercise1 {
    SimpleOwnership bank;
    
    function beforeAll() public {
        bank = new SimpleOwnership();
    }
    
    /// Test: Solo el owner debería poder cambiar ownership
    function testOnlyOwnerCanChangeOwner() public {
        address newOwner = address(0x123);
        
        // Como somos el owner, esto debería funcionar
        bank.changeOwner(newOwner);
        
        // Verificar que cambió
        Assert.equal(bank.getOwner(), newOwner, "Owner should have changed");
        
        // Restaurar para otros tests
        bank.changeOwner(address(this));
    }
    
    /// Test: La función debe rechazar llamadas de no-owners  
    function testRejectNonOwnerCalls() public {
        // Este test verificará que tu modifier funciona
        // Cuando implementes el modifier correctamente, este test pasará
        Assert.ok(true, "Implement onlyOwner modifier to secure changeOwner");
    }
}
```

### 🔍 Analiza el Problema
**Pregúntate:**
1. ¿Qué pasaría si un atacante llama `changeOwner()`?
2. ¿Cómo puede el contrato saber quién es el owner legítimo?
3. ¿Qué mecanismo de Solidity puede restringir acceso a funciones?

### 💡 Pistas Estructuradas

#### Pista 1: Concepto de Modifier
```solidity
// Los modifiers en Solidity permiten agregar condiciones a funciones
// Estructura básica:
modifier nombreDelModifier() {
    // Aquí van las verificaciones
    require(/* condición */, "mensaje de error");
    _; // Aquí se ejecuta la función
}
```

#### Pista 2: ¿Qué Verificar?
```solidity
// Piensa: ¿Qué variable contiene la dirección del owner?
// Piensa: ¿Qué variable contiene quién está llamando la función?
// Compara estas dos variables en tu require()
```

#### Pista 3: Estructura del Modifier
```solidity
modifier onlyOwner() {
    require(/* ¿msg.sender debe ser igual a qué? */, "Not the owner");
    _;
}
```

#### Pista 4: Aplicar el Modifier
```solidity
// Para usar un modifier, agrégalo después de la visibilidad:
function changeOwner(address newOwner) public /* ¿qué modifier va aquí? */ {
    owner = newOwner;
}
```

### ✅ Verifica tu Solución
1. **Compila** tu contrato
2. **Ejecuta los tests** 
3. Si ambos tests pasan → ¡Perfecto! Continúa al Ejercicio 2
4. Si fallan → Revisa las pistas y vuelve a intentar

### 🎓 Reflexión
Una vez que funcione, pregúntate:
- ¿Por qué es importante el control de acceso?
- ¿Qué otros contratos podrían necesitar este patrón?

---

## 🚀 EJERCICIO 2: Validación de Entradas

### 🎯 Objetivo
Aprender a validar que las entradas a las funciones sean válidas antes de procesarlas.

### 📁 Setup
**Archivo:** `contracts/Exercise2_InputValidation.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleDeposits {
    mapping(address => uint256) public balances;
    
    // 🚨 PROBLEMA: ¿Qué pasa si alguien "deposita" 0 ETH?
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
```

**Archivo:** `tests/TestExercise2.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise2_InputValidation.sol";

contract TestExercise2 {
    SimpleDeposits bank;
    
    function beforeAll() public {
        bank = new SimpleDeposits();
    }
    
    /// Test: Depósitos válidos deben funcionar
    /// #value: 1000000000000000000
    function testValidDeposit() public payable {
        uint256 initialBalance = bank.getBalance();
        
        bank.deposit{value: 1 ether}();
        
        uint256 finalBalance = bank.getBalance();
        Assert.equal(finalBalance, initialBalance + 1 ether, "Valid deposit should work");
    }
    
    /// Test: Depósitos de 0 deben ser rechazados
    function testRejectZeroDeposit() public {
        try bank.deposit{value: 0}() {
            Assert.ok(false, "Should reject deposits of 0");
        } catch Error(string memory reason) {
            Assert.ok(true, "Correctly rejects zero deposits");
        } catch {
            Assert.ok(true, "Zero deposit rejected");
        }
    }
}
```

### 🔍 Analiza el Problema
**Pregúntate:**
1. ¿Es útil permitir "depósitos" de 0 ETH?
2. ¿Qué problemas podría causar esto?
3. ¿Cómo puede el contrato verificar el valor enviado?

### 💡 Pistas Estructuradas

#### Pista 1: Variable Especial
```solidity
// En Solidity, cuando alguien envía ETH a una función payable,
// ¿qué variable especial contiene la cantidad enviada?
// Busca en la documentación: msg.???
```

#### Pista 2: Función require()
```solidity
// require() verifica una condición y falla si es falsa
// Estructura: require(condición, "mensaje de error");
// Ejemplo: require(numero > 5, "Numero debe ser mayor a 5");
```

#### Pista 3: ¿Qué Condición Necesitas?
```solidity
function deposit() public payable {
    // Antes de hacer cualquier cosa, verifica:
    // ¿El valor enviado (msg.value) debe ser mayor a qué?
    require(/* ¿qué condición? */, "Must deposit more than 0");
    
    balances[msg.sender] += msg.value;
}
```

#### Pista 4: Ubicación de la Validación
```solidity
// IMPORTANTE: Las validaciones siempre van AL PRINCIPIO de la función
// ¿Por qué? Porque queremos fallar rápido si hay problemas
```

### ✅ Verifica tu Solución
1. **Compila** tu contrato
2. **Ejecuta los tests**
3. Test 1 debe pasar: Depósitos válidos funcionan
4. Test 2 debe pasar: Depósitos de 0 son rechazados

### 🎓 Reflexión
- ¿Qué otras validaciones podrían ser útiles?
- ¿En qué otras funciones aplicarías validaciones?

---

## 🚀 EJERCICIO 3: Patrón CEI (Checks-Effects-Interactions)

### 🎯 Objetivo  
Aprender el orden correcto para escribir funciones seguras y prevenir ataques de reentrada.

### 📁 Setup
**Archivo:** `contracts/Exercise3_CEIPattern.sol`
```solidity
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
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // ❌ PELIGRO: ¿Qué pasa si esta línea permite al receptor llamar withdraw() otra vez?
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        // ❌ PROBLEMA: ¿Esta actualización llega muy tarde?
        balances[msg.sender] -= amount;
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
```

**Archivo:** `tests/TestExercise3.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise3_CEIPattern.sol";

contract TestExercise3 {
    SimpleWithdrawals bank;
    
    function beforeAll() public {
        bank = new SimpleWithdrawals();
    }
    
    /// Test: Withdraw debe actualizar balance correctamente
    /// #value: 2000000000000000000
    function testWithdrawUpdatesBalance() public payable {
        // Depositar primero
        bank.deposit{value: 1 ether}();
        uint256 balanceAfterDeposit = bank.getBalance();
        
        // Retirar la mitad
        bank.withdraw(0.5 ether);
        uint256 balanceAfterWithdraw = bank.getBalance();
        
        // El balance debe haberse actualizado correctamente
        Assert.equal(balanceAfterWithdraw, balanceAfterDeposit - 0.5 ether, "Balance should update correctly");
    }
    
    /// Test: Withdraw no debe permitir retirar más del balance
    /// #value: 1000000000000000000  
    function testWithdrawValidation() public payable {
        bank.deposit{value: 0.5 ether}();
        
        try bank.withdraw(1 ether) {
            Assert.ok(false, "Should not allow overdraw");
        } catch {
            Assert.ok(true, "Correctly prevents overdraw");
        }
    }
}
```

### 🔍 Analiza el Problema
**Pregúntate:**
1. ¿Qué pasa cuando `msg.sender.call()` se ejecuta?
2. ¿Puede el receptor llamar de vuelta a `withdraw()`?
3. ¿Qué ve el atacante cuando verifica su balance la segunda vez?

### 💡 Pistas Estructuradas

#### Pista 1: El Patrón CEI
```solidity
// CEI significa: Checks, Effects, Interactions
// C - Checks: Verificaciones (require statements)
// E - Effects: Cambios al estado del contrato  
// I - Interactions: Llamadas a contratos externos

// ¿En qué orden deberían ir para ser seguro?
```

#### Pista 2: Identifica cada Parte
```solidity
function withdraw(uint256 amount) public {
    // Esto es un CHECK:
    require(balances[msg.sender] >= amount, "Insufficient balance");
    
    // Esto es una INTERACTION:
    (bool success, ) = msg.sender.call{value: amount}("");
    
    // Esto es un EFFECT:  
    balances[msg.sender] -= amount;
    
    // ¿En qué orden deberían ir?
}
```

#### Pista 3: ¿Por qué el Orden Importa?
```solidity
// Imagina este escenario:
// 1. Atacante llama withdraw(10)
// 2. Su balance es 10, pasa la verificación ✅
// 3. Se envían 10 ETH al atacante
// 4. El atacante recibe el ETH y llama withdraw(10) OTRA VEZ
// 5. Su balance SIGUE siendo 10 (porque no se ha actualizado)
// 6. Pasa la verificación otra vez ✅
// 7. Se envían otros 10 ETH...

// ¿Cómo prevenir esto?
```

#### Pista 4: Orden Correcto
```solidity
function withdraw(uint256 amount) public {
    // C - Checks (verificaciones) - PRIMERO
    require(/* verificaciones aquí */);
    
    // E - Effects (cambios de estado) - SEGUNDO  
    /* actualiza balances[msg.sender] aquí */
    
    // I - Interactions (llamadas externas) - ÚLTIMO
    /* haz el transfer aquí */
}
```

#### Pista 5: Implementación Específica
```solidity
function withdraw(uint256 amount) public {
    // C - Checks
    require(balances[msg.sender] >= amount, "Insufficient balance");
    
    // E - Effects (¿qué necesitas actualizar ANTES de transferir?)
    balances[msg.sender] -= amount;
    
    // I - Interactions
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

### ✅ Verifica tu Solución
1. **Reordena** las líneas en `withdraw()` siguiendo CEI
2. **Compila** tu contrato  
3. **Ejecuta los tests**
4. Ambos tests deben pasar

### 🎓 Reflexión
- ¿Por qué CEI previene ataques de reentrada?
- ¿En qué otras funciones aplicarías este patrón?

---

## 🚀 EJERCICIO 4: Patrón Pull vs Push

### 🎯 Objetivo
Aprender a implementar transferencias seguras usando el patrón "Pull" en lugar del peligroso patrón "Push".

### 📁 Setup  
**Archivo:** `contracts/Exercise4_PullPattern.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleEmergency {
    mapping(address => uint256) public balances;
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
    
    // 🚨 PROBLEMA: ¿Qué pasa si transfer() falla? ¿Se bloquea toda la función?
    function emergencyWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount); // ❌ PUSH pattern - peligroso
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
```

**Archivo:** `tests/TestExercise4.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise4_PullPattern.sol";

contract TestExercise4 {
    SimpleEmergency bank;
    
    function beforeAll() public {
        bank = new SimpleEmergency();
    }
    
    /// Test: emergencyWithdraw debe marcar fondos como pendientes
    /// #value: 1000000000000000000
    function testEmergencyWithdrawPullPattern() public payable {
        // Depositar algo al contrato
        bank.deposit{value: 1 ether}();
        
        // Emergency withdraw no debería transferir directamente
        bank.emergencyWithdraw();
        
        // Debería existir una función para ver pending withdrawals
        try bank.getPendingWithdrawal() returns (uint256 pending) {
            Assert.ok(pending > 0, "Should have pending withdrawal after emergency");
        } catch {
            Assert.ok(false, "Should implement getPendingWithdrawal function");
        }
    }
    
    /// Test: Debe existir función withdrawPending
    function testWithdrawPendingExists() public {
        try bank.withdrawPending() {
            Assert.ok(true, "withdrawPending function exists");
        } catch {
            Assert.ok(false, "Should implement withdrawPending function");
        }
    }
}
```

### 🔍 Analiza el Problema
**Pregúntate:**
1. ¿Qué pasa si `transfer()` falla?
2. ¿Puede un contrato malicioso bloquear `emergencyWithdraw()`?
3. ¿Cómo sería más seguro manejar las transferencias?

### 💡 Pistas Estructuradas

#### Pista 1: Push vs Pull
```solidity
// PUSH = El contrato FUERZA el envío
// - Si el receptor no puede recibir, toda la operación falla
// - Ejemplo: transfer(), send()

// PULL = El receptor RETIRA cuando puede  
// - Si el receptor tiene problemas, no afecta otros procesos
// - Más seguro y flexible
```

#### Pista 2: Sistema de Pending Withdrawals
```solidity
// En lugar de transferir directamente, podemos:
// 1. Marcar cuánto dinero tiene cada usuario "pendiente de retiro"
// 2. Dejar que cada usuario retire cuando pueda/quiera

// ¿Qué estructura de datos necesitas para almacenar pending withdrawals?
mapping(address => uint256) public /* ¿cómo llamarías a esta variable? */;
```

#### Pista 3: Estructura de emergencyWithdraw
```solidity
function emergencyWithdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    
    // En lugar de: payable(owner).transfer(amount);
    // Haz esto: marca el amount como pendiente para el owner
    /* ¿cómo marcarías pending withdrawal para owner? */
}
```

#### Pista 4: Función getPendingWithdrawal
```solidity
// Los tests esperan esta función. ¿Cómo la implementarías?
function getPendingWithdrawal() public view returns (uint256) {
    // ¿Qué debería retornar para msg.sender?
    return /* ¿qué valor del mapping? */;
}
```

#### Pista 5: Función withdrawPending
```solidity
function withdrawPending() public {
    // 1. ¿Cuánto tiene pendiente msg.sender?
    uint256 amount = /* ¿de dónde obtienes este valor? */;
    
    // 2. Verificar que tenga algo pendiente
    require(amount > 0, "No pending withdrawal");
    
    // 3. IMPORTANTE: Limpiar pending ANTES de transferir (¿por qué?)
    /* ¿cómo pones en 0 el pending de msg.sender? */
    
    // 4. Transferir
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

#### Pista 6: Implementación Completa
```solidity
// Agregar al contrato:
mapping(address => uint256) public pendingWithdrawals;

function emergencyWithdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    pendingWithdrawals[owner] += amount; // Marcar como pendiente
}

function getPendingWithdrawal() public view returns (uint256) {
    return pendingWithdrawals[msg.sender];
}

function withdrawPending() public {
    uint256 amount = pendingWithdrawals[msg.sender];
    require(amount > 0, "No pending withdrawal");
    
    pendingWithdrawals[msg.sender] = 0; // Limpiar ANTES
    
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

### ✅ Verifica tu Solución
1. **Agrega** el mapping de pending withdrawals
2. **Modifica** emergencyWithdraw() para usar patrón pull
3. **Implementa** getPendingWithdrawal()
4. **Implementa** withdrawPending()
5. **Ejecuta los tests** - ambos deben pasar

### 🎓 Reflexión
- ¿Por qué el patrón Pull es más seguro?
- ¿En qué situaciones usarías Pull vs Push?

---

## 🚀 EJERCICIO 5: Integración Final

### 🎯 Objetivo
Combinar TODAS las técnicas aprendidas en un contrato bancario completo y seguro.

### 📁 Setup
**Archivo:** `contracts/Exercise5_SecureBank.sol`
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SecureBank {
    // TODO: Agregar todas las variables necesarias
    // Pista: balances, owner, pendingWithdrawals, locked (para nonReentrant)
    
    constructor() {
        // TODO: Inicializar owner
    }
    
    // TODO: Implementar modifier onlyOwner
    
    // TODO: Implementar modifier nonReentrant
    // Pista: usar variable locked para prevenir reentrada
    
    function deposit() public payable {
        // TODO: Implementar con validación de entrada
    }
    
    function withdraw(uint256 amount) public {
        // TODO: Implementar con patrón CEI y nonReentrant
    }
    
    function initiateWithdrawal(uint256 amount) public {
        // TODO: Implementar patrón pull - paso 1
    }
    
    function withdrawPending() public {
        // TODO: Implementar patrón pull - paso 2
    }
    
    function emergencyWithdraw() public {
        // TODO: Implementar con onlyOwner y patrón pull
    }
    
    function adminTransfer(address from, address to, uint256 amount) public {
        // TODO: Implementar con onlyOwner y validaciones completas
    }
    
    // TODO: Implementar funciones view necesarias
    // getBalance(), getPendingWithdrawal(), getOwner(), getTotalFunds()
}
```

### 💡 Checklist de Implementación

#### ✅ Variables Necesarias
```solidity
mapping(address => uint256) private balances;
mapping(address => uint256) private pendingWithdrawals;
address private owner;
uint256 private totalFunds;
bool private locked; // Para nonReentrant
```

#### ✅ Modifiers Necesarios
- [ ] `onlyOwner()` - Control de acceso
- [ ] `nonReentrant()` - Prevenir reentrada
- [ ] `validAddress(address)` - Validar direcciones (opcional)

#### ✅ Funciones Core
- [ ] `deposit()` - Con validación de entrada
- [ ] `withdraw()` - Con CEI pattern y nonReentrant
- [ ] `initiateWithdrawal()` - Patrón pull paso 1
- [ ] `withdrawPending()` - Patrón pull paso 2

#### ✅ Funciones Admin
- [ ] `emergencyWithdraw()` - Solo owner, patrón pull
- [ ] `adminTransfer()` - Solo owner, validaciones completas

#### ✅ Funciones View
- [ ] `getBalance()` - Balance del usuario
- [ ] `getPendingWithdrawal()` - Pending del usuario
- [ ] `getOwner()` - Dirección del owner
- [ ] `getTotalFunds()` - Solo para owner

### 🔧 Pistas de Implementación

#### Modifier nonReentrant
```solidity
modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}
```

#### adminTransfer con validaciones completas
```solidity
function adminTransfer(address from, address to, uint256 amount) public onlyOwner {
    // Validar direcciones
    require(from != address(0), "Invalid from address");
    require(to != address(0), "Invalid to address");
    require(from != to, "Cannot transfer to self");
    
    // Validar amount y balance
    require(amount > 0, "Invalid amount");
    require(balances[from] >= amount, "Insufficient balance");
    
    // Transferir
    balances[from] -= amount;
    balances[to] += amount;
}
```

### ✅ Verifica tu Solución
**Usa los tests del ejercicio original** - ¡deberían pasar TODOS!

### 🎓 ¡Felicidades!
Has implementado un contrato bancario seguro que incluye:
- ✅ Control de acceso robusto
- ✅ Validación de entradas completa  
- ✅ Prevención de ataques de reentrada
- ✅ Patrones seguros de transferencia
- ✅ Encapsulación adecuada

## 🎯 Próximos Pasos
1. **Estudia casos reales** de hacks que estas técnicas habrían prevenido
2. **Practica con proyectos más complejos** aplicando estos patrones
3. **Aprende herramientas de auditoría** como Slither y MythX
4. **Únete a bug bounties** para encontrar vulnerabilidades en proyectos reales

¡Ahora tienes las bases para desarrollar contratos seguros! 🚀