# Plan de Clase: Evolución de KipuBank a KipuBankV2
## Ethereum Developer Pack - Módulo 3 | Duración: 4 horas

---

## **PARTE 1: Análisis y Limitaciones del KipuBank Original** 
*Duración: 2 horas*

### **Objetivos de Aprendizaje**
Al finalizar esta parte, los estudiantes serán capaces de:
- Identificar limitaciones en contratos inteligentes básicos
- Comprender la importancia de los oráculos de precios
- Analizar problemas de escalabilidad y funcionalidad

### **1.1 Revisión Rápida del KipuBank Original (10 minutos)**

#### **Recapitulación Dirigida**
El instructor hará una revisión rápida proyectando el código y destacando:

**Funcionalidades Actuales:**
- ✅ Depósitos en ETH nativos (`deposit()`)
- ✅ Retiros con límite por transacción (0.01 ETH)
- ✅ Cap del banco basado en cantidad de ETH
- ✅ Eventos para deposits/withdrawals
- ✅ Mapping simple: `address => uint256`

**Pregunta Rápida a la Clase:** *"¿Qué pasaría si ETH sube de $2000 a $4000 y nuestro bankCap es 10 ETH?"*
- Respuesta esperada: El valor real del banco se duplicaría sin control

### **1.2 Identificación de Limitaciones (10 minutos)**

#### **Limitaciones Críticas - Presentación Rápida**

**1. Solo ETH → Necesitamos Multi-Token**
```solidity
// Problema: Un solo mapping
mapping(address user => uint256 amount) public s_vault;

// Solución: Mapping anidado  
mapping(address user => mapping(address token => uint256 amount)) public s_vault;
```

**2. Cap Volátil → Cap en Valor USD**
```solidity
// Problema: Si ETH = $2000, cap = 10 ETH = $20,000
//          Si ETH = $4000, cap = 10 ETH = $40,000 ❌

// Solución: Cap fijo en USD usando oráculos
```

**3. Sin Precios → Integrar Chainlink**
- No sabemos el valor real de los depósitos
- No podemos convertir entre ETH y USDC

**4. Sin Control → Añadir Owner Pattern**
- No hay administración del contrato
- No se puede actualizar configuraciones

### **1.3 Chainlink Price Feeds en la Práctica (30 minutos)**

#### **¿Qué son los Data Feeds y por qué los usamos? (5 minutos)**

**Data Feeds** son contratos inteligentes que proporcionan datos del mundo real actualizados constantemente.

**¿Por qué necesitamos Data Feeds en nuestro banco?**
- **Problema:** Nuestro KipuBank original no sabe cuánto vale 1 ETH en dólares
- **Consecuencia:** No podemos tener un cap fijo en valor USD
- **Solución:** Chainlink Data Feeds nos dan el precio ETH/USD en tiempo real

**Ejemplo práctico:**
```
Escenario: Queremos un banco con cap de $50,000 USD
- Sin oracle: Si cap = 25 ETH y ETH = $2000 → valor = $50,000 ✅
- Problema: Si ETH sube a $4000 → valor = $100,000 ❌
- Con oracle: Siempre sabemos el valor real y mantenemos el cap en $50,000
```

#### **¿Por qué necesitamos esta implementación específica?**

**Setup mínimo para Data Feeds:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Import esencial para Data Feeds
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract KipuBankV2 {
    // Variable para almacenar el feed
    AggregatorV3Interface public s_feeds;
    
    // Constantes para validaciones
    uint256 constant ORACLE_HEARTBEAT = 3600; // 1 hora
    
    // Errores específicos
    error KipuBank_OracleCompromised();
    error KipuBank_StalePrice();

    constructor(address _feed) {
        s_feeds = AggregatorV3Interface(_feed);
    }
}
```

**Código de Chainlink explicado línea por línea:**
```solidity
// 1. Interfaz para comunicarse con el contrato de Chainlink
AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

