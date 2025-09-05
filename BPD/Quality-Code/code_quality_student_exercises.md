# Ejercicios de Calidad y Mantenibilidad en Solidity

## Objetivo
Aprender a escribir código mantenible, actualizable y bien testeado que siga las mejores prácticas de desarrollo profesional.

---

## EJERCICIO 1: Refactorización para Claridad y Mantenibilidad

### Objetivo
Transformar código confuso en código profesional y mantenible.

### Contexto
Has heredado este contrato de un desarrollador que ya no está en el equipo. Necesitas mantenerlo y agregar nuevas funcionalidades, pero el código es imposible de entender.

### Código Base - Contrato Confuso
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract BadShop {
    mapping(address => uint256) b;
    mapping(uint256 => address) o;
    mapping(uint256 => uint256) p;
    mapping(uint256 => bool) s;
    uint256 c;
    address ad;
    
    constructor() { ad = msg.sender; }
    
    function f1(uint256 pr) public {
        require(msg.sender != address(0)); c++; o[c] = msg.sender; p[c] = pr; s[c] = true;
    }
    
    function f2(uint256 id) public payable {
        require(s[id] && msg.value >= p[id] && msg.sender != o[id]); 
        payable(o[id]).transfer(msg.value); s[id] = false;
    }
    
    function f3() public { require(msg.sender == ad); payable(ad).transfer(address(this).balance); }
    
    function f4(address u) public view returns (uint256) { return b[u]; }
    
    function f5(uint256 id) public view returns (bool) { return s[id]; }
}
```

### Tu Tarea (30 minutos máximo)
1. **Renombrar variables y funciones** con nombres que expliquen su propósito
2. **Agregar comentarios NatSpec** para documentar el contrato
3. **Organizar código** con estructura clara (variables, events, modifiers, funciones)
4. **Separar la función compleja f2()** en partes más pequeñas

### Tests para Verificar tu Solución
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise1_CleanShop.sol";

contract TestExercise1 {
    CleanShop shop;
    
    function beforeAll() public {
        shop = new CleanShop();
    }
    
    /// Test: Funciones deben tener nombres descriptivos
    function testDescriptiveNames() public {
        shop.createItem(1000);
        Assert.equal(shop.getCurrentItemId(), 1, "Should track item ID with clear function name");
    }
    
    /// Test: Debe mantener funcionalidad original
    /// #value: 1000000000000000000
    function testPurchaseFunctionality() public payable {
        shop.createItem(1 ether);
        uint256 itemId = shop.getCurrentItemId();
        
        shop.purchaseItem{value: 1 ether}(itemId);
        Assert.ok(!shop.isItemAvailable(itemId), "Item should be sold");
    }
}
```

### Pistas Rápidas
- `b` probablemente = balances
- `o` probablemente = owners
- `p` probablemente = prices
- `f1` = crear item, `f2` = comprar, `f3` = retirar fondos

---

## EJERCICIO 2: Análisis Básico de Contratos Actualizables

### Objetivo
Entender la diferencia básica entre contratos inmutables y actualizables.

### Contexto
Tu jefe te pregunta: "¿Deberíamos hacer nuestro token actualizable o inmutable?" Necesitas darle una respuesta simple.

### Código Base - Comparación Simple
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// OPCIÓN A: Token Inmutable (no se puede cambiar)
contract ImmutableToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply = 1000000;
    
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
    
    // ¿Qué pasa si hay un bug aquí? ¿Podemos arreglarlo?
    // Respuesta: NO, está grabado en piedra
}

// OPCIÓN B: Token con Admin (se puede cambiar)
contract AdminToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply = 1000000;
    address public admin;
    
    constructor() {
        admin = msg.sender;
    }
    
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
    
    // Admin puede cambiar cualquier balance
    function adminSetBalance(address user, uint256 newBalance) public {
        require(msg.sender == admin, "Only admin");
        balances[user] = newBalance; // ¿Es esto bueno o malo?
    }
    
    // Admin puede pausar transfers
    function adminPauseTransfers() public {
        require(msg.sender == admin, "Only admin");
        // Código para pausar... ¿Qué opinas de este poder?
    }
}
```

### Tu Tarea (15 minutos máximo)
Completa esta tabla simple:

```
| Aspecto | Token Inmutable | Token con Admin |
|---------|----------------|-----------------|
| ¿Puede corregir bugs? | [SÍ/NO] | [SÍ/NO] |
| ¿Puede robar fondos? | [SÍ/NO] | [SÍ/NO] |
| ¿Los usuarios confían siempre? | [SÍ/NO] | [SÍ/NO] |
| ¿Puede agregar funciones nuevas? | [SÍ/NO] | [SÍ/NO] |
| ¿Es descentralizado? | [SÍ/NO] | [SÍ/NO] |
```

### Pregunta Simple
**¿Cuál elegirías para cada caso?**
- Para Bitcoin: [Inmutable/Admin] - ¿Por qué?
- Para un juego experimental: [Inmutable/Admin] - ¿Por qué?
- Para ahorros de jubilación: [Inmutable/Admin] - ¿Por qué?

---

## EJERCICIO 3: Testing Básico de Seguridad

### Objetivo
Escribir 3 tests simples que eviten perder dinero.

### Contexto
Este contrato guardará dinero real. Solo necesitas verificar que los 3 escenarios más peligrosos no puedan pasar.

### Código Base - Contrato Simple
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PiggyBank {
    mapping(address => uint256) public savings;
    
    function deposit() public payable {
        require(msg.value > 0, "Must send money");
        savings[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) public {
        require(savings[msg.sender] >= amount, "Not enough savings");
        savings[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
    
    function getSavings(address user) public view returns (uint256) {
        return savings[user];
    }
}
```

