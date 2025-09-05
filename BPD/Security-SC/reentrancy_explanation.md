# Explicación Detallada: Problemas de Seguridad en Contratos

## PROBLEMA 3: Ataque de Reentrada (Reentrancy Attack)

### ¿Qué es un ataque de reentrada?

Un ataque de reentrada ocurre cuando un contrato externo puede llamar de vuelta a una función del contrato original **antes** de que termine de ejecutarse completamente.

### Ejemplo paso a paso del ataque:

**Situación inicial:**
- VulnerableBank tiene 100 ETH
- Atacante tiene balance de 10 ETH en el contrato

**Código vulnerable:**
```solidity
function withdraw(uint256 amount) public {
    require(balances[msg.sender] >= amount); // ✅ Check: "¿Tiene suficiente balance?"
    
    // ❌ PELIGRO: Envía dinero ANTES de actualizar el balance
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
    
    // ❌ PROBLEMA: Esta línea se ejecuta DESPUÉS del call
    balances[msg.sender] -= amount; // Actualiza el balance
}
```

### Paso a paso del ataque:

**Paso 1:** Atacante llama `withdraw(10 ETH)`
- ✅ Check: `balances[atacante] = 10 ETH >= 10 ETH` (pasa)
- 🔄 Se ejecuta `msg.sender.call{value: 10}("")`

**Paso 2:** El `call` activa la función `receive()` del atacante
```solidity
// Contrato del atacante
receive() external payable {
    if (address(vulnerableBank).balance >= 10 ether) {
        vulnerableBank.withdraw(10 ether); // ¡Llama otra vez!
    }
}
```

**Paso 3:** Segunda llamada a `withdraw(10 ETH)`
- ✅ Check: `balances[atacante] = 10 ETH >= 10 ETH` (¡Sigue siendo 10 porque no se ha actualizado!)
- 🔄 Se ejecuta otro `call` por 10 ETH

**Paso 4:** El proceso se repite hasta drenar el contrato
- El atacante puede retirar 10 ETH múltiples veces
- Su balance nunca se actualiza hasta que todas las llamadas terminen
- Resultado: Retira 100 ETH teniendo solo 10 ETH de balance

### El Patrón CEI (Checks-Effects-Interactions)

**C**hecks: Verificaciones
**E**ffects: Cambios de estado
**I**nteractions: Llamadas externas

```solidity
function withdrawSecure(uint256 amount) public {
    // 1. CHECKS: Verificaciones primero
    require(balances[msg.sender] >= amount);
    
    // 2. EFFECTS: Cambios de estado ANTES de interacciones
    balances[msg.sender] -= amount;
    totalDeposits -= amount;
    
    // 3. INTERACTIONS: Llamadas externas al final
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

---

## PROBLEMA 4: Patrón Push Inseguro

### ¿Qué es el patrón Push vs Pull?

**Push Pattern (Inseguro):** El contrato "empuja" el dinero al destinatario
**Pull Pattern (Seguro):** El destinatario "tira" del dinero cuando quiere

### Código problemático:
```solidity
function emergencyWithdraw() public {
    uint256 balance = address(this).balance;
    payable(owner).transfer(balance); // ❌ PUSH: Fuerza el envío
}
```

### Problemas del patrón Push:

**1. Bloqueo del contrato:**
```solidity
// Si el owner es un contrato que rechaza pagos:
contract MaliciousOwner {
    // No tiene función receive() o payable fallback
    // O tiene una que siempre falla
}
```
- El `transfer()` fallará siempre
- La función `emergencyWithdraw()` nunca funcionará
- El contrato se bloquea permanentemente

**2. Límite de gas:**
- `transfer()` solo permite 2300 gas
- Si el receptor necesita más gas, falla

### Solución: Patrón Pull

```solidity
mapping(address => uint256) pendingWithdrawals;

function emergencyWithdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    pendingWithdrawals[owner] += balance; // Marca como pendiente
}

function withdrawPending() public {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0; // Actualiza ANTES
    
    (bool success, ) = msg.sender.call{value: amount}("");
    if (!success) {
        pendingWithdrawals[msg.sender] = amount; // Revierte si falla
    }
}
```

---

## PROBLEMA 5: Falta de Validación y Control de Acceso

### Código problemático:
```solidity
function adminTransfer(address from, address to, uint256 amount) public {
    balances[from] -= amount; // ❌ Sin validaciones
    balances[to] += amount;
}
```

### Problemas específicos:

**1. Sin control de acceso:**
```solidity
// ❌ Cualquier persona puede llamar esta función
// Debería ser solo para administradores
```

**2. Sin validar direcciones:**
```solidity
// ❌ ¿Qué pasa si from = address(0)?
// ❌ ¿Qué pasa si to = address(0)?
// ❌ ¿Qué pasa si from = to?
```

**3. Underflow/Overflow:**
```solidity
// Si balances[from] = 5 y amount = 10:
balances[from] -= amount; // 5 - 10 = ¡número gigante! (underflow)

// Si balances[to] está cerca del máximo uint256:
balances[to] += amount; // ¡Puede causar overflow!
```

### Ejemplo de ataque:

**Escenario:**
- Alice tiene 100 ETH en balance
- Bob tiene 50 ETH en balance
- Charlie (atacante) tiene 0 ETH

**Ataque:**
```solidity
// Charlie llama:
adminTransfer(alice, charlie, 100); // Sin restricciones
```

**Resultado:**
- Alice: 100 - 100 = 0 ETH
- Charlie: 0 + 100 = 100 ETH
- ¡Charlie robó el dinero de Alice!

### Solución completa:
```solidity
function adminTransfer(address from, address to, uint256 amount) 
    external 
    onlyOwner  // Solo administrador
    validAddress(from)  // Validar direcciones
    validAddress(to) 
{
    require(amount > 0, "Invalid amount");
    require(from != to, "Cannot transfer to self");
    require(balances[from] >= amount, "Insufficient balance");
    
    // Verificar overflow
    require(balances[to] + amount >= balances[to], "Overflow");
    
    balances[from] -= amount;
    balances[to] += amount;
}
```

## Resumen Visual del Ataque de Reentrada

```
ATAQUE DE REENTRADA:

1. Atacante: withdraw(10)
   ├─ Check: balance = 10 ✅
   ├─ Call atacante (10 ETH) 
   │  └─ Atacante.receive()
   │     └─ withdraw(10) ← ¡NUEVA LLAMADA!
   │        ├─ Check: balance = 10 ✅ (¡no actualizado!)
   │        ├─ Call atacante (10 ETH)
   │        │  └─ Atacante.receive()
   │        │     └─ withdraw(10) ← ¡OTRA VEZ!
   │        │        └─ ... (continúa hasta drenar)
   │        └─ balance -= 10 (finalmente)
   │     └─ balance -= 10 (finalmente)  
   └─ balance -= 10 (finalmente)

RESULTADO: Atacante retira 100 ETH con solo 10 ETH de balance
```