// 2. Obtener datos del feed - ¿por qué estos valores específicos?
(, int price, , uint256 updatedAt,) = priceFeed.latestRoundData();
```

#### **Desglose de `latestRoundData()`**
```solidity
(
    uint80 roundId,        // ❌ ID del round - solo útil para tracking histórico
    int256 answer,         // ✅ El precio que queremos  
    uint256 startedAt,     // ❌ Cuándo empezó el round - no necesario para precios actuales
    uint256 updatedAt,     // ✅ Cuándo se actualizó - crucial para validar frescura
    uint80 answeredInRound // ❌ En qué round se respondió - solo para depuración
)
```

**¿Por qué NO necesitamos estos valores?**

- **`roundId`**: Es un identificador interno de Chainlink. Solo útil si quisiéramos hacer tracking histórico de precios o debugging avanzado.

- **`startedAt`**: Timestamp de cuándo empezó la agregación del precio. Para un banco solo nos importa el precio final y cuándo estuvo listo.

- **`answeredInRound`**: Campo técnico que indica inconsistencias en la agregación. En producción usarías esto, pero para nuestro ejemplo es complejidad innecesaria.

**¿Por qué `int256` y no `uint256`?**
- Chainlink maneja feeds de commodities que pueden tener precios negativos (petróleo WTI llegó a -$37 en 2020)
- ETH/USD nunca será negativo, pero la interfaz es genérica para todos los assets

#### **Implementación Completa con Validaciones**
```solidity
function chainlinkFeed() internal view returns (uint256 ethUSDPrice_) {
    // Usar la variable s_feeds que definimos en el setup
    (, int256 ethUSDPrice,, uint256 updatedAt,) = s_feeds.latestRoundData();
    
    // Validación 1: Precio no puede ser 0 o negativo
    if (ethUSDPrice <= 0) revert KipuBank_OracleCompromised();
    
    // Validación 2: Datos no pueden ser obsoletos (> 1 hora)
    if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert KipuBank_StalePrice();
    
    // Conversión segura de int256 a uint256
    ethUSDPrice_ = uint256(ethUSDPrice);
}
```

#### **Direcciones de Price Feeds**
- **Mainnet ETH/USD:** `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- **Sepolia ETH/USD:** `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- **Decimales:** 8 (precio viene multiplicado por 10^8)

#### **Ejemplo Práctico de Uso**
```solidity
// Si ETH = $2,500.50, Chainlink retorna: 250050000000 (8 decimales)
// Nuestro contrato necesita: 2500500000 (6 decimales para USDC)
// Conversión: price / 100 = 2500500000
```

### **1.5 Actividad Práctica: Testing de Data Feeds en Remix (10 minutos)**

#### **Objetivo**
Los estudiantes deployarán y probarán el contrato con Chainlink Data Feeds en Remix para ver los precios en tiempo real.

#### **Código para Testing (3 minutos)**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract ChainlinkTest {
    AggregatorV3Interface public s_feeds;
    uint256 constant ORACLE_HEARTBEAT = 3600;
    
    error TestContract_OracleCompromised();
    error TestContract_StalePrice();

    constructor(address _feed) {
        s_feeds = AggregatorV3Interface(_feed);
    }
    
    // Función para obtener precio básico
    function getBasicPrice() external view returns (int256) {
        (, int256 price,,,) = s_feeds.latestRoundData();
        return price;
    }
    
    // Función para obtener precio con validaciones
    function getSecurePrice() external view returns (uint256) {
        (, int256 ethUSDPrice,, uint256 updatedAt,) = s_feeds.latestRoundData();
        
        if (ethUSDPrice <= 0) revert TestContract_OracleCompromised();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert TestContract_StalePrice();
        
        return uint256(ethUSDPrice);
    }
    
    // Función para ver todos los datos
    function getAllData() external view returns (
        uint80 roundId,
        int256 price,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return s_feeds.latestRoundData();
    }
    
    // Función para verificar si el precio está actualizado
    function isPriceStale() external view returns (bool) {
        (,, , uint256 updatedAt,) = s_feeds.latestRoundData();
        return (block.timestamp - updatedAt > ORACLE_HEARTBEAT);
    }
}
```

#### **Testing Rápido (7 minutos)**
1. **Deploy en Remix** con Sepolia feed: `0x694AA1769357215DE4FAC081bf1f309aDC325306`
2. **Llamar `getBasicPrice()`** - dividir resultado entre 10^8 para obtener precio en USD
3. **Comparar** con precio real de ETH
4. **Llamar `getAllData()`** - identificar campos que usaremos vs los que ignoramos

### **1.6 Mappings Anidados y SafeERC20 (20 minutos)**