### Tu Tarea (15 minutos máximo)
Completa estos 3 tests críticos:

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise3_PiggyBank.sol";

contract TestExercise3 {
    PiggyBank bank;
    
    function beforeAll() public {
        bank = new PiggyBank();
    }
    
    /// TEST 1: ¿Puedo depositar 0 ETH?
    function testCannotDepositZero() public {
        try bank.deposit{value: 0}() {
            Assert.ok(false, "Should not allow zero deposits");
        } catch {
            Assert.ok(true, "Correctly blocks zero deposits");
        }
    }
    
    /// TEST 2: ¿Puedo retirar más de lo que tengo?
    /// #value: 1000000000000000000
    function testCannotWithdrawMoreThanBalance() public payable {
        // TODO: Depositar 1 ETH
        bank.deposit{value: 1 ether}();
        
        // TODO: Intentar retirar 2 ETH (debería fallar)
        try bank.withdraw(2 ether) {
            Assert.ok(false, "Should not allow overdraw");
        } catch {
            Assert.ok(true, "Correctly blocks overdraw");
        }
    }
    
    /// TEST 3: ¿Mi dinero se guarda correctamente?
    /// #value: 500000000000000000
    function testMoneyIsSavedCorrectly() public payable {
        uint256 initialSavings = bank.getSavings(address(this));
        
        // TODO: Depositar 0.5 ETH
        bank.deposit{value: 0.5 ether}();
        
        // TODO: Verificar que se guardó correctamente
        uint256 finalSavings = bank.getSavings(address(this));
        Assert.equal(finalSavings, initialSavings + 0.5 ether, "Money should be saved correctly");
    }
}
```

### Preguntas de Reflexión
1. **¿Qué otros tests agregarías?** (no implementes, solo piensa)
2. **¿Qué pasa si alguien envía ETH al contrato sin usar deposit()?**
3. **¿Es este contrato seguro para usar con dinero real?**

---

## REFLEXIÓN FINAL

### Preguntas Simples
1. **Mantenibilidad:** ¿Qué código es más fácil de entender: el del ejercicio 1 antes o después?
2. **Upgrades:** ¿En qué confías más: en código inmutable o en un admin honesto?
3. **Testing:** ¿Estos 3 tests básicos son suficientes para un contrato real?

### Puntos Clave
- **Claridad:** Si no entiendes el código en 30 segundos, necesita mejorarse
- **Upgrades:** Poder actualizar = Poder cambiar reglas = Riesgo
- **Testing:** Mejor 3 tests importantes que 30 irrelevantes

### Próximos Pasos
- Refactorizar código real que encuentres confuso
- Leer sobre casos donde upgrades salieron mal
- Practicar writing tests para contratos simples

---

## REFLEXIÓN FINAL

### Preguntas para Considerar
1. **Código Legacy:** ¿Cómo manejarían código heredado aún más confuso que el ejercicio 1?
2. **Upgrade Decisions:** Si fueran usuarios, ¿preferirían un protocolo inmutable o actualizable? ¿Por qué?
3. **Testing Priorities:** Con tiempo limitado, ¿qué tests escribirían primero?
4. **Real World:** ¿Qué otros tipos de tests agregarían con herramientas como Foundry?

### Puntos Clave para Recordar
- **Claridad > Inteligencia:** Código que un junior puede entender en 6 meses
- **Immutable vs Upgradeable:** No hay respuesta correcta universal, depende del contexto
- **Testing:** 5 tests bien elegidos > 50 tests irrelevantes
- **Trade-offs:** Toda decisión técnica tiene pros y contras, hay que conocerlos

### Próximos Pasos
- Practicar refactoring con proyectos reales
- Analizar upgrades de protocolos famosos (Uniswap, Compound)
- Usar herramientas profesionales (Foundry, Slither, Echidna)
- Participar en auditorías de código