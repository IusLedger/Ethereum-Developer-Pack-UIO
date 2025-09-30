# Documentación - Configuración de DApp con Ethers.js

## 📋 Requisitos Previos

- **Node.js y npm** instalados
- **MetaMask** instalado en el navegador
- Editor de código (VS Code recomendado)

## 🚀 Configuración Inicial del Proyecto

### 1. Crear la estructura del proyecto

```bash
# Crear carpeta del proyecto
mkdir mi-dapp-ethers
cd mi-dapp-ethers

# Inicializar npm
npm init -y
```

### 2. Instalar Ethers.js

```bash
npm install --save ethers
```

Esto instalará Ethers.js v6 (última versión) en la carpeta `node_modules`.

### 3. Configurar package.json

Asegúrate de que tu `package.json` incluya `"type": "module"`:

```json
{
  "name": "mi-dapp-ethers",
  "version": "1.0.0",
  "description": "DApp simple con Ethers.js",
  "type": "module",
  "main": "index.js",
  "scripts": {
    "dev": "http-server -p 8000"
  },
  "dependencies": {
    "ethers": "^6.15.0"
  }
}
```

## 📁 Estructura de Archivos

```
mi-dapp-ethers/
├── node_modules/
├── index.html
├── package.json
└── package-lock.json
```

## 💻 Código del Proyecto

### index.html - Código Completo de la DApp