#### **Mappings Anidados: De Single-Token a Multi-Token (10 minutos)**

**Problema del mapping actual:**
```solidity
// KipuBank original - solo ETH
mapping(address user => uint256 amount) public s_vault;

// ¿Qué pasa si queremos soportar USDC también?
// ❌ No podemos distinguir entre balances de ETH y USDC del mismo usuario
```

**Solución: Mapping Anidado**
```solidity
// KipuBankV2 - multi-token
mapping(address user => mapping(address token => uint256 amount)) public s_vault;

// Uso práctico:
s_vault[msg.sender][address(0)] = 100;      // 100 wei de ETH para el usuario
s_vault[msg.sender][address(i_usdc)] = 50;  // 50 USDC para el mismo usuario
```

**¿Cómo funciona?**
- **Primer mapping:** `address user` → Identifica al usuario
- **Segundo mapping:** `address token` → Identifica el token específico
- **`address(0)`**: Convención para ETH nativo
- **`address(i_usdc)`**: Dirección del contrato USDC

**Ejemplo visual:**
```
Usuario: 0x123...
├── address(0) → 5 ETH
├── 0xA0b86... (USDC) → 1000 USDC
└── 0x6B17... (DAI) → 500 DAI
```

#### **SafeERC20: Transferencias Seguras de Tokens (10 minutos)**

**Problema con ERC20 estándar:**
```solidity
// ❌ Algunos tokens no siguen el estándar correctamente
bool success = token.transfer(msg.sender, amount);
// Problema: Algunos tokens no retornan bool, otros retornan false pero no revierten

// ❌ Con .call también puede fallar silenciosamente
(bool success, bytes memory data) = address(token).call(
    abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amount)
);
// Problema: success puede ser true pero el token puede haber fallado internamente
```

**Solución: SafeERC20**
```solidity
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KipuBankV2 {
    using SafeERC20 for IERC20;  // ⬅️ Esto habilita los métodos seguros
    
    IERC20 immutable i_usdc;
    
    function depositUSDC(uint256 _amount) external {
        // ✅ Transferencia segura - revierte automáticamente si falla
        i_usdc.safeTransferFrom(msg.sender, address(this), _amount);
        // Explicación: msg.sender → address(this) (usuario envía al contrato)
    }
    
    function withdrawUSDC(uint256 _amount) external {
        // ✅ Transferencia segura - maneja tokens "problemáticos"
        i_usdc.safeTransfer(msg.sender, _amount);
        // Explicación: address(this) → msg.sender (contrato envía al usuario)
    }
}
```

**¿Por qué estas direcciones específicas?**

**En `safeTransferFrom`:**
- **`msg.sender`**: El usuario que está depositando (origen de los tokens)
- **`address(this)`**: El contrato del banco (destino de los tokens)
- **Flujo**: Usuario → Banco (depósito)

**En `safeTransfer`:**
- **`msg.sender`**: El usuario que está retirando (destino de los tokens)
- **Implícito `address(this)`**: El contrato es quien envía (origen de los tokens)
- **Flujo**: Banco → Usuario (retiro)

**Diferencia clave:**
- **`transferFrom`**: Necesitas especificar FROM y TO (3 parámetros)
- **`transfer`**: Solo especificas TO, el FROM es automático (2 parámetros)

**¿Qué hace SafeERC20?**
- **Normaliza comportamientos** de diferentes implementaciones ERC20
- **Revierte automáticamente** si la transferencia falla
- **Maneja tokens** que no retornan bool correctamente
- **Valida** que el contrato de destino sea válido

**¿Por qué es importante?**
- **USDT:** No retorna bool en algunas funciones
- **Tokens defectuosos:** Pueden fallar silenciosamente
- **Seguridad:** Evita pérdida de fondos por transferencias fallidas

**Comparación:**
```solidity
// ❌ Transferencia directa - puede fallar silenciosamente
usdc.transfer(user, amount);

// ✅ SafeERC20 - revierte si hay cualquier problema
usdc.safeTransfer(user, amount);
```

### **1.4 Actividad Práctica: Planificación de Mejoras (10 minutos)**

**Completar Tabla en Grupos (7 minutos):** Los estudiantes trabajan en equipos de 3-4 personas para completar rápidamente:

