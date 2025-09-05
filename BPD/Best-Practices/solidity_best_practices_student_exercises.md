# Ejercicios de Mejores Prácticas en Solidity

## Objetivo
Aprender a aplicar estándares profesionales, usar bibliotecas confiables, implementar transparencia y seguir convenciones de nomenclatura.

---

## EJERCICIO 1: Evaluación de Madurez del Código

### Objetivo
Identificar qué hace que código esté listo (o no) para producción.

### Contexto
Tu equipo está a punto de lanzar este token que manejará $500,000. Tu jefe pregunta: "¿Está listo para mainnet?"

### Código Base - Token para Evaluar
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Token {
    mapping(address => uint) balances;
    uint total;
    address owner;
    
    constructor() {
        owner = msg.sender;
        total = 1000000;
        balances[owner] = total;
    }
    
    function transfer(address to, uint amount) public {
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
    
    function mint(uint amount) public {
        require(msg.sender == owner);
        balances[owner] += amount;
        total += amount;
    }
    
    function burn(uint amount) public {
        balances[msg.sender] -= amount;
        total -= amount;
    }
    
    function getBalance(address user) public view returns (uint) {
        return balances[user];
    }
}
```

### Tu Tarea (15 minutos máximo)
Identifica **5 problemas críticos** que hacen este código NO apto para producción:

```
PROBLEMA 1: [Describe el problema específico]
RIESGO: [Qué puede salir mal exactamente]

PROBLEMA 2: [Describe el problema específico]  
RIESGO: [Qué puede salir mal exactamente]

PROBLEMA 3: [Describe el problema específico]
RIESGO: [Qué puede salir mal exactamente]

PROBLEMA 4: [Describe el problema específico]
RIESGO: [Qué puede salir mal exactamente]

PROBLEMA 5: [Describe el problema específico]
RIESGO: [Qué puede salir mal exactamente]
```

### Pistas Específicas para Buscar

#### Pista 1: Función transfer()
```solidity
function transfer(address to, uint amount) public {
    balances[msg.sender] -= amount;  // ¿Qué pasa si amount > balance?
    balances[to] += amount;          // ¿Qué pasa si to = address(0)?
}
```
**Busca:** Validaciones faltantes, posible underflow, transferencias a dirección inválida

#### Pista 2: Función burn()
```solidity
function burn(uint amount) public {
    balances[msg.sender] -= amount;  // ¿Verificaste el balance primero?
    total -= amount;
}
```
**Busca:** Sin verificar si el usuario tiene suficientes tokens

#### Pista 3: Documentación
```solidity
contract Token {  // ¿Qué hace este contrato? ¿Cómo usarlo?
```
**Busca:** Falta documentación NatSpec, comentarios explicativos

#### Pista 4: Eventos
```solidity
function transfer(address to, uint amount) public {
    // Cambio de estado pero... ¿cómo rastrear?
}
```
**Busca:** Sin eventos para tracking de operaciones

#### Pista 5: Tipos de datos
```solidity
uint total;  // ¿uint8? ¿uint256? ¿Inconsistencia?
```
**Busca:** Tipos sin especificar tamaño

### Pregunta Final
**¿Recomendarías lanzar este token a mainnet?** [SÍ/NO]
**¿Por qué?** [Explica en 1-2 líneas]

---

## EJERCICIO 2: Uso de Bibliotecas Confiables

### Objetivo
Transformar código inseguro usando bibliotecas probadas como OpenZeppelin.

### Contexto
Un desarrollador junior escribió este código para manejar roles de administrador. Necesitas mejorarlo usando bibliotecas estándar.

### Código Base - Sistema de Roles Casero
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CustomAccessControl {
    mapping(address => bool) public admins;
    mapping(address => bool) public moderators;
    address public superAdmin;
    
    constructor() {
        superAdmin = msg.sender;
        admins[msg.sender] = true;
    }
    
    function addAdmin(address user) public {
        require(msg.sender == superAdmin, "Only super admin");
        admins[user] = true;
    }
    
    function removeAdmin(address user) public {
        require(msg.sender == superAdmin, "Only super admin");
        admins[user] = false;
    }
    
    function addModerator(address user) public {
        require(admins[msg.sender], "Only admin");
        moderators[user] = true;
    }
    
    function removeModerator(address user) public {
        require(admins[msg.sender], "Only admin");
        moderators[user] = false;
    }
    
    function sensitiveFunction() public {
        require(admins[msg.sender], "Only admin");
        // Lógica importante
    }
    
    function moderateFunction() public {
        require(moderators[msg.sender] || admins[msg.sender], "Only moderator or admin");
        // Lógica de moderación
    }
}
```

### Tu Tarea (15 minutos máximo)
Reescribir usando OpenZeppelin AccessControl

### Pistas Específicas

#### Pista 1: Importar OpenZeppelin
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// TODO: Agregar esta línea
import "@openzeppelin/contracts/access/AccessControl.sol";

// TODO: Heredar de AccessControl
contract ImprovedAccessControl is AccessControl {
```

#### Pista 2: Definir roles
```solidity
contract ImprovedAccessControl is AccessControl {
    // TODO: Definir roles usando keccak256
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
```

#### Pista 3: Constructor con OpenZeppelin
```solidity
constructor() {
    // TODO: Otorgar rol de admin por defecto al deployer
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    
    // TODO: Otorgar rol ADMIN_ROLE al deployer
    _grantRole(ADMIN_ROLE, msg.sender);
    
    // TODO: Configurar jerarquía: ADMIN puede gestionar MODERATOR
    _setRoleAdmin(MODERATOR_ROLE, ADMIN_ROLE);
}
```

#### Pista 4: Funciones de gestión de roles
```solidity
function addAdmin(address user) public {
    // TODO: Usar grantRole en lugar de mapping manual
    // require(___, "Only default admin");
    // grantRole(___, ___);
}

function addModerator(address user) public {
    // TODO: Solo ADMIN_ROLE puede agregar moderadores
    // require(___, "Only admin");
    // grantRole(___, ___);
}
```

#### Pista 5: Funciones protegidas
```solidity
function sensitiveFunction() public {
    // TODO: Usar onlyRole modifier de OpenZeppelin
    // ¿Cómo verificar que msg.sender tiene ADMIN_ROLE?
}

function moderateFunction() public {
    // TODO: Verificar MODERATOR_ROLE o ADMIN_ROLE
    // require(hasRole(___, ___) || hasRole(___, ___), "___");
}
```

### Preguntas de Reflexión
1. **¿Qué ventajas tiene usar OpenZeppelin vs código propio?**
2. **¿En qué casos SÍ escribirías código de acceso personalizado?**
3. **¿Qué otras bibliotecas de OpenZeppelin conoces?**

---

## EJERCICIO 3: Implementar Transparencia con Eventos

### Objetivo
Agregar eventos apropiados para hacer el contrato transparente y auditable.

### Contexto
Este contrato de votación funciona, pero los usuarios no pueden rastrear qué está pasando. Necesitas agregar eventos para transparencia total.

### Código Base - Voting Sin Transparencia
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SilentVoting {
    mapping(address => bool) public hasVoted;
    mapping(bytes32 => uint256) public voteCount;
    mapping(bytes32 => bool) public validProposals;
    address public admin;
    bool public votingOpen;
    
    constructor() {
        admin = msg.sender;
        votingOpen = false;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }
    
    function createProposal(bytes32 proposalId) public onlyAdmin {
        require(!validProposals[proposalId], "Proposal exists");
        validProposals[proposalId] = true;
    }
    
    function openVoting() public onlyAdmin {
        require(!votingOpen, "Voting already open");
        votingOpen = true;
    }
    
    function closeVoting() public onlyAdmin {
        require(votingOpen, "Voting already closed");
        votingOpen = false;
    }
    
    function vote(bytes32 proposalId) public {
        require(votingOpen, "Voting is closed");
        require(validProposals[proposalId], "Invalid proposal");
        require(!hasVoted[msg.sender], "Already voted");
        
        hasVoted[msg.sender] = true;
        voteCount[proposalId]++;
    }
    
    function getResults(bytes32 proposalId) public view returns (uint256) {
        return voteCount[proposalId];
    }
}
```

### Tu Tarea (15 minutos máximo)
Agregar eventos apropiados para cada acción importante

### Pistas Específicas

#### Pista 1: Definir eventos
```solidity
contract TransparentVoting {
    // TODO: Evento para cuando se crea propuesta
    event ProposalCreated(
        bytes32 indexed proposalId,  // indexed para filtrar
        address indexed creator,     // quién la creó
        uint256 timestamp           // cuándo
    );
    
    // TODO: Evento para abrir votación
    event VotingOpened(/* ¿qué parámetros necesitas? */);
    
    // TODO: Evento para cerrar votación
    event VotingClosed(/* ¿qué parámetros necesitas? */);
    
    // TODO: Evento para voto individual
    event VoteCast(/* ¿qué parámetros necesitas? */);
```

#### Pista 2: Emitir en createProposal()
```solidity
function createProposal(bytes32 proposalId) public onlyAdmin {
    require(!validProposals[proposalId], "Proposal exists");
    validProposals[proposalId] = true;
    
    // TODO: Emitir evento aquí
    emit ProposalCreated(proposalId, msg.sender, block.timestamp);
}
```

#### Pista 3: Emitir en openVoting()
```solidity
function openVoting() public onlyAdmin {
    require(!votingOpen, "Voting already open");
    votingOpen = true;
    
    // TODO: ¿Qué información incluir en el evento?
    emit VotingOpened(/* parámetros aquí */);
}
```

#### Pista 4: Emitir en vote()
```solidity
function vote(bytes32 proposalId) public {
    require(votingOpen, "Voting is closed");
    require(validProposals[proposalId], "Invalid proposal");
    require(!hasVoted[msg.sender], "Already voted");
    
    hasVoted[msg.sender] = true;
    voteCount[proposalId]++;
    
    // TODO: Emitir evento con información completa
    emit VoteCast(
        proposalId,
        msg.sender,              // ¿incluir votante?
        block.timestamp,
        voteCount[proposalId]    // total actual
    );
}
```

#### Pista 5: Campos indexed vs no-indexed
```solidity
// Regla: Máximo 3 campos indexed por evento
event VoteCast(
    bytes32 indexed proposalId,  // Para filtrar por propuesta
    address indexed voter,       // Para filtrar por votante
    uint256 timestamp,          // No indexed (data)
    uint256 newTotal           // No indexed (data)
);
```

### Pregunta de Diseño
**¿Deberías incluir la dirección del votante en el evento VoteCast?**
- **Opción A:** Sí, para transparencia total
- **Opción B:** No, para mantener privacidad

**Tu decisión:** [A/B] - **¿Por qué?** [Explica tu razonamiento]

---

## EJERCICIO 4: Aplicar Convenciones de Nomenclatura

### Objetivo
Refactorizar código con nomenclatura inconsistente siguiendo estándares de Solidity.

### Contexto
Heredaste este código de un desarrollador que no siguió convenciones. Los nuevos miembros del equipo se confunden con los nombres inconsistentes.

### Código Base - Nomenclatura Inconsistente
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract bad_naming_example {
    uint256 public Total_Supply;
    address private Owner_Address;
    bool public Is_Paused_Status;
    mapping(address => uint256) UserBalanceMapping;
    uint256 constant max_tokens_per_user = 10000;
    address constant NULL_ADDRESS = address(0);
    
    uint256 private current_supply;
    bool private contract_initialized;
    
    event token_transfer(address FROM, address TO, uint256 AMOUNT);
    event ownership_change(address old_owner, address new_owner);
    
    modifier Only_Owner() {
        require(msg.sender == Owner_Address, "not owner");
        _;
    }
    
    modifier Not_Paused() {
        require(!Is_Paused_Status, "contract paused");
        _;
    }
    
    constructor(uint256 Initial_Supply) {
        Owner_Address = msg.sender;
        Total_Supply = Initial_Supply;
        current_supply = 0;
        contract_initialized = true;
        UserBalanceMapping[msg.sender] = Initial_Supply;
    }
    
    function Transfer_Tokens(address receiver_address, uint256 transfer_amount) 
        public 
        Not_Paused 
        returns (bool success_status) 
    {
        require(UserBalanceMapping[msg.sender] >= transfer_amount, "insufficient balance");
        require(receiver_address != NULL_ADDRESS, "invalid address");
        
        UserBalanceMapping[msg.sender] -= transfer_amount;
        UserBalanceMapping[receiver_address] += transfer_amount;
        
        emit token_transfer(msg.sender, receiver_address, transfer_amount);
        return true;
    }
    
    function Change_Owner(address New_Owner_Address) public Only_Owner {
        require(New_Owner_Address != NULL_ADDRESS, "invalid address");
        address previous_owner = Owner_Address;
        Owner_Address = New_Owner_Address;
        emit ownership_change(previous_owner, New_Owner_Address);
    }
    
    function Get_User_Balance(address user_address) public view returns (uint256 user_balance) {
        return UserBalanceMapping[user_address];
    }
    
    function Toggle_Pause_Status() public Only_Owner {
        Is_Paused_Status = !Is_Paused_Status;
    }
}
```

### Tu Tarea (20 minutos máximo)
Refactorizar TODO el código siguiendo convenciones estándar

### Pistas Específicas de Nomenclatura

#### Pista 1: Nombre del contrato
```solidity
// ANTES: bad_naming_example
// DESPUÉS: ¿Cómo debería llamarse en PascalCase?
contract CleanNamingExample {
```

#### Pista 2: Variables de estado
```solidity
// ANTES: uint256 public Total_Supply;
// DESPUÉS: Variables de estado usan camelCase con prefijo s_
uint256 public s_totalSupply;

// ANTES: address private Owner_Address;
// DESPUÉS: 
address private s_ownerAddress;

// ANTES: bool public Is_Paused_Status;
// DESPUÉS: Booleans usan prefijo is/has
bool public s_isPaused;

// ANTES: mapping(address => uint256) UserBalanceMapping;
// DESPUÉS:
mapping(address => uint256) private s_userBalances;
```

#### Pista 3: Constantes
```solidity
// ANTES: uint256 constant max_tokens_per_user = 10000;
// DESPUÉS: Constantes en UPPER_SNAKE_CASE
uint256 public constant MAX_TOKENS_PER_USER = 10000;

// ANTES: address constant NULL_ADDRESS = address(0);
// DESPUÉS: Ya está bien (UPPER_SNAKE_CASE)
address public constant NULL_ADDRESS = address(0);
```

#### Pista 4: Eventos
```solidity
// ANTES: event token_transfer(address FROM, address TO, uint256 AMOUNT);
// DESPUÉS: Eventos en PascalCase, parámetros en camelCase
event TokenTransfer(address indexed from, address indexed to, uint256 amount);

// ANTES: event ownership_change(address old_owner, address new_owner);
// DESPUÉS:
event OwnershipChange(address indexed oldOwner, address indexed newOwner);
```

#### Pista 5: Modifiers
```solidity
// ANTES: modifier Only_Owner() {
// DESPUÉS: Modifiers en camelCase
modifier onlyOwner() {
    require(msg.sender == s_ownerAddress, "Not the owner");
    _;
}

// ANTES: modifier Not_Paused() {
// DESPUÉS:
modifier whenNotPaused() {
    require(!s_isPaused, "Contract is paused");
    _;
}
```

#### Pista 6: Funciones
```solidity
// ANTES: function Transfer_Tokens(address receiver_address, uint256 transfer_amount)
// DESPUÉS: Funciones en camelCase, parámetros con prefijo _
function transferTokens(address _receiverAddress, uint256 _transferAmount) 
    public 
    whenNotPaused 
    returns (bool success) 
{
    // Implementación...
}

// ANTES: function Get_User_Balance(address user_address)
// DESPUÉS:
function getUserBalance(address _userAddress) public view returns (uint256 balance) {
    return s_userBalances[_userAddress];
}
```

#### Pista 7: Estructura y espaciado
```solidity
contract CleanNamingExample {
    
    // ================================
    // STATE VARIABLES
    // ================================
    
    uint256 public s_totalSupply;
    address private s_ownerAddress;
    bool public s_isPaused;
    
    // ================================
    // CONSTANTS
    // ================================
    
    uint256 public constant MAX_TOKENS_PER_USER = 10000;
    
    // ================================
    // EVENTS
    // ================================
    
    event TokenTransfer(address indexed from, address indexed to, uint256 amount);
    
    // ================================
    // MODIFIERS
    // ================================
    
    modifier onlyOwner() {
        require(msg.sender == s_ownerAddress, "Not the owner");
        _;
    }
    
    // ================================
    // CONSTRUCTOR
    // ================================
    
    constructor(uint256 _initialSupply) {
        // Implementación...
    }
    
    // ================================
    // FUNCTIONS
    // ================================
    
    // Funciones públicas aquí...
    
    // ================================
    // VIEW FUNCTIONS
    // ================================
    
    // Funciones view al final...
}
```

### Checklist de Nomenclatura
- [ ] Contrato: PascalCase
- [ ] Variables de estado: camelCase con prefijos (s_, i_)
- [ ] Constantes: UPPER_SNAKE_CASE
- [ ] Funciones: camelCase
- [ ] Parámetros: camelCase con _ prefix
- [ ] Modifiers: camelCase
- [ ] Eventos: PascalCase
- [ ] Booleans: is/has prefix
- [ ] Estructura clara con secciones comentadas
- [ ] Espaciado consistente

---

## REFLEXIÓN FINAL

### Preguntas para Considerar
1. **Madurez:** ¿Qué otros aspectos harían código "production-ready"?
2. **Bibliotecas:** ¿Cuándo es apropiado reinventar vs usar bibliotecas?
3. **Transparencia:** ¿Demasiados eventos pueden ser problemáticos?
4. **Nomenclatura:** ¿Por qué la consistencia es más importante que preferencias personales?

### Puntos Clave para Recordar
- **Madurez:** Funcionar ≠ Estar listo para producción
- **Bibliotecas:** OpenZeppelin es tu mejor amigo para código estándar
- **Eventos:** Son ventanas que muestran qué hace tu contrato
- **Nomenclatura:** Consistencia facilita colaboración en equipo

### Próximos Pasos
- Estudiar contratos de protocolos famosos (Uniswap, AAVE)
- Familiarizarse con toda la suite de OpenZeppelin
- Practicar análisis de madurez con contratos reales
- Establecer guías de estilo para tu equipo