A continuación se presenta el código completo y funcional de la aplicación:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethers.js DApp</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 50px auto;
        padding: 20px;
      }
      .section {
        margin: 20px 0;
        padding: 15px;
        border: 1px solid #ddd;
        border-radius: 5px;
      }
      button {
        background-color: #4CAF50;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        margin: 5px;
        font-size: 14px;
      }
      button:hover {
        background-color: #45a049;
      }
      #disconnectBtn {
        background-color: #f44336;
      }
      #disconnectBtn:hover {
        background-color: #da190b;
      }
      #revokeBtn {
        background-color: #ff6b6b;
      }
      #revokeBtn:hover {
        background-color: #ff5252;
      }
      input {
        padding: 8px;
        margin: 5px;
        width: 400px;
        border: 1px solid #ddd;
        border-radius: 4px;
      }
      .result {
        margin-top: 10px;
        padding: 10px;
        background-color: #f0f0f0;
        border-radius: 4px;
        font-family: monospace;
        white-space: pre-wrap;
        word-break: break-all;
      }
    </style>
  </head>
  <body>
    <h1>Ethers.js DApp - Blockchain Explorer</h1>

    <!-- Conexión de Wallet -->
    <div class="section">
      <h2>🔗 Wallet Connection</h2>
      <div id="wallet">Connecting...</div>
      <div id="network" class="result" style="margin: 10px 0;"></div>
      <div style="margin-top: 10px;">
        <button id="disconnectBtn" onclick="disconnectWallet()" style="display: none;">
          🔌 Disconnect from App
        </button>
        <button id="revokeBtn" onclick="revokePermissions()" style="display: none;">
          🚫 Revoke MetaMask Permissions
        </button>
      </div>
    </div>

    <!-- Consulta de Blockchain -->
    <div class="section">
      <h2>🔍 Blockchain Query</h2>
      <button onclick="getCurrentBlock()">Get Current Block Number</button>
      <div id="blockResult" class="result"></div>
    </div>

    <!-- Consulta de Balance -->
    <div class="section">
      <h2>💰 ETH Balance Query</h2>
      <input type="text" id="addressInput" placeholder="Enter Ethereum address (0x...)">
      <button onclick="getBalance()">Get Balance</button>
      <div id="balanceResult" class="result"></div>
    </div>

    <!-- Saldo de USDC -->
    <div class="section">
      <h2>💵 USDC Balance</h2>
      <button onclick="getUSDCBalance()">Get My USDC Balance</button>
      <div id="usdcBalanceResult" class="result"></div>
    </div>

    <!-- Transferir USDC -->
    <div class="section">
      <h2>💸 Transfer USDC</h2>
      <input type="text" id="receiverAddress" placeholder="Receiver address (0x...)">
      <input type="number" id="usdcAmount" placeholder="Amount (e.g., 10.5)" step="0.000001">
      <button onclick="transferUSDC()">Transfer USDC</button>
      <div id="transferResponse" class="result" style="display: none;"></div>
    </div>

    <!-- Firmar Mensaje -->
    <div class="section">
      <h2>✍️ Sign Message</h2>
      <input type="text" id="messageInput" placeholder="Enter message to sign">
      <button onclick="signMessage()">Sign Message</button>
      <div id="signatureResult" class="result"></div>
    </div>

    <script type="module">
      import { ethers } from './node_modules/ethers/dist/ethers.js';

      // USDC Contract Configuration
      const usdcAddresses = {
        '1': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',        // Mainnet
        '11155111': '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238', // Sepolia
        '5': '0x07865c6E87B9F70255377e024ace6630C1Eaa37F'         // Goerli
      };

      const usdcABI = [
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function decimals() view returns (uint8)",
        "function balanceOf(address _owner) public view returns (uint256 balance)",
        "function transfer(address _to, uint256 _value) public returns (bool success)",
      ];

      // Variables globales
      let provider;
      let signer;
      let userAddress;

      // Inicialización
      (async function () {
        if (!window.ethereum) {
          document.getElementById("wallet").innerText = "❌ Please install MetaMask!";
          return;
        }

        provider = new ethers.BrowserProvider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = await provider.getSigner();
        
        userAddress = await signer.getAddress();
        document.getElementById("wallet").innerText = "✅ Connected: " + userAddress;

        const network = await provider.getNetwork();
        console.log("Network Info:", network);
        console.log("Chain ID:", network.chainId);
        
        const networkNames = {
          '1': 'Ethereum Mainnet',
          '11155111': 'Sepolia Testnet',
          '5': 'Goerli Testnet',
          '137': 'Polygon Mainnet'
        };
        
        const displayName = networkNames[network.chainId.toString()] || network.name;
        document.getElementById("network").innerText = 
          `🌐 Network: ${displayName} (Chain ID: ${network.chainId})`;

        document.getElementById("disconnectBtn").style.display = "inline-block";
        document.getElementById("revokeBtn").style.display = "inline-block";

        window.getCurrentBlock = getCurrentBlock;
        window.getBalance = getBalance;
        window.signMessage = signMessage;
        window.disconnectWallet = disconnectWallet;
        window.revokePermissions = revokePermissions;
        window.getUSDCBalance = getUSDCBalance;
        window.transferUSDC = transferUSDC;
        window.provider = provider;
        window.signer = signer;
        window.ethers = ethers;
      })();

      async function getCurrentBlock() {
        try {
          let currentBlock = await provider.getBlockNumber();
          console.log("Current block:", currentBlock);
          document.getElementById("blockResult").innerText = 
            `Current Block Number: ${currentBlock}`;
        } catch (error) {
          console.error("Error getting block:", error);
          document.getElementById("blockResult").innerText = 
            `Error: ${error.message}`;
        }
      }

      async function getBalance() {
        try {
          let address = document.getElementById("addressInput").value;
          
          if (!address) {
            address = userAddress;
            console.log("No address provided, using connected wallet:", address);
          }

          if (!ethers.isAddress(address)) {
            document.getElementById("balanceResult").innerText = 
              "Invalid Ethereum address";
            return;
          }

          console.log("Querying balance for:", address);
          let balance = await provider.getBalance(address);
          console.log("Balance in Wei:", balance.toString());
          
          let balanceInEth = ethers.formatEther(balance);
          console.log("Balance in ETH:", balanceInEth);
          
          const network = await provider.getNetwork();
          
          document.getElementById("balanceResult").innerText = 
            `Address: ${address}\nBalance: ${balanceInEth} ETH\nNetwork: ${network.name} (Chain ID: ${network.chainId})`;
        } catch (error) {
          console.error("Error getting balance:", error);
          document.getElementById("balanceResult").innerText = 
            `Error: ${error.message}`;
        }
      }

      async function signMessage() {
        try {
          let message = document.getElementById("messageInput").value;
          
          if (!message) {
            document.getElementById("signatureResult").innerText = 
              "Please enter a message to sign";
            return;
          }

          let signature = await signer.signMessage(message);
          
          console.log("Message:", message);
          console.log("Signature:", signature);
          
          document.getElementById("signatureResult").innerText = 
            `Message: "${message}"\n\nSignature:\n${signature}`;
        } catch (error) {
          console.error("Error signing message:", error);
          document.getElementById("signatureResult").innerText = 
            `Error: ${error.message}`;
        }
      }

      async function getUSDCBalance() {
        try {
          const network = await provider.getNetwork();
          const chainId = network.chainId.toString();
          
          console.log("Current Chain ID:", chainId);
          
          const usdcAddress = usdcAddresses[chainId];
          
          if (!usdcAddress) {
            document.getElementById("usdcBalanceResult").innerText = 
              `⚠️ USDC not available on this network (Chain ID: ${chainId})\n\n` +
              `Available networks:\n` +
              `- Ethereum Mainnet (Chain ID: 1)\n` +
              `- Sepolia Testnet (Chain ID: 11155111)\n` +
              `- Goerli Testnet (Chain ID: 5)`;
            return;
          }

          const usdcContract = new ethers.Contract(usdcAddress, usdcABI, signer);
          
          console.log("USDC Contract Address:", usdcAddress);
          
          const tokenName = await usdcContract.name();
          const tokenSymbol = await usdcContract.symbol();
          const tokenDecimals = await usdcContract.decimals();
          
          console.log("Token Info:", { name: tokenName, symbol: tokenSymbol, decimals: tokenDecimals });
          
          const balance = await usdcContract.balanceOf(userAddress);
          console.log("Balance (raw):", balance.toString());
          
          const formattedBalance = ethers.formatUnits(balance, tokenDecimals);
          console.log("Balance (formatted):", formattedBalance);
          
          document.getElementById("usdcBalanceResult").innerText = 
            `Token: ${tokenName} (${tokenSymbol})\n` +
            `Contract: ${usdcAddress}\n` +
            `Your Address: ${userAddress}\n` +
            `Balance: ${formattedBalance} ${tokenSymbol}\n` +
            `Network: ${network.name} (Chain ID: ${chainId})`;
            
        } catch (error) {
          console.error("Error getting USDC balance:", error);
          document.getElementById("usdcBalanceResult").innerText = 
            `❌ Error: ${error.message}\n\n` +
            `Make sure you're connected to a supported network.`;
        }
      }

      async function transferUSDC() {
        try {
          let receiver = document.getElementById("receiverAddress").value;
          let amount = document.getElementById("usdcAmount").value;
          
          document.getElementById("transferResponse").style.display = "none";
          
          if (!receiver || !amount) {
            showTransferMessage("❌ Please enter both receiver address and amount", "error");
            return;
          }

          const network = await provider.getNetwork();
          const chainId = network.chainId.toString();
          const usdcAddress = usdcAddresses[chainId];
          
          if (!usdcAddress) {
            showTransferMessage(`❌ USDC not available on this network (Chain ID: ${chainId})`, "error");
            return;
          }

          try {
            receiver = ethers.getAddress(receiver);
            console.log("Valid receiver address:", receiver);
          } catch (error) {
            showTransferMessage(`❌ Invalid receiver address: ${receiver}`, "error");
            return;
          }

          let parsedAmount;
          try {
            parsedAmount = ethers.parseUnits(amount, 6);
            console.log("Amount in smallest units:", parsedAmount.toString());
            
            if (parsedAmount <= 0n) {
              throw new Error("Amount must be positive");
            }
          } catch (error) {
            showTransferMessage(`❌ Invalid amount: ${amount}`, "error");
            return;
          }

          const usdcContract = new ethers.Contract(usdcAddress, usdcABI, signer);

          const balance = await usdcContract.balanceOf(userAddress);
          console.log("Your balance:", balance.toString());
          console.log("Transfer amount:", parsedAmount.toString());

          if (balance < parsedAmount) {
            const amountFormatted = ethers.formatUnits(parsedAmount, 6);
            const balanceFormatted = ethers.formatUnits(balance, 6);
            showTransferMessage(
              `❌ Insufficient balance!\n` +
              `You have: ${balanceFormatted} USDC\n` +
              `You need: ${amountFormatted} USDC`,
              "error"
            );
            return;
          }

          const amountFormatted = ethers.formatUnits(parsedAmount, 6);
          showTransferMessage(
            `⏳ Transferring ${amountFormatted} USDC to ${receiver.slice(0, 6)}...${receiver.slice(-4)}\n\n` +
            `Please confirm the transaction in MetaMask...`,
            "info"
          );

          console.log("Initiating transfer...");
          const tx = await usdcContract.transfer(receiver, parsedAmount);
          
          console.log("Transaction sent:", tx.hash);
          showTransferMessage(
            `⏳ Transaction sent!\n\n` +
            `Hash: ${tx.hash}\n\n` +
            `Waiting for confirmation...`,
            "info"
          );

          const receipt = await tx.wait();
          console.log("Transaction confirmed:", receipt);

          showTransferMessage(
            `✅ Transfer successful!\n\n` +
            `Amount: ${amountFormatted} USDC\n` +
            `To: ${receiver}\n` +
            `Transaction Hash: ${tx.hash}\n` +
            `Block Number: ${receipt.blockNumber}\n` +
            `Gas Used: ${receipt.gasUsed.toString()}`,
            "success"
          );

          document.getElementById("receiverAddress").value = "";
          document.getElementById("usdcAmount").value = "";

          setTimeout(() => {
            getUSDCBalance();
          }, 2000);

        } catch (error) {
          console.error("Error transferring USDC:", error);
          
          let errorMessage = "❌ Transfer failed!\n\n";
          
          if (error.code === "ACTION_REJECTED") {
            errorMessage += "Transaction was rejected by user.";
          } else if (error.code === "INSUFFICIENT_FUNDS") {
            errorMessage += "Insufficient ETH for gas fees.";
          } else if (error.message.includes("transfer amount exceeds balance")) {
            errorMessage += "Insufficient USDC balance.";
          } else {
            errorMessage += `Error: ${error.message}`;
          }
          
          showTransferMessage(errorMessage, "error");
        }
      }

      function showTransferMessage(message, type) {
        const transferResponse = document.getElementById("transferResponse");
        transferResponse.innerText = message;
        transferResponse.style.display = "block";
        
        if (type === "error") {
          transferResponse.style.backgroundColor = "#ffebee";
          transferResponse.style.color = "#c62828";
        } else if (type === "success") {
          transferResponse.style.backgroundColor = "#e8f5e9";
          transferResponse.style.color = "#2e7d32";
        } else {
          transferResponse.style.backgroundColor = "#e3f2fd";
          transferResponse.style.color = "#1565c0";
        }
      }

      function disconnectWallet() {
        provider = null;
        signer = null;
        userAddress = null;

        document.getElementById("wallet").innerText = "❌ Wallet disconnected from app";
        document.getElementById("network").innerText = "";
        document.getElementById("blockResult").innerText = "";
        document.getElementById("balanceResult").innerText = "";
        document.getElementById("signatureResult").innerText = "";
        document.getElementById("disconnectBtn").style.display = "none";
        document.getElementById("revokeBtn").style.display = "none";

        document.getElementById("addressInput").value = "";
        document.getElementById("messageInput").value = "";

        console.log("Wallet disconnected from app. Refresh the page to reconnect.");
        
        setTimeout(() => {
          if (confirm("Wallet disconnected from app. Do you want to reload the page?")) {
            location.reload();
          }
        }, 1000);
      }

      async function revokePermissions() {
        try {
          if (window.ethereum && window.ethereum.request) {
            await window.ethereum.request({
              method: "wallet_revokePermissions",
              params: [
                {
                  eth_accounts: {}
                }
              ]
            });
            
            console.log("Permissions revoked successfully!");
            alert("✅ MetaMask permissions revoked! The page will reload.");
            
            setTimeout(() => {
              location.reload();
            }, 1000);
          } else {
            throw new Error("MetaMask not available");
          }
        } catch (error) {
          console.error("Error revoking permissions:", error);
          
          if (error.code === -32601) {
            alert(
              "⚠️ Auto-revoke not available in your MetaMask version.\n\n" +
              "To disconnect manually:\n" +
              "1. Click the MetaMask extension\n" +
              "2. Click the three dots (⋮)\n" +
              "3. Go to 'Connected sites'\n" +
              "4. Disconnect this site"
            );
          } else {
            alert(`Error: ${error.message}`);
          }
        }
      }
    </script>
  </body>