| Limitación Identificada | Impacto en Usuarios | Solución Propuesta | Implementación Necesaria |
|---|---|---|---|
| Solo soporta ETH | No pueden usar stablecoins | Soporte multi-token | Mapping anidado + SafeERC20 |
| Cap basado en cantidad ETH | Valor fluctúa con precio | Cap basado en valor USD | Oráculos + conversión |
| Sin datos de precios | No conoce valor real | Integrar oráculos | Chainlink Price Feeds |
| Sin roles/permisos | No hay administración | Sistema de ownership | OpenZeppelin Ownable |

**Validación Rápida (3 minutos):** El instructor valida las respuestas con la clase y confirma que estas son exactamente las mejoras que implementaremos en la Parte 2.

---

## **PARTE 2: Implementación del KipuBankV2** 
*Duración: 2 horas*

### **Objetivos de Aprendizaje**
Al finalizar esta parte, los estudiantes serán capaces de:
- Implementar contratos con soporte multi-token
- Integrar oráculos de Chainlink
- Aplicar patrones de acceso y seguridad
- Utilizar bibliotecas de OpenZeppelin

### **2.1 Arquitectura del KipuBankV2 (30 minutos)**

#### **Nuevas Dependencias**
```solidity
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
```

#### **Cambios Estructurales Principales**

**1. Mapping Multi-Token**
```solidity
// Antes:
mapping(address user => uint256 amount) public s_vault;

// Después:
mapping(address user => mapping(address token => uint256 amount)) public s_vault;
```

**2. Variables de Oráculo**
```solidity
AggregatorV3Interface public s_feeds;
uint256 constant ORACLE_HEARTBEAT = 3600;
uint256 constant DECIMAL_FACTOR = 1 * 10 ** 20;
```

**3. Control de Acceso**
```solidity
contract KipuBankV2 is Ownable {
    // Hereda funcionalidades de control de acceso
}
```

### **2.2 Implementación Paso a Paso (60 minutos)**

#### **Paso 1: Constructor Mejorado (10 minutos)**
```solidity
constructor(uint256 _bankCap, address _feed, address _owner) 
    Ownable(_owner) {
    i_bankCap = _bankCap;
    s_feeds = AggregatorV3Interface(_feed);
}
```

**Diferencias clave:**
- Recibe dirección del price feed
- Establece owner para control de acceso
- `bankCap` ahora representa valor en USD

#### **Paso 2: Función de Oráculo (15 minutos)**
```solidity
function chainlinkFeed() internal view returns (uint256 ethUSDPrice_) {
    (, int256 ethUSDPrice,, uint256 updatedAt,) = s_feeds.latestRoundData();
    
    if (ethUSDPrice == 0) revert KipuBank_OracleCompromised();
    if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert KipuBank_StalePrice();
    
    ethUSDPrice_ = uint256(ethUSDPrice);
}
```

**Elementos de Seguridad:**
- Validación de precio > 0
- Verificación de frescura de datos
- Conversión segura int256 → uint256

#### **Paso 3: Conversión ETH a USD (10 minutos)**
```solidity
function convertEthInUSD(uint256 _ethAmount) internal view returns (uint256 convertedAmount_) {
    convertedAmount_ = (_ethAmount * chainlinkFeed()) / DECIMAL_FACTOR;
}
```

**Explicación Matemática:**
- ETH tiene 18 decimales
- Precio Chainlink tiene 8 decimales
- USDC tiene 6 decimales
- Factor de conversión: 10^20

#### **Paso 4: Función de Balance en USD (10 minutos)**
```solidity
function contractBalanceInUSD() public view returns (uint256 balance_) {
    uint256 convertedUSDAmount = convertEthInUSD(address(this).balance);
    balance_ = convertedUSDAmount + i_usdc.balanceOf(address(this));
}
```

#### **Paso 5: Depósitos Multi-Token (15 minutos)**

**Depósito ETH:**
```solidity
function depositEther() external payable bankCapCheck(ZERO) {
    s_depositsCounter = s_depositsCounter + 1;
    s_vault[msg.sender][address(0)] += msg.value;
    emit KipuBank_SuccessfullyDeposited(msg.sender, msg.value);
}
```

**Depósito USDC:**
```solidity
function depositUSDC(uint256 _usdcAmount) external bankCapCheck(_usdcAmount) {
    s_depositsCounter = s_depositsCounter + 1;
    s_vault[msg.sender][address(i_usdc)] += _usdcAmount;
    emit KipuBank_SuccessfullyDeposited(msg.sender, _usdcAmount);
    i_usdc.safeTransferFrom(msg.sender, address(this), _usdcAmount);
}
```

### **2.3 Características Avanzadas (30 minutos)**

#### **Modifier bankCapCheck**
```solidity
modifier bankCapCheck(uint256 _usdcAmount) {
    if (contractBalanceInUSD() + _usdcAmount > i_bankCap) {
        revert KipuBank_BankCapReached(i_bankCap);
    }
    _;
}
```

**Ventajas:**
- Cap basado en valor USD real
- Funciona tanto para ETH como USDC
- Se actualiza automáticamente con precios

#### **Función setFeeds (Solo Owner)**
```solidity
function setFeeds(address _feed) external onlyOwner {
    s_feeds = AggregatorV3Interface(_feed);
    emit KipuBank_ChainlinkFeedUpdated(_feed);
}
```

**Casos de Uso:**
- Actualización de feeds
- Migración a nuevas versiones
- Respuesta a emergencias

#### **SafeERC20 para Transferencias**
```solidity
// Uso de SafeERC20 en lugar de transfer directo
i_usdc.safeTransfer(msg.sender, _amount);
i_usdc.safeTransferFrom(msg.sender, address(this), _usdcAmount);
```

**Beneficios:**
- Manejo de tokens que no devuelven bool
- Verificación automática de éxito
- Compatibilidad con más tokens

### **2.4 Actividad Práctica Final (10 minutos)**

#### **Ejercicio: Comparación de Funcionalidades**

Los estudiantes completan una tabla comparativa:

| Característica | KipuBank Original | KipuBankV2 | Beneficio |
|---|---|---|---|
| Tokens Soportados | Solo ETH | ETH + USDC | Mayor flexibilidad |
| Cap del Banco | Basado en cantidad ETH | Basado en valor USD | Estabilidad de valor |
| Oráculos | No | Chainlink ETH/USD | Precios en tiempo real |
| Control de Acceso | No | Owner pattern | Administración segura |
| Transferencias ERC20 | No | SafeERC20 | Mayor compatibilidad |

#### **Preguntas de Reflexión**
1. ¿Qué otros tokens podrían integrarse fácilmente?
2. ¿Qué otros oráculos serían útiles?
3. ¿Qué funcionalidades adicionales proponen?

### **2.5 Ejercicio Práctico: Implementa una Función Nueva (30 minutos)**

#### **Desafío: Función `swapETHtoUSDC()` (25 minutos)**

**Objetivo:** Los estudiantes deben implementar una función que permita a los usuarios convertir su ETH depositado a USDC usando el oráculo de precios.

#### **Especificaciones del Ejercicio**
```solidity
/**
 * @notice Función para convertir ETH depositado a USDC
 * @param _ethAmount cantidad de ETH a convertir (en wei)
 * @dev El usuario debe tener suficiente ETH depositado
 * @dev El contrato debe tener suficiente USDC para la conversión
 * @dev Usar el precio del oráculo para la conversión
 */
function swapETHtoUSDC(uint256 _ethAmount) external {
    // Tu implementación aquí
}
```

#### **Pistas Progresivas**

**Pista 1: Validaciones necesarias**
```solidity
// ¿Qué validaciones necesitas?
// 1. El usuario tiene suficiente ETH depositado?
// 2. El contrato tiene suficiente USDC?
// 3. La cantidad es mayor que 0?
```

**Pista 2: Conversión de precios**
```solidity
// ¿Cómo convertir ETH a USDC?
// - Obtener precio ETH en USD usando chainlinkFeed()
// - Calcular: ethAmount * ethPrice / DECIMAL_FACTOR
// - Recordar: ETH tiene 18 decimales, USDC tiene 6 decimales
```

**Pista 3: Actualización de balances**
```solidity
// ¿Qué balances deben cambiar?
// - Reducir ETH del usuario: s_vault[msg.sender][address(0)]
// - Aumentar USDC del usuario: s_vault[msg.sender][address(i_usdc)]
```

