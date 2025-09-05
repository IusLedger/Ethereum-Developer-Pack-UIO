# Guía del Profesor: Mejores Prácticas y Estándares en Solidity

## Objetivos de Aprendizaje
Al final de esta sesión, los estudiantes serán capaces de:
1. **Evaluar** la madurez y preparación de código para producción
2. **Aplicar** convenciones de nomenclatura y formato estándar
3. **Implementar** sistemas de transparencia con eventos
4. **Utilizar** bibliotecas confiables apropiadamente

---

## ESTRUCTURA DE LA CLASE (60 minutos)

### Parte 1: Madurez del Código y Auditorías (20 min)

#### 1.1 ¿Qué significa "código maduro"?
**Pregunta al grupo:** "¿Cuándo considerarían que su código está listo para manejar dinero real?"
**Respuestas esperadas:** Cuando está probado, documentado, revisado

**Explicación del concepto:**
```solidity
// CÓDIGO INMADURO: Sin documentación, sin tests
contract BadToken {
    mapping(address => uint) b;
    function t(address a, uint v) public { b[msg.sender] -= v; b[a] += v; }
}

// CÓDIGO MADURO: Documentado, probado, claro
/// @title ERC20 Token Implementation
/// @notice Standard token with transfer functionality
contract MatureToken {
    mapping(address => uint256) private balances;
    
    /// @notice Transfer tokens to another address
    /// @param recipient The address receiving tokens
    /// @param amount The amount of tokens to transfer
    function transfer(address recipient, uint256 amount) public {
        // Implementación completa con validaciones
    }
}
```

#### 1.2 La importancia de las auditorías
**Pregunta crítica:** "¿Confiarían $1M a código que solo ustedes han revisado?"
**Respuesta:** Probablemente no

**Casos reales para impacto:**
- "The DAO hack: $60M perdidos por bug no detectado"
- "Poly Network: $600M robados por vulnerability en cross-chain"

**Demostración de análisis de riesgos:**
```solidity
// PREGUNTA: ¿Qué puede salir mal aquí?
function emergencyWithdraw() public onlyOwner {
    payable(owner).transfer(address(this).balance);
}

// ANÁLISIS DE RIESGOS:
// 1. ¿Y si owner es una EOA y pierde la clave?
// 2. ¿Y si owner es malicioso?
// 3. ¿Y si hay un bug en la función transfer?
```

**Pregunta reflexiva:** "¿Qué otras situaciones peligrosas pueden imaginar?"

#### 1.3 Revisiones de código efectivas
**Pregunta práctica:** "¿Cómo explicarían esta función a su abuela?"
```solidity
function complexOperation(uint256 x) public {
    // Si no puedes explicarlo simple, probablemente esté mal diseñado
}
```

**Técnica de revisión:**
1. **Revisión técnica:** Desarrolladores buscan bugs
2. **Revisión de negocio:** No-técnicos verifican lógica
3. **Revisión de seguridad:** Especialistas buscan vulnerabilidades

---

### Parte 2: Bibliotecas Confiables (10 min)

#### 2.1 ¿Por qué usar bibliotecas?
**Pregunta:** "¿Implementarían su propio sistema de frenos para un auto?"
**Respuesta:** No, usarías partes probadas y certificadas

**Demostración práctica:**
```solidity
// MAL: Reinventar la rueda
contract MyToken {
    mapping(address => uint256) balances;
    
    function transfer(address to, uint256 amount) public {
        // 50 líneas de código custom que puede tener bugs
    }
}

// BIEN: Usar OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        // Funcionalidad probada por miles de proyectos
    }
}
```

**Pregunta:** "¿Qué bibliotecas conocen que sean confiables?"
**Respuestas esperadas:** OpenZeppelin, Chainlink, Uniswap

#### 2.2 Cuándo NO usar bibliotecas
**Pregunta reflexiva:** "¿Siempre deberíamos usar bibliotecas?"
**Respuesta:** No siempre

**Casos donde crear código propio:**
- Funcionalidad muy específica del negocio
- Optimizaciones de gas críticas
- Cuando la biblioteca es demasiado pesada

---

### Parte 3: Transparencia con Eventos (15 min)

#### 3.1 ¿Por qué son importantes los eventos?
**Pregunta:** "¿Cómo saben los usuarios qué está pasando en el contrato?"
**Respuesta:** A través de eventos

**Demostración de transparencia:**
```solidity
// SIN EVENTOS: Caja negra
function transfer(address to, uint256 amount) public {
    balances[msg.sender] -= amount;
    balances[to] += amount;
    // ¿Cómo sabe el usuario que funcionó?
}

// CON EVENTOS: Transparencia total
function transfer(address to, uint256 amount) public {
    balances[msg.sender] -= amount;
    balances[to] += amount;
    
    emit Transfer(msg.sender, to, amount); // ¡Visible para todos!
}
```

#### 3.2 Diseño de eventos efectivos
**Pregunta:** "¿Qué información debería incluir un evento?"
**Respuestas esperadas:** Who, what, when, how much

**Mejores prácticas:**
```solidity
// BIEN: Información completa
event Transfer(
    address indexed from,    // indexed para filtrar
    address indexed to,      // indexed para filtrar  
    uint256 amount          // no indexed para datos
);

// MAL: Información insuficiente
event Something(uint256 value); // ¿Qué? ¿Quién? ¿Cuándo?
```

**Actividad práctica:** Mostrar diferentes eventos y que identifiquen problemas

---

### Parte 4: Convenciones de Nomenclatura (15 min)

#### 4.1 La importancia de nombres consistentes
**Pregunta:** "¿Preferirían leer un libro en español mezclado con chino?"
**Respuesta:** Por supuesto que no