</html>
```

### package.json

```json
{
  "name": "dapp-etherjs",
  "version": "1.0.0",
  "description": "Full Stack DApp with Ethers.js v6",
  "type": "module",
  "main": "index.js",
  "scripts": {
    "dev": "http-server -p 8000",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "ethers": "^6.15.0"
  },
  "devDependencies": {
    "http-server": "^14.1.1"
  }
}
```

## 📖 Explicación Detallada del Código

### Estructura HTML y Estilos CSS

#### Head Section
```html
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethers.js DApp</title>
```
**Propósito**: Configuración básica del documento HTML5 con charset UTF-8 para soporte de caracteres especiales y viewport para responsive design.

#### Estilos CSS
```css
body {
    font-family: Arial, sans-serif;
    max-width: 800px;
    margin: 50px auto;
    padding: 20px;
}
```
**Propósito**: Centra el contenido con un ancho máximo de 800px y añade espaciado para mejor legibilidad.

```css
.section {
    margin: 20px 0;
    padding: 15px;
    border: 1px solid #ddd;
    border-radius: 5px;
}
```
**Propósito**: Crea cajas visuales para cada funcionalidad, separando visualmente las diferentes secciones de la aplicación.

```css
button {
    background-color: #4CAF50;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}
```
**Propósito**: Estiliza los botones con color verde (#4CAF50) y efecto hover para indicar interactividad.

```css
#disconnectBtn { background-color: #f44336; }
#revokeBtn { background-color: #ff6b6b; }
```
**Propósito**: Botones de desconexión en tonos rojos para indicar acciones destructivas o de salida.

```css
.result {
    background-color: #f0f0f0;
    font-family: monospace;
    white-space: pre-wrap;
    word-break: break-all;
}
```
**Propósito**: Área de resultados con fuente monoespaciada para mejor visualización de datos técnicos (direcciones, hashes). `white-space: pre-wrap` preserva saltos de línea y `word-break: break-all` evita overflow de direcciones largas.

### Secciones del Body

#### 1. Conexión de Wallet
```html
<div class="section">
    <h2>🔗 Wallet Connection</h2>
    <div id="wallet">Connecting...</div>
    <div id="network" class="result"></div>
    <button id="disconnectBtn" onclick="disconnectWallet()" style="display: none;">
```
**Propósito**: 
- `id="wallet"`: Muestra el estado de conexión y la dirección del usuario
- `id="network"`: Muestra información de la red actual (Mainnet, Sepolia, etc.)
- Botones inicialmente ocultos (`display: none`) que aparecen después de conectar

#### 2. Consulta de Blockchain
```html
<div class="section">
    <h2>🔍 Blockchain Query</h2>
    <button onclick="getCurrentBlock()">Get Current Block Number</button>
    <div id="blockResult" class="result"></div>
</div>
```
**Propósito**: Permite consultar el número del último bloque minado en la blockchain. Útil para verificar conectividad y sincronización con la red.

#### 3. Consulta de Balance ETH
```html
<input type="text" id="addressInput" placeholder="Enter Ethereum address (0x...)">
<button onclick="getBalance()">Get Balance</button>
<div id="balanceResult" class="result"></div>
```
**Propósito**: 
- Input para ingresar cualquier dirección Ethereum
- Si se deja vacío, consulta la dirección del usuario conectado
- Muestra el balance en ETH (convertido desde Wei)

#### 4. Balance de USDC
```html
<button onclick="getUSDCBalance()">Get My USDC Balance</button>
<div id="usdcBalanceResult" class="result"></div>
```
**Propósito**: Consulta el balance del token USDC del usuario conectado. Interactúa con el smart contract de USDC usando su ABI.

#### 5. Transferencia de USDC
```html
<input type="text" id="receiverAddress" placeholder="Receiver address (0x...)">
<input type="number" id="usdcAmount" placeholder="Amount (e.g., 10.5)" step="0.000001">
<button onclick="transferUSDC()">Transfer USDC</button>
```
**Propósito**: 
- `receiverAddress`: Dirección destino de la transferencia
- `usdcAmount`: Cantidad en formato decimal (ej: 10.5)
- `step="0.000001"`: Permite hasta 6 decimales (precisión de USDC)

#### 6. Firma de Mensajes
```html
<input type="text" id="messageInput" placeholder="Enter message to sign">
<button onclick="signMessage()">Sign Message</button>
<div id="signatureResult" class="result"></div>
```
**Propósito**: Permite firmar mensajes arbitrarios con la clave privada del usuario (sin exponerla). Útil para autenticación y prueba de propiedad.

### JavaScript: Configuración Inicial

#### Importación de Ethers.js
```javascript
<script type="module">
import { ethers } from './node_modules/ethers/dist/ethers.js';
```
**Propósito**: 
- `type="module"`: Habilita módulos ES6 en el navegador
- Importa ethers desde la instalación local de npm
- No usa CDN para mejor control de versiones y funcionamiento offline

#### Configuración de Contratos USDC
```javascript
const usdcAddresses = {
    '1': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',        // Mainnet
    '11155111': '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238', // Sepolia
    '5': '0x07865c6E87B9F70255377e024ace6630C1Eaa37F'         // Goerli
};
```
**Propósito**: 
- Mapa de Chain ID a dirección de contrato USDC
- Soporta múltiples redes sin hardcodear la dirección
- Chain ID '11155111' es Sepolia testnet
- Permite detectar automáticamente qué contrato usar según la red del usuario

#### ABI del Contrato USDC
```javascript
const usdcABI = [
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function decimals() view returns (uint8)",
    "function balanceOf(address _owner) public view returns (uint256 balance)",
    "function transfer(address _to, uint256 _value) public returns (bool success)",
];
```
**Propósito**: 
- ABI en formato "human-readable" de Ethers.js v6
- Define las funciones del contrato que vamos a usar
- `view`: funciones de solo lectura (no gastan gas)
- `public`: funciones que modifican estado (requieren gas y firma)
- No necesitamos el ABI completo, solo las funciones que usamos

#### Variables Globales
```javascript
let provider;  // Conexión de solo lectura a la blockchain
let signer;    // Acceso a la cuenta del usuario para firmar transacciones
let userAddress; // Dirección Ethereum del usuario conectado
```
**Propósito**: 
- Variables globales accesibles desde todas las funciones
- `provider`: Para consultas (getBalance, getBlockNumber, etc.)
- `signer`: Para operaciones que requieren firma (transfer, signMessage)
- `userAddress`: Para no consultarla repetidamente

### Función de Inicialización

```javascript
(async function () {
    if (!window.ethereum) {
        document.getElementById("wallet").innerText = "❌ Please install MetaMask!";
        return;
    }
```
**Propósito**: 
- IIFE (Immediately Invoked Function Expression) asíncrona
- `window.ethereum`: API inyectada por MetaMask
- Si no existe, el usuario no tiene MetaMask instalado
- `return`: Detiene la ejecución si no hay MetaMask

```javascript
provider = new ethers.BrowserProvider(window.ethereum);
await provider.send("eth_requestAccounts", []);
signer = await provider.getSigner();
```
**Propósito**: 
- `BrowserProvider`: Wrapper de ethers.js sobre window.ethereum
- `eth_requestAccounts`: Solicita permiso al usuario para conectar su wallet
- Muestra popup de MetaMask para que el usuario apruebe
- `getSigner()`: Obtiene acceso a la cuenta para firmar (async en v6)

```javascript
userAddress = await signer.getAddress();
document.getElementById("wallet").innerText = "✅ Connected: " + userAddress;
```
**Propósito**: 
- Obtiene la dirección pública del usuario
- Actualiza la UI para mostrar conexión exitosa
- El emoji ✅ indica visualmente el éxito

#### Detección de Red
```javascript
const network = await provider.getNetwork();
console.log("Network Info:", network);
console.log("Chain ID:", network.chainId);
```
**Propósito**: 
- `getNetwork()`: Obtiene información de la red actual
- `chainId`: Identificador único de cada red blockchain
- Logs para debugging y verificación

```javascript
const networkNames = {
    '1': 'Ethereum Mainnet',
    '11155111': 'Sepolia Testnet',
    '5': 'Goerli Testnet',
    '137': 'Polygon Mainnet'
};

const displayName = networkNames[network.chainId.toString()] || network.name;
```
**Propósito**: 
- Convierte Chain IDs numéricos a nombres legibles
- `toString()`: Convierte BigInt a string para usar como clave
- Operador `||`: Si no está en el mapa, usa el nombre por defecto

```javascript
document.getElementById("network").innerText = 
    `🌐 Network: ${displayName} (Chain ID: ${network.chainId})`;

document.getElementById("disconnectBtn").style.display = "inline-block";
document.getElementById("revokeBtn").style.display = "inline-block";
```
**Propósito**: 
- Muestra la red actual al usuario
- Template literals (`` ` ``) para interpolación de variables
- Hace visibles los botones de desconexión después de conectar exitosamente

#### Exposición de Funciones Globales
```javascript
window.getCurrentBlock = getCurrentBlock;
window.getBalance = getBalance;
window.signMessage = signMessage;
// ... etc
window.provider = provider;
window.signer = signer;
window.ethers = ethers;
```
**Propósito**: 
- Hace las funciones accesibles desde atributos `onclick` en HTML
- Los módulos ES6 tienen scope aislado, necesitamos exponerlas
- Exponer provider/signer/ethers permite debugging desde la consola del navegador
- El usuario puede ejecutar comandos como `window.provider.getBlockNumber()` en la consola

### Función getCurrentBlock()

```javascript
async function getCurrentBlock() {
    try {
        let currentBlock = await provider.getBlockNumber();
        console.log("Current block:", currentBlock);
        document.getElementById("blockResult").innerText = 
            `Current Block Number: ${currentBlock}`;
    } catch (error) {
        console.error("Error getting block:", error);
        document.getElementById("blockResult").innerText = 
            `Error: ${error.message}`;
    }
}
```
**Explicación línea por línea**:
1. `async function`: Permite usar `await` dentro
2. `try-catch`: Captura errores de red o conexión
3. `provider.getBlockNumber()`: Método de solo lectura (no requiere gas)
4. `await`: Espera la respuesta de la blockchain
5. `console.log`: Para debugging en consola del navegador
6. `document.getElementById().innerText`: Actualiza la UI con el resultado
7. `catch`: Si falla (ej: red caída), muestra error al usuario
8. `error.message`: Mensaje legible del error

**Uso**: Esta función es útil para verificar que estás conectado correctamente y la red está respondiendo.

### Función getBalance()

```javascript
async function getBalance() {
    try {
        let address = document.getElementById("addressInput").value;
        
        if (!address) {
            address = userAddress;
            console.log("No address provided, using connected wallet:", address);
        }
```
**Propósito**:
- Lee el valor del input de dirección
- Si está vacío, usa la dirección del usuario conectado
- Log informativo para debugging

```javascript
        if (!ethers.isAddress(address)) {
            document.getElementById("balanceResult").innerText = 
                "Invalid Ethereum address";
            return;
        }
```
**Propósito**:
- `ethers.isAddress()`: Valida formato de dirección Ethereum (checksum)
- Previene consultas con direcciones malformadas
- `return`: Detiene ejecución si la validación falla

```javascript
        console.log("Querying balance for:", address);
        let balance = await provider.getBalance(address);
        console.log("Balance in Wei:", balance.toString());
```
**Propósito**:
- `getBalance()`: Consulta el balance nativo (ETH) de una dirección
- Retorna en Wei (1 ETH = 10^18 Wei)
- `balance` es un BigInt en ethers v6
- `.toString()`: Convierte BigInt a string para logging

```javascript
        let balanceInEth = ethers.formatEther(balance);
        console.log("Balance in ETH:", balanceInEth);
        
        const network = await provider.getNetwork();
        
        document.getElementById("balanceResult").innerText = 
            `Address: ${address}\nBalance: ${balanceInEth} ETH\nNetwork: ${network.name} (Chain ID: ${network.chainId})`;
```
**Propósito**:
- `formatEther()`: Convierte de Wei (18 decimales) a ETH
- `\n`: Saltos de línea en el texto
- Muestra red para confirmación (importante en testnets)
- Template literals para formato legible

### Función signMessage()

```javascript
async function signMessage() {
    try {
        let message = document.getElementById("messageInput").value;
        
        if (!message) {
            document.getElementById("signatureResult").innerText = 
                "Please enter a message to sign";
            return;
        }
```
**Propósito**:
- Lee el mensaje del input
- Valida que no esté vacío
- Early return si no hay mensaje

```javascript
        let signature = await signer.signMessage(message);
        
        console.log("Message:", message);
        console.log("Signature:", signature);
```
**Propósito**:
- `signer.signMessage()`: Firma el mensaje con la clave privada del usuario
- Requiere aprobación en MetaMask (popup de firma)
- La clave privada NUNCA sale de MetaMask
- Retorna firma en formato hexadecimal (130 caracteres: 0x + 128 hex)

```javascript
        document.getElementById("signatureResult").innerText = 
            `Message: "${message}"\n\nSignature:\n${signature}`;
```
**Propósito**:
- Muestra mensaje original y firma resultante
- La firma puede usarse para verificación posterior
- Cualquiera puede verificar que esa firma proviene de esa dirección sin exponer la clave privada

**Caso de uso**: Autenticación en aplicaciones web sin contraseñas (Sign-In with Ethereum).

### Función getUSDCBalance()

```javascript
async function getUSDCBalance() {
    try {
        const network = await provider.getNetwork();
        const chainId = network.chainId.toString();
        
        console.log("Current Chain ID:", chainId);
        
        const usdcAddress = usdcAddresses[chainId];
```
**Propósito**:
- Detecta la red actual del usuario
- Convierte BigInt a string para usar como clave de objeto
- Busca la dirección del contrato USDC para esa red

```javascript
        if (!usdcAddress) {
            document.getElementById("usdcBalanceResult").innerText = 
                `⚠️ USDC not available on this network (Chain ID: ${chainId})\n\n` +
                `Available networks:\n- Ethereum Mainnet (Chain ID: 1)\n` +
                `- Sepolia Testnet (Chain ID: 11155111)\n- Goerli Testnet (Chain ID: 5)`;
            return;
        }
```
**Propósito**:
- Manejo de error cuando el usuario está en una red no soportada
- Mensaje informativo listando redes disponibles
- Previene intentar interactuar con contrato inexistente

```javascript
        const usdcContract = new ethers.Contract(usdcAddress, usdcABI, signer);
        
        console.log("USDC Contract Address:", usdcAddress);
```
**Propósito**:
- `new ethers.Contract()`: Crea instancia del contrato
- Parámetros: dirección, ABI, signer
- Con `signer`: podemos hacer operaciones de lectura Y escritura
- Con `provider`: solo lectura

```javascript
        const tokenName = await usdcContract.name();
        const tokenSymbol = await usdcContract.symbol();
        const tokenDecimals = await usdcContract.decimals();
        
        console.log("Token Info:", { name: tokenName, symbol: tokenSymbol, decimals: tokenDecimals });
```
**Propósito**:
- Llama funciones `view` del contrato (no gastan gas)
- `name()`: Retorna "USD Coin"
- `symbol()`: Retorna "USDC"
- `decimals()`: Retorna 6 (USDC usa 6 decimales, no 18 como ETH)
- Estas llamadas son síncronas con la blockchain pero no requieren firma

```javascript
        const balance = await usdcContract.balanceOf(userAddress);
        console.log("Balance (raw):", balance.toString());
        
        const formattedBalance = ethers.formatUnits(balance, tokenDecimals);
        console.log("Balance (formatted):", formattedBalance);
```
**Propósito**:
- `balanceOf()`: Función estándar ERC-20 para consultar balance
- Balance en unidades más pequeñas (6 decimales para USDC)
- `formatUnits(balance, 6)`: Convierte de unidades pequeñas a decimales legibles
- Ejemplo: 1000000 (raw) → 1.0 (formatted)

```javascript
        document.getElementById("usdcBalanceResult").innerText = 
            `Token: ${tokenName} (${tokenSymbol})\n` +
            `Contract: ${usdcAddress}\n` +
            `Your Address: ${userAddress}\n` +
            `Balance: ${formattedBalance} ${tokenSymbol}\n` +
            `Network: ${network.name} (Chain ID: ${chainId})`;
```
**Propósito**:
- Muestra información completa y detallada
- Incluye dirección del contrato para verificación en exploradores de blockchain
- Muestra red para confirmar estás consultando donde esperas

### Función transferUSDC() - Parte 1: Validaciones

```javascript
async function transferUSDC() {
    try {
        let receiver = document.getElementById("receiverAddress").value;
        let amount = document.getElementById("usdcAmount").value;
        
        document.getElementById("transferResponse").style.display = "none";
```
**Propósito**:
- Lee inputs del formulario
- Oculta mensaje anterior (si existe) para evitar confusión
- Reset del estado de UI antes de nueva operación

```javascript
        if (!receiver || !amount) {
            showTransferMessage("❌ Please enter both receiver address and amount", "error");
            return;
        }
```
**Propósito**:
- Validación básica de campos requeridos
- Early return para evitar procesamiento innecesario
- Mensaje de error claro al usuario

```javascript
        const network = await provider.getNetwork();
        const chainId = network.chainId.toString();
        const usdcAddress = usdcAddresses[chainId];
        
        if (!usdcAddress) {
            showTransferMessage(`❌ USDC not available on this network (Chain ID: ${chainId})`, "error");
            return;
        }
```
**Propósito**:
- Verifica que estás en una red soportada
- Previene intentar transferir en red donde no existe el contrato
- Mismo patrón de validación que getUSDCBalance()

```javascript
        try {
            receiver = ethers.getAddress(receiver);
            console.log("Valid receiver address:", receiver);
        } catch (error) {
            showTransferMessage(`❌ Invalid receiver address: ${receiver}`, "error");
            return;
        }
```
**Propósito**:
- `getAddress()`: Valida y normaliza dirección (convierte a checksum)
- Lanza error si formato inválido
- Try-catch interno para manejar específicamente error de validación de dirección
- Previene enviar fondos a dirección malformada (pérdida de fondos)

```javascript
        let parsedAmount;
        try {
            parsedAmount = ethers.parseUnits(amount, 6);
            console.log("Amount in smallest units:", parsedAmount.toString());
            
            if (parsedAmount <= 0n) {
                throw new Error("Amount must be positive");
            }
        } catch (error) {
            showTransferMessage(`❌ Invalid amount: ${amount}`, "error");
            return;
        }
```
**Propósito**:
- `parseUnits(amount, 6)`: Convierte de formato decimal (10.5) a unidades pequeñas (10500000)
- `6`: USDC usa 6 decimales
- `0n`: BigInt literal en JavaScript
- `<=`: Comparación con BigInt
- Valida que sea número positivo
- Previene transferencias de 0 o negativas

### Función transferUSDC() - Parte 2: Verificación de Balance

```javascript
        const usdcContract = new ethers.Contract(usdcAddress, usdcABI, signer);

        const balance = await usdcContract.balanceOf(userAddress);
        console.log("Your balance:", balance.toString());
        console.log("Transfer amount:", parsedAmount.toString());
```
**Propósito**:
- Crea instancia del contrato
- Consulta balance actual del usuario
- Logs para debugging y comparación

```javascript
        if (balance < parsedAmount) {
            const amountFormatted = ethers.formatUnits(parsedAmount, 6);
            const balanceFormatted = ethers.formatUnits(balance, 6);
            showTransferMessage(
                `❌ Insufficient balance!\n` +
                `You have: ${balanceFormatted} USDC\n` +
                `You need: ${amountFormatted} USDC`,
                "error"
            );
            return;
        }
```
**Propósito**:
- Comparación directa de BigInt en v6
- Previene transacción que fallaría en blockchain (ahorrando gas)
- Mensaje claro mostrando balance actual vs requerido
- Formatea ambos números para legibilidad del usuario

### Función transferUSDC() - Parte 3: Ejecución de Transferencia

```javascript
        const amountFormatted = ethers.formatUnits(parsedAmount, 6);
        showTransferMessage(
            `⏳ Transferring ${amountFormatted} USDC to ${receiver.slice(0, 6)}...${receiver.slice(-4)}\n\n` +
            `Please confirm the transaction in MetaMask...`,
            "info"
        );
```
**Propósito**:
- Mensaje de estado "en progreso" antes de mostrar MetaMask
- `slice(0, 6)...slice(-4)`: Formato corto de dirección (0x1c7D...9C38)
- Instruye al usuario sobre el siguiente paso
- Feedback inmediato de que algo está pasando

```javascript
        console.log("Initiating transfer...");
        const tx = await usdcContract.transfer(receiver, parsedAmount);
```
**Propósito**:
- `transfer()`: Función estándar ERC-20 para transferir tokens
- Parámetros: dirección destino, cantidad (en unidades pequeñas)
- `await`: Espera a que el usuario confirme en MetaMask
- Si usuario rechaza, lanza error y va al catch
- `tx`: Objeto de transacción con información preliminar

```javascript
        console.log("Transaction sent:", tx.hash);
        showTransferMessage(
            `⏳ Transaction sent!\n\n` +
            `Hash: ${tx.hash}\n\n` +
            `Waiting for confirmation...`,
            "info"
        );
```
**Propósito**:
- `tx.hash`: Hash único de la transacción
- Transacción enviada pero AÚN NO confirmada
- Usuario puede copiar hash para monitorear en Etherscan
- Mensaje actualizado muestra progreso

```javascript
        const receipt = await tx.wait();
        console.log("Transaction confirmed:", receipt);
```
**Propósito**:
- `tx.wait()`: Espera a que la transacción sea minada e incluida en un bloque
- Puede tomar segundos o minutos dependiendo de la red y gas
- `receipt`: Contiene detalles de la transacción confirmada
- Incluye: blockNumber, gasUsed, status, logs, etc.

```javascript
        showTransferMessage(
            `✅ Transfer successful!\n\n` +
            `Amount: ${amountFormatted} USDC\n` +
            `To: ${receiver}\n` +
            `Transaction Hash: ${tx.hash}\n` +
            `Block Number: ${receipt.blockNumber}\n` +
            `Gas Used: ${receipt.gasUsed.toString()}`,
            "success"
        );
```
**Propósito**:
- Mensaje de éxito con todos los detalles
- `blockNumber`: En qué bloque se incluyó
- `gasUsed`: Cuánto gas costó la transacción
- Información completa para verificación y registros

```javascript
        document.getElementById("receiverAddress").value = "";
        document.getElementById("usdcAmount").value = "";

        setTimeout(() => {
            getUSDCBalance();
        }, 2000);
```
**Propósito**:
- Limpia los campos del formulario
- Listo para nueva transferencia
- `setTimeout`: Espera 2 segundos antes de actualizar balance
- Da tiempo a que la blockchain se actualice
- Actualización automática de balance sin intervención del usuario

### Función transferUSDC() - Parte 4: Manejo de Errores

```javascript
    } catch (error) {
        console.error("Error transferring USDC:", error);
        
        let errorMessage = "❌ Transfer failed!\n\n";
        
        if (error.code === "ACTION_REJECTED") {
            errorMessage += "Transaction was rejected by user.";
        } else if (error.code === "INSUFFICIENT_FUNDS") {
            errorMessage += "Insufficient ETH for gas fees.";
        } else if (error.message.includes("transfer amount exceeds balance")) {
            errorMessage += "Insufficient USDC balance.";
        } else {
            errorMessage += `Error: ${error.message}`;
        }
        
        showTransferMessage(errorMessage, "error");
    }
}
```
**Propósito**:
- Catch global para todos los errores posibles
- `error.code`: Códigos estándar de ethers.js
- `ACTION_REJECTED`: Usuario canceló en MetaMask
- `INSUFFICIENT_FUNDS`: No hay ETH para pagar gas (común en testnets)
- Verificación de mensaje de error del contrato
- Mensajes amigables en lugar de errores técnicos
- Ayuda al usuario a entender qué salió mal y cómo solucionarlo

### Función Auxiliar showTransferMessage()

```javascript
function showTransferMessage(message, type) {
    const transferResponse = document.getElementById("transferResponse");
    transferResponse.innerText = message;
    transferResponse.style.display = "block";
```
**Propósito**:
- Función reutilizable para mostrar mensajes
- `display: "block"`: Hace visible el elemento
- Centraliza lógica de mostrar mensajes

```javascript
    if (type === "error") {
        transferResponse.style.backgroundColor = "#ffebee";
        transferResponse.style.color = "#c62828";
    } else if (type === "success") {
        transferResponse.style.backgroundColor = "#e8f5e9";
        transferResponse.style.color = "#2e7d32";
    } else {
        transferResponse.style.backgroundColor = "#e3f2fd";
        transferResponse.style.color = "#1565c0";
    }
}
```
**Propósito**:
- Código de colores para diferentes estados
- Rojo: Error (algo falló)
- Verde: Éxito (operación completada)
- Azul: Info (en progreso o información general)
- Feedback visual inmediato para el usuario
- Mejora UX sin necesidad de leer el texto

### Función disconnectWallet()

```javascript
function disconnectWallet() {
    provider = null;
    signer = null;
    userAddress = null;
```
**Propósito**:
- Limpia referencias a objetos de ethers.js
- Libera memoria
- Previene uso accidental de conexión antigua

```javascript
    document.getElementById("wallet").innerText = "❌ Wallet disconnected from app";
    document.getElementById("network").innerText = "";
    document.getElementById("blockResult").innerText = "";
    document.getElementById("balanceResult").innerText = "";
    document.getElementById("signatureResult").innerText = "";
    document.getElementById("disconnectBtn").style.display = "none";
    document.getElementById("revokeBtn").style.display = "none";
```
**Propósito**:
- Limpia toda la UI
- Resetea a estado inicial
- Oculta botones de desconexión
- Previene confusión sobre estado de conexión

```javascript
    document.getElementById("addressInput").value = "";
    document.getElementById("messageInput").value = "";

    console.log("Wallet disconnected from app. Refresh the page to reconnect.");
    
    setTimeout(() => {
        if (confirm("Wallet disconnected from app. Do you want to reload the page?")) {
            location.reload();
        }
    }, 1000);
}
```
**Propósito**:
- Limpia formularios
- Log informativo
- Pregunta al usuario si quiere recargar
- `setTimeout(1000)`: Espera 1 segundo para que usuario vea mensaje de desconexión
- `confirm()`: Dialog nativo del navegador
- `location.reload()`: Recarga página para reiniciar aplicación

**Nota**: Esta es desconexión de la APLICACIÓN, no de MetaMask. MetaMask sigue recordando el sitio.

### Función revokePermissions()

```javascript
async function revokePermissions() {
    try {
        if (window.ethereum && window.ethereum.request) {
            await window.ethereum.request({
                method: "wallet_revokePermissions",
                params: [
                    {
                        eth_accounts: {}
                    }
                ]
            });
```
**Propósito**:
- `wallet_revokePermissions`: Método experimental de MetaMask
- Revoca permisos a nivel de MetaMask (no solo app)
- `eth_accounts`: Permiso específico para acceso a cuentas
- MetaMask olvida que diste permiso a este sitio

```javascript
            console.log("Permissions revoked successfully!");
            alert("✅ MetaMask permissions revoked! The page will reload.");
            
            setTimeout(() => {
                location.reload();
            }, 1000);
```
**Propósito**:
- Confirmación de éxito
- `alert()`: Notificación bloqueante para asegurar que usuario vea
- Recarga automática después de 1 segundo
- Al recargar, tendrás que volver a conectar desde cero

```javascript
        } else {
            throw new Error("MetaMask not available");
        }
    } catch (error) {
        console.error("Error revoking permissions:", error);
        
        if (error.code === -32601) {
            alert(
                "⚠️ Auto-revoke not available in your MetaMask version.\n\n" +
                "To disconnect manually:\n" +
                "1. Click the MetaMask extension\n" +
                "2. Click the three dots (⋮)\n" +
                "3. Go to 'Connected sites'\n" +
                "4. Disconnect this site"
            );
        } else {
            alert(`Error: ${error.message}`);
        }
    }
}
```
**Propósito**:
- `-32601`: Código de error "método no encontrado"
- Versiones antiguas de MetaMask no tienen este método
- Fallback: Instrucciones manuales paso a paso
- Guía visual para que usuario pueda desconectar de todas formas
- Manejo robusto de compatibilidad

## 🎓 Conceptos Clave Implementados

### 1. Asincronía en JavaScript
- Todas las operaciones de blockchain son asíncronas
- `async/await`: Sintaxis moderna para manejar promesas
- Sin `await`, obtendrías un Promise en lugar del valor

### 2. Try-Catch para Manejo de Errores
- Envuelve operaciones que pueden fallar
- Red caída, usuario rechaza, gas insuficiente, etc.
- Muestra errores amigables en lugar de crashes

### 3. Validaciones en Frontend
- Verificar datos ANTES de enviar a blockchain
- Ahorra gas al prevenir transacciones que fallarían
- Mejora UX con mensajes inmediatos

### 4. Separación de Responsabilidades
- HTML: Estructura
- CSS: Presentación
- JavaScript: Lógica
- Cada función hace una cosa específica

### 5. Feedback Visual
- Estados de carga (⏳)
- Éxito (✅)
- Error (❌)
- Colores diferenciados
- Mensajes informativos

### 6. Seguridad
- Validación de todas las entradas
- Verificación de balance antes de transferir
- Normalización de direcciones
- Manejo de errores sin exponer información sensible
- La clave privada NUNCA sale de MetaMask

```bash
# 1. Clonar o crear la carpeta del proyecto
mkdir mi-dapp-ethers
cd mi-dapp-ethers

# 2. Crear los archivos
# Copiar el código de index.html y package.json

# 3. Instalar dependencias
npm install

# 4. Ejecutar servidor de desarrollo
npm run dev
# o
npx http-server -p 8000

# 5. Abrir en el navegador
# http://localhost:8000
```

### Estructura Final del Proyecto

```
mi-dapp-ethers/
├── node_modules/
│   └── ethers/
│       └── dist/
│           └── ethers.js
├── index.html          (Código completo arriba)
├── package.json        (Configuración del proyecto)
├── package-lock.json   (Generado automáticamente)
└── README.md          (Esta documentación)
```

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethers.js DApp</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 50px auto;
        padding: 20px;
      }
      .section {
        margin: 20px 0;
        padding: 15px;
        border: 1px solid #ddd;
        border-radius: 5px;
      }
      button {
        background-color: #4CAF50;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        margin: 5px;
      }
      button:hover {
        background-color: #45a049;
      }
      input {
        padding: 8px;
        margin: 5px;
        width: 400px;
        border: 1px solid #ddd;
        border-radius: 4px;
      }
      .result {
        margin-top: 10px;
        padding: 10px;
        background-color: #f0f0f0;
        border-radius: 4px;
        font-family: monospace;
      }
    </style>
  </head>
  <body>
    <h1>Ethers.js DApp - Blockchain Explorer</h1>

    <!-- Conexión de Wallet -->
    <div class="section">
      <h2>🔗 Wallet Connection</h2>
      <div id="wallet">Connecting...</div>
    </div>

    <!-- Consulta de Blockchain -->
    <div class="section">
      <h2>🔍 Blockchain Query</h2>
      <button onclick="getCurrentBlock()">Get Current Block Number</button>
      <div id="blockResult" class="result"></div>
    </div>

    <!-- Consulta de Balance -->
    <div class="section">
      <h2>💰 Balance Query</h2>
      <input type="text" id="addressInput" placeholder="Enter Ethereum address (0x...)">
      <button onclick="getBalance()">Get Balance</button>
      <div id="balanceResult" class="result"></div>
    </div>

    <!-- Firmar Mensaje -->
    <div class="section">
      <h2>✍️ Sign Message</h2>
      <input type="text" id="messageInput" placeholder="Enter message to sign">
      <button onclick="signMessage()">Sign Message</button>
      <div id="signatureResult" class="result"></div>
    </div>

    <script type="module">
      import { ethers } from './node_modules/ethers/dist/ethers.js';

      // Variables globales
      let provider;
      let signer;
      let userAddress;

      // Inicialización
      (async function () {
        if (!window.ethereum) {
          document.getElementById("wallet").innerText = "❌ Please install MetaMask!";
          return;
        }

        provider = new ethers.BrowserProvider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = await provider.getSigner();
        
        userAddress = await signer.getAddress();
        document.getElementById("wallet").innerText = "✅ Connected: " + userAddress;

        // Exponer funciones al scope global
        window.getCurrentBlock = getCurrentBlock;
        window.getBalance = getBalance;
        window.signMessage = signMessage;
        window.provider = provider;
        window.signer = signer;
        window.ethers = ethers;
      })();

      // Obtener número de bloque actual
      async function getCurrentBlock() {
        try {
          let currentBlock = await provider.getBlockNumber();
          console.log("Current block:", currentBlock);
          document.getElementById("blockResult").innerText = 
            `Current Block Number: ${currentBlock}`;
        } catch (error) {
          console.error("Error getting block:", error);
          document.getElementById("blockResult").innerText = 
            `Error: ${error.message}`;
        }
      }

      // Obtener balance de una dirección
      async function getBalance() {
        try {
          let address = document.getElementById("addressInput").value;
          
          if (!address) {
            address = userAddress;
          }

          // Validar dirección
          if (!ethers.isAddress(address)) {
            document.getElementById("balanceResult").innerText = 
              "Invalid Ethereum address";
            return;
          }

          let balance = await provider.getBalance(address);
          // Convertir de wei a ETH
          let balanceInEth = ethers.formatEther(balance);
          
          console.log(`Balance of ${address}: ${balanceInEth} ETH`);
          document.getElementById("balanceResult").innerText = 
            `Address: ${address}\nBalance: ${balanceInEth} ETH`;
        } catch (error) {
          console.error("Error getting balance:", error);
          document.getElementById("balanceResult").innerText = 
            `Error: ${error.message}`;
        }
      }

      // Firmar mensaje
      async function signMessage() {
        try {
          let message = document.getElementById("messageInput").value;
          
          if (!message) {
            document.getElementById("signatureResult").innerText = 
              "Please enter a message to sign";
            return;
          }

          let signature = await signer.signMessage(message);
          
          console.log("Message:", message);
          console.log("Signature:", signature);
          
          document.getElementById("signatureResult").innerText = 
            `Message: "${message}"\n\nSignature:\n${signature}`;
        } catch (error) {
          console.error("Error signing message:", error);
          document.getElementById("signatureResult").innerText = 
            `Error: ${error.message}`;
        }
      }
    </script>
  </body>
</html>
```

## 🎯 Funcionalidades Implementadas

### 1. Conexión de Wallet
- Conecta automáticamente con MetaMask al cargar la página
- Muestra la dirección del usuario conectado
- Valida que MetaMask esté instalado

### 2. Consulta de Blockchain
- **getCurrentBlock()**: Obtiene el número del último bloque minado
- Usa el método `getBlockNumber()` del provider
- Muestra el resultado en pantalla y en consola

### 3. Consulta de Balance
- **getBalance()**: Consulta el balance de cualquier dirección Ethereum
- Si no se ingresa dirección, consulta la del usuario conectado
- Valida que la dirección sea correcta con `ethers.isAddress()`
- Convierte automáticamente de Wei a ETH usando `ethers.formatEther()`
- Maneja errores de forma clara

### 4. Firma de Mensajes
- **signMessage()**: Firma mensajes con la clave privada del usuario
- Crea firmas digitales para demostrar propiedad sin exponer la clave privada
- Usa `signer.signMessage()` 
- Muestra la firma resultante en formato hexadecimal

## 🔧 Conceptos Clave de Ethers.js

### Provider (Proveedor)
- Proporciona acceso de **solo lectura** a la blockchain Ethereum
- Permite consultar el estado de la blockchain
- En v6 existen diferentes tipos de providers

#### BrowserProvider (para DApps con MetaMask)
Se usa cuando necesitas interacción del usuario y firma de transacciones:

```javascript
const provider = new ethers.BrowserProvider(window.ethereum);
```

**Cuándo usarlo:**
- ✅ DApps con interfaz web
- ✅ Necesitas que el usuario firme transacciones
- ✅ Quieres usar la red que el usuario tiene en MetaMask
- ✅ Aplicaciones que requieren autenticación del usuario

#### JsonRpcProvider (para solo lectura o backend)
Se usa cuando solo necesitas leer datos o en aplicaciones backend:

```javascript
const provider = new ethers.JsonRpcProvider(
  'https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY'
);
```

**Cuándo usarlo:**
- ✅ Aplicaciones backend (Node.js)
- ✅ Solo necesitas leer datos (sin firmar)
- ✅ Scripts automáticos o bots
- ✅ No requieres interacción del usuario
- ✅ Quieres conectarte a una red específica sin MetaMask

**Comparación:**

| Característica | BrowserProvider | JsonRpcProvider |
|----------------|-----------------|-----------------|
| Requiere MetaMask | Sí | No |
| Puede firmar transacciones | Sí (con signer) | No |
| Solo lectura | Sí | Sí |
| Ubicación | Frontend (navegador) | Frontend/Backend |
| Red | La que usuario elija | La que tú especifiques |

### Signer (Firmante)
- Tiene acceso a la **clave privada** del usuario
- Puede **firmar transacciones** y mensajes
- Se obtiene desde el provider después de conectar

```javascript
const signer = await provider.getSigner();
```

**Nota:** Solo disponible con `BrowserProvider`, no con `JsonRpcProvider`.

### Window.ethereum
- API global proporcionada por MetaMask
- Permite la comunicación entre la DApp y la wallet
- Se verifica su existencia antes de usarla

```javascript
if (!window.ethereum) {
  // MetaMask no está instalado
}
```

## 🎯 Diferencias entre Ethers.js v5 y v6

| Característica | v5 | v6 |
|----------------|----|----|
| Provider | `Web3Provider` | `BrowserProvider` |
| getSigner() | Síncrono | Asíncrono (requiere `await`) |
| Import CDN | Disponible | No recomendado |
| Import npm | `require()` o `import` | `import` (ES Modules) |

## 🌐 Ejecutar el Proyecto

### Método 1: http-server (Recomendado)

```bash
# Instalar http-server globalmente (solo una vez)
npm install -g http-server

# Ejecutar servidor
npx http-server -p 8000
```

Abrir en el navegador: `http://localhost:8000`

### Método 2: Python

```bash
python -m http.server 8000
```

### Método 3: Live Server (VS Code)

1. Instalar extensión "Live Server" en VS Code
2. Clic derecho en `index.html` → "Open with Live Server"

## 🔍 Flujo de Ejecución

```
1. Usuario abre index.html en localhost
   ↓
2. Se carga Ethers.js desde node_modules
   ↓
3. Se verifica si MetaMask está instalado (window.ethereum)
   ↓
4. Se crea el BrowserProvider
   ↓
5. Se solicita acceso a las cuentas (popup de MetaMask)
   ↓
6. Usuario acepta la conexión
   ↓
7. Se obtiene el Signer
   ↓
8. Se obtiene la dirección de la wallet
   ↓
9. Se muestra en la página
```

## ⚠️ Solución de Problemas Comunes

### Error: "ethers is not defined"
- **Causa**: No se está usando `type="module"` en el script
- **Solución**: Agregar `type="module"` al tag `<script>`

### Error: "Cannot find module"
- **Causa**: Ruta incorrecta al importar ethers
- **Solución**: Verificar que la ruta sea `./node_modules/ethers/dist/ethers.js`

### MetaMask no aparece
- **Causa**: Script se ejecuta antes de que la página cargue
- **Solución**: Usar función autoejecutable `(async function() { ... })();`

### Error 404 al cargar ethers
- **Causa**: No se está ejecutando desde un servidor local
- **Solución**: Usar http-server o Python para servir archivos

### Caché del navegador
- **Causa**: El navegador guarda versión antigua del archivo
- **Solución**: Recargar con `Ctrl + Shift + R` (hard reload)

## 🔐 Configuración de MetaMask

### 1. Instalar MetaMask
- Ve a [metamask.io](https://metamask.io)
- Descarga la extensión para tu navegador
- Crea una nueva wallet o importa una existente

### 2. Cambiar a Red de Prueba
- Abre MetaMask
- Clic en el menú de redes (arriba)
- Habilita "Mostrar redes de prueba" en configuración
- Selecciona "Sepolia" o "Goerli"

### 3. Obtener ETH de Prueba
- Copia tu dirección de wallet
- Ve a un faucet:
  - Sepolia: https://sepoliafaucet.com/
  - Goerli: https://goerlifaucet.com/
- Pega tu dirección y solicita ETH gratis

## 📚 Próximos Pasos

Con esta configuración básica puedes:
- ✅ Conectar con MetaMask
- ✅ Obtener la dirección de la wallet del usuario
- ✅ Acceder al provider y signer

En la siguiente fase agregaremos:
- Consultar saldo de ETH
- Consultar información de la blockchain
- Interactuar con contratos inteligentes
- Enviar transacciones

## 🎯 Estado Actual del Proyecto: DApp Full Stack

Esta aplicación es ahora una **DApp Full Stack funcional** que incluye:

### Frontend Completo
- Interfaz web con HTML/CSS
- Conexión e interacción con MetaMask
- Consultas a la blockchain
- Interacción con contratos inteligentes (USDC)
- Transferencias de tokens

### Funcionalidades Implementadas

#### 1. Gestión de Wallet
- Conexión automática con MetaMask
- Detección de red activa (Mainnet, Sepolia, Goerli)
- Visualización de dirección conectada
- Desconexión de la aplicación
- Revocación de permisos de MetaMask

#### 2. Consultas de Blockchain
- **getCurrentBlock()**: Obtener número del último bloque minado
- **getBalance()**: Consultar balance de ETH de cualquier dirección
- Conversión automática de Wei a ETH
- Validación de direcciones Ethereum

#### 3. Firma de Mensajes
- **signMessage()**: Firmar mensajes con clave privada
- Generar firmas digitales para demostrar propiedad
- Visualización de firma en formato hexadecimal

#### 4. Interacción con Contratos (USDC)
- **getUSDCBalance()**: Consultar balance de USDC
- **transferUSDC()**: Transferir tokens USDC
- Soporte multi-red (Mainnet, Sepolia, Goerli)
- Validaciones completas de dirección y cantidad
- Verificación de balance antes de transferir
- Manejo de errores robusto

### Características Técnicas

#### Smart Contract Integration
```javascript
// Configuración del contrato USDC
const usdcAddresses = {
  '1': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',        // Mainnet
  '11155111': '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238', // Sepolia
  '5': '0x07865c6E87B9F70255377e024ace6630C1Eaa37F'         // Goerli
};

// ABI simplificado
const usdcABI = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
  "function balanceOf(address) public view returns (uint256)",
  "function transfer(address, uint256) public returns (bool)",
];

// Crear instancia del contrato
const contract = new ethers.Contract(address, abi, signer);
```

#### Manejo de Transacciones
```javascript
// Enviar transacción
const tx = await contract.transfer(receiver, amount);

// Esperar confirmación
const receipt = await tx.wait();

// Acceder a detalles
console.log("Hash:", tx.hash);
console.log("Block:", receipt.blockNumber);
console.log("Gas:", receipt.gasUsed.toString());
```

#### Validaciones y Conversiones
```javascript
// Validar dirección
const validAddress = ethers.getAddress(address);

// Convertir a unidades más pequeñas (USDC = 6 decimales)
const amount = ethers.parseUnits("10.5", 6);

// Convertir a unidades legibles
const formatted = ethers.formatUnits(amount, 6);

// Comparar BigInt
if (balance < amount) { /* insuficiente */ }
```

### Arquitectura de la Aplicación

```
DApp Architecture
├── Frontend (HTML/CSS/JavaScript)
│   ├── UI Components (inputs, buttons, display areas)
│   ├── Event Handlers (onclick functions)
│   └── Style Management (CSS)
│
├── Ethers.js v6 (npm package)
│   ├── Provider (BrowserProvider)
│   ├── Signer (from MetaMask)
│   └── Contract (USDC interaction)
│
├── MetaMask (Wallet)
│   ├── Account Management
│   ├── Transaction Signing
│   └── Network Selection
│
└── Ethereum Blockchain
    ├── Read Operations (getBalance, getBlockNumber)
    └── Write Operations (transfer tokens)
```

### Flujo de una Transferencia USDC

```
1. Usuario ingresa dirección y cantidad
   ↓
2. Validar dirección (ethers.getAddress)
   ↓
3. Parsear cantidad (ethers.parseUnits)
   ↓
4. Verificar balance suficiente
   ↓
5. Crear instancia del contrato
   ↓
6. Llamar contract.transfer()
   ↓
7. MetaMask muestra popup de confirmación
   ↓
8. Usuario confirma y firma transacción
   ↓
9. Transacción enviada a la blockchain
   ↓
10. Esperar confirmación (tx.wait())
    ↓
11. Mostrar resultado y actualizar balance
```

### Manejo de Errores Implementado

La aplicación maneja múltiples casos de error:

- **MetaMask no instalado**: Mensaje informativo
- **Red no soportada**: Lista de redes disponibles
- **Dirección inválida**: Validación con mensaje claro
- **Balance insuficiente**: Muestra balance actual vs requerido
- **Usuario rechaza transacción**: Mensaje amigable
- **ETH insuficiente para gas**: Notificación específica
- **Errores de red**: Captura y muestra error detallado

### Mejoras de UX/UI

- Estados visuales diferenciados (info, success, error)
- Mensajes de progreso durante transacciones
- Limpieza automática de formularios después de éxito
- Actualización automática de balance post-transferencia
- Logs detallados en consola para debugging
- Formato legible de direcciones (primeros y últimos caracteres)
- Colores según estado de la operación

### Consideraciones de Seguridad

#### ✅ Implementadas
- Validación de todas las entradas del usuario
- Verificación de balance antes de transacciones
- Uso de getAddress() para normalizar direcciones
- No se exponen claves privadas
- Todas las firmas se hacen en MetaMask

#### ⚠️ Consideraciones Adicionales
- En producción, agregar límites de rate limiting
- Implementar mejores mensajes de confirmación para grandes cantidades
- Validar contratos con herramientas como Etherscan
- Considerar usar multicall para operaciones batch

### Diferencias Clave: Ethers.js v5 vs v6

La aplicación usa Ethers.js v6, que tiene cambios importantes:

| Aspecto | v5 | v6 |
|---------|----|----|
| Provider Web | `Web3Provider` | `BrowserProvider` |
| Utilidades | `ethers.utils.*` | `ethers.*` |
| getSigner() | Síncrono | Asíncrono (`await`) |
| BigNumber | `balance.lt(amount)` | `balance < amount` |
| Formato de unidades | `utils.formatUnits` | `formatUnits` |
| Parse unidades | `utils.parseUnits` | `parseUnits` |
| Validar dirección | `utils.getAddress` | `getAddress` |

### Testing en Redes de Prueba

Para probar la aplicación necesitas:

1. **Configurar MetaMask en Sepolia**
   - Agregar red Sepolia
   - Obtener ETH de prueba del faucet

2. **Obtener USDC de Prueba**
   - Dirección del contrato: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`
   - Usar faucets o swaps de testnet
   - Verificar balance antes de transferir

3. **Tener ETH para Gas**
   - Cada transacción requiere gas
   - Mantener al menos 0.01 ETH en testnet

### Monitoreo de Transacciones

Después de enviar una transacción, puedes monitorizarla en:

- **Sepolia Etherscan**: https://sepolia.etherscan.io/
- Buscar por hash de transacción
- Verificar estado, gas usado, y eventos

### Próximas Mejoras Sugeridas

Para convertir esto en una DApp de producción:

1. **Backend opcional** (si necesitas funcionalidades privadas)
   - API REST con Node.js/Express
   - Base de datos para historial
   - Autenticación de usuarios

2. **Características adicionales**
   - Historial de transacciones del usuario
   - Allowance y approve para tokens
   - Swap de tokens
   - Staking y yield farming
   - Integración con múltiples wallets (WalletConnect)

3. **Mejoras de UI/UX**
   - Framework como React o Vue
   - Componentes reutilizables
   - Responsive design
   - Dark mode
   - Notificaciones toast

4. **Testing y Calidad**
   - Unit tests con Jest
   - Integration tests
   - E2E tests con Playwright
   - CI/CD pipeline

5. **Deployment**
   - Hosting en Vercel/Netlify
   - Dominio personalizado
   - SSL/HTTPS
   - CDN para assets

## 🔗 Referencias Útiles

- [Documentación oficial de Ethers.js](https://docs.ethers.org/)
- [MetaMask Developer Docs](https://docs.metamask.io/)
- [Ethereum Developer Resources](https://ethereum.org/en/developers/)

---

**Última actualización**: Septiembre 2025  
**Versión de Ethers.js**: 6.15.0