**Pista 4: Consideraciones adicionales**
```solidity
// ¿Qué más necesitas?
// - Error personalizado para balance insuficiente
// - Error para USDC insuficiente en contrato
// - Evento para el swap realizado
// - Incrementar contador de operaciones?
```

#### **Template Base**
```solidity
// Errores adicionales necesarios
error KipuBank_InsufficientETHBalance(uint256 requested, uint256 available);
error KipuBank_InsufficientUSDCInContract(uint256 requested, uint256 available);

// Evento para el swap
event KipuBank_ETHSwappedToUSDC(address user, uint256 ethAmount, uint256 usdcAmount);

function swapETHtoUSDC(uint256 _ethAmount) external {
    // 1. Validaciones
    
    // 2. Cálculo de conversión
    
    // 3. Actualización de balances
    
    // 4. Emisión de evento
}
```

#### **Solución Completa (5 minutos)**

```solidity
// Errores adicionales
error KipuBank_InsufficientETHBalance(uint256 requested, uint256 available);
error KipuBank_InsufficientUSDCInContract(uint256 requested, uint256 available);
error KipuBank_InvalidAmount();

// Evento
event KipuBank_ETHSwappedToUSDC(address user, uint256 ethAmount, uint256 usdcAmount);

function swapETHtoUSDC(uint256 _ethAmount) external {
    // Validación 1: Cantidad válida
    if (_ethAmount == 0) revert KipuBank_InvalidAmount();
    
    // Validación 2: Usuario tiene suficiente ETH
    uint256 userETHBalance = s_vault[msg.sender][address(0)];
    if (_ethAmount > userETHBalance) {
        revert KipuBank_InsufficientETHBalance(_ethAmount, userETHBalance);
    }
    
    // Cálculo de conversión ETH → USDC
    uint256 ethPriceUSD = chainlinkFeed(); // Precio ETH en USD (8 decimales)
    uint256 usdcAmount = (_ethAmount * ethPriceUSD) / DECIMAL_FACTOR;
    
    // Validación 3: Contrato tiene suficiente USDC
    uint256 contractUSDCBalance = i_usdc.balanceOf(address(this));
    if (usdcAmount > contractUSDCBalance) {
        revert KipuBank_InsufficientUSDCInContract(usdcAmount, contractUSDCBalance);
    }
    
    // Actualización de balances
    s_vault[msg.sender][address(0)] -= _ethAmount;          // Reducir ETH
    s_vault[msg.sender][address(i_usdc)] += usdcAmount;     // Aumentar USDC
    
    // Emisión de evento
    emit KipuBank_ETHSwappedToUSDC(msg.sender, _ethAmount, usdcAmount);
}
```

#### **Puntos de Aprendizaje**
- **Validaciones múltiples:** Balance de usuario y contrato
- **Uso del oráculo:** Conversión de precios en tiempo real  
- **Manejo de decimales:** ETH (18) → USDC (6) via precio (8)
- **Gestión de estado:** Actualización de mappings anidados
- **Eventos informativos:** Tracking de operaciones
- **Errores descriptivos:** Debugging y UX mejorada

#### **Extensiones Opcionales**
Los estudiantes avanzados pueden implementar:
1. Función inversa `swapUSDCtoETH()`
2. Límites máximos de swap por transacción
3. Fee de conversión (ej: 0.1%)
4. Slippage protection

---

## **Recursos Adicionales**

### **Enlaces Útiles**
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [SafeERC20 Documentation](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20#SafeERC20)

### **Direcciones para Testing**
- ETH/USD Mainnet: `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`
- ETH/USD Sepolia: `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- USDC Mainnet: `0xA0b86a33E6441b8435b662f95e40c33BF26C0e33`

### **Homework/Proyecto Final**
Implementar una funcionalidad adicional:
1. Soporte para DAI como tercer token
2. Función de emergency pause
3. Límites de retiro por usuario
4. Sistema de rewards por depósitos

---

## **Evaluación**

### **Criterios de Evaluación**
- Comprensión de oráculos y price feeds (25%)
- Implementación de multi-token support (25%)
- Aplicación de patrones de seguridad (25%)
- Participación y preguntas durante la clase (25%)

### **Entregables**
1. Contrato KipuBankV2 completamente funcional
2. Tests básicos para las nuevas funcionalidades
3. Documento explicando las mejoras implementadas