**Demostración de inconsistencia:**
```solidity
// INCONSISTENTE: Pesadilla de mantenimiento
contract badContract {
    uint256 public TotalSupply;
    address private owner_address;
    bool public Is_Paused;
    mapping(address => uint256) user_balance;
    
    function GetBalance(address usr) public view returns (uint256) { }
    function setOwner(address NewOwner) public { }
}
```

#### 4.2 Estándar de nomenclatura Solidity
**Explicación sistemática:**

**Variables y funciones: camelCase**
```solidity
uint256 public totalSupply;        // ✅
address private contractOwner;     // ✅
function getUserBalance() public   // ✅
```

**Constantes: UPPER_SNAKE_CASE**
```solidity
uint256 public constant MAX_SUPPLY = 1000000;    // ✅
address public constant DEAD_ADDRESS = 0x...;   // ✅
```

**Prefijos útiles:**
```solidity
// Storage variables
uint256 private s_totalSupply;
mapping(address => uint256) private s_balances;

// Immutable variables  
address private immutable i_owner;
uint256 private immutable i_decimals;

// Function parameters
function transfer(address _recipient, uint256 _amount) public {
    // El _ ayuda a distinguir parámetros de variables locales
}

// Boolean variables
bool private s_isPaused;      // ✅
bool private s_hasAccess;     // ✅
bool private s_canTransfer;   // ✅
```

#### 4.3 Formato y estructura
**Demostración de buena estructura:**
```solidity
contract WellFormattedContract {
    // ================================
    // STATE VARIABLES
    // ================================
    
    uint256 private s_totalSupply;
    address private immutable i_owner;
    
    // ================================
    // EVENTS
    // ================================
    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    // ================================
    // MODIFIERS  
    // ================================
    
    modifier onlyOwner() {
        require(msg.sender == i_owner, "Not owner");
        _;
    }
    
    // ================================
    // FUNCTIONS
    // ================================
    
    function transfer(address _recipient, uint256 _amount) 
        public 
        returns (bool success) 
    {
        // Líneas limitadas a ~80 caracteres
        require(_recipient != address(0), "Invalid recipient");
        require(_amount <= s_balances[msg.sender], "Insufficient balance");
        
        // Espacios en blanco para separar lógica
        s_balances[msg.sender] -= _amount;
        s_balances[_recipient] += _amount;
        
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }
}
```

**Pregunta:** "¿Qué diferencias notan comparado con código mal formateado?"
**Respuesta:** Más fácil de leer, entender y mantener

---

## TÉCNICAS PEDAGÓGICAS

### Comparación Visual
Siempre mostrar código "antes" (malo) y "después" (bueno) lado a lado para que vean la diferencia inmediatamente.

### Analogías Efectivas
- **Código maduro = Casa lista para vivir:** Todas las instalaciones probadas
- **Bibliotecas = Partes de auto:** No reinventes frenos o airbags
- **Eventos = Recibos:** Prueba de que algo ocurrió
- **Nomenclatura = Idioma común:** Todos deben hablar igual

### Preguntas Progresivas
1. **Identificación:** "¿Qué problemas ven aquí?"
2. **Comprensión:** "¿Por qué esto es problemático?"
3. **Aplicación:** "¿Cómo lo mejorarían?"
4. **Síntesis:** "¿Qué principio general aplicamos?"

---

## PUNTOS CLAVE PARA ENFATIZAR

### Madurez del Código
- "Código que funciona ≠ Código listo para producción"
- "La auditoría no es opcional para dinero real"
- "Ojos externos ven bugs que tú no ves"

### Bibliotecas
- "No reinventes lo que ya funciona bien"
- "OpenZeppelin es tu mejor amigo"
- "Pero conoce cuándo crear código propio"

### Transparencia
- "Los eventos son ventanas a tu contrato"
- "Los usuarios merecen saber qué está pasando"
- "Transparencia genera confianza"

### Nomenclatura
- "Consistencia > Preferencias personales"
- "Tu 'yo futuro' te agradecerá nombres claros"
- "El equipo debe hablar el mismo idioma"

---

## VERIFICACIÓN DE COMPRENSIÓN

### Preguntas Rápidas
1. **"¿Este código está listo para mainnet?"** (Mostrar código sin tests)
   - Respuesta: No

2. **"¿Usarían una biblioteca para generar números aleatorios?"**
   - Respuesta: Sí, Chainlink VRF

3. **"¿Qué falta en esta función?"** (Mostrar función sin eventos)
   - Respuesta: Eventos para transparencia

### Señales de Éxito
- Estudiantes critican código por falta de documentación
- Preguntan sobre bibliotecas disponibles
- Proponen eventos para nuevas funciones
- Corrigen nomenclatura inconsistente automáticamente

### Intervenciones
**Si subestiman auditorías:**
- Mostrar casos reales de hacks causados por bugs simples
- Calcular costo de auditoría vs pérdidas potenciales

**Si resisten convenciones:**
- Explicar que es como reglas de tránsito: todos deben seguirlas
- Mostrar código de equipos reales que sigue estándares

---

## EXTENSIONES PARA CLASES FUTURAS

### Nivel Avanzado
- Herramientas de análisis automático (Slither, MythX)
- Procesos de CI/CD para contratos
- Metodologías de testing formal

### Casos Prácticos
- Análisis de contratos de protocolos famosos
- Simulacro de auditoría en grupo
- Revisión de código en vivo

**Esta guía te ayudará a enseñar prácticas profesionales que los estudiantes aplicarán en proyectos reales de producción.**