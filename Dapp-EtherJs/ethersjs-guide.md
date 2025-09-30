# Primeros pasos con Ethers.js

Ethers.js es una biblioteca de JavaScript que permite a los desarrolladores interactuar fácilmente con la cadena de bloques Ethereum y su ecosistema.

## Instalación

Ethers.js está disponible como un paquete npm y se puede instalar ejecutando:

```bash
npm install --save ethers
```

O incluir su CDN en un documento HTML como el siguiente:

```html
<script
  src="https://cdn.ethers.io/lib/ethers-5.2.umd.min.js"
  type="application/javascript">
</script>
```

Si está trabajando con Node.js, puede importar el paquete Ethers en su proyecto con:

```javascript
const { ethers } = require("ethers");
```

Para un proyecto basado en ES6 o TypeScript, puede importarlo con:

```javascript
import { ethers } from "ethers";
```

De lo contrario, si ha incluido la CDN en su marcado, no se necesita ningún esfuerzo adicional para importar, ya que el paquete Ethers se carga automáticamente.

## Términos comunes

Algunos términos comunes que encontrará mientras trabaja con Ethers.js incluyen:

- **Proveedor**: esta es una clase en Ethers.js que proporciona acceso abstracto de solo lectura a la cadena de bloques Ethereum y su estado
- **Firmante**: esta es una clase en Ethers con acceso a su clave privada. Esta clase es responsable de firmar mensajes y autorizar transacciones que incluyen cargar Ether de su cuenta para realizar operaciones
- **Contrato**: esta clase es responsable de la conexión a contratos específicos en la red Ethereum

## Conexión a MetaMask

MetaMask es una billetera para almacenar criptomonedas y también sirve como puerta de entrada para conectarse a aplicaciones basadas en blockchain. Si aún no lo ha hecho, diríjase a su página de descarga para descargar la extensión web para su navegador preferido.

Después de configurar MetaMask, tenemos acceso a la API global de Ethereum, a la que se puede acceder a través de `window.ethereum`.

Puedes conectarte fácilmente a MetaMask con Ethers.js creando un nuevo proveedor Web3 y pasando la API global de Ethereum como parámetro, como se muestra a continuación:

```javascript
const provider = new ethers.providers.Web3Provider(window.ethereum)
```

Para probar esto, cree un nuevo archivo `index.html` y agregue el siguiente código:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <script
      src="https://cdn.ethers.io/lib/ethers-5.2.umd.min.js"
      type="application/javascript"
    ></script>
    <script>
      const provider = new ethers.providers.Web3Provider(
        window.ethereum,
        "any"
      );
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();

      (async function () {
        let userAddress = await signer.getAddress();
        document.getElementById("wallet").innerText =
          "Your wallet is " + userAddress;
      })();
    </script>
  </head>
  <body>
    <div id="wallet"></div>
  </body>
</html>
```

En el código anterior, después de incluir el CDN Ethers.js, creamos una conexión a MetaMask y la asignamos a una variable constante `provider`, y luego, creamos una función asíncrona de autoinvocación que habíamos usado para obtener nuestra cuenta MetaMask conectada.

Al ejecutar el código, se abrirá una nueva conexión de MetaMask, y una vez que la conexión sea exitosa, debería ver la dirección de su billetera en la página.

## Consulta de la cadena de bloques de Ethereum

Con la clase `provider`, tenemos acceso de solo lectura a los datos de la cadena de bloques, y con esto, podemos obtener el estado actual de la cadena de bloques, leer registros históricos y mucho más.

Por ejemplo, podemos usar el método asíncrono `getBlockNumber()` para obtener el bloque minado actual en la cadena de bloques de Ethereum:

```javascript
const provider = new ethers.providers.Web3Provider(window.ethereum)
async function getCurrentBlock() {
  let currentBlock = await provider.getBlockNumber();
  console.log(currentBlock);
}

getCurrentBlock();
// returns 13344639
```

O el método `getBalance()`, para obtener la cantidad de Ether disponible en una dirección específica:

```javascript
const provider = new ethers.providers.Web3Provider(window.ethereum)

async function getBalance(wallet) {
  let balance = await provider.getBalance(wallet);
  // we use the code below to convert the balance from wei to eth
  balance = ethers.utils.formatEther(balance);
  console.log(balance);
}

getBalance("0xC7CF72918D9a7101D2333538686E389b15ad8F2E");
// returns 0.3
```

Visite [aquí](https://docs.ethers.io/v5/api/providers/) para obtener una referencia completa de todos los métodos disponibles en la clase de proveedor.

## Firmar mensajes

Firmar mensajes en la cadena de bloques significa crear firmas digitales. Estas firmas digitales se utilizan para demostrar la propiedad de una dirección sin exponer su clave privada.

Podemos hacer esto fácilmente con Ethers.js utilizando el método `signMessage()` disponible en la clase de firmante:

```javascript
let mySignature = await signer.signMessage("Some custom message");
```

## Construyendo nuestra DApp

Para comenzar, visite este repositorio de GitHub y siga las instrucciones en el archivo README del repositorio para configurar la rama frontend del proyecto en su máquina local. Este repositorio contiene todos los archivos que necesitamos para crear nuestra DApp, así como el código de marcado para la interfaz de usuario, pero aún no se ha agregado ninguna funcionalidad.

Si siguió el proceso de instalación con éxito y ejecutó el archivo `index.html`, debería tener una salida similar a la imagen a continuación.

### Obtener ETH gratis

Para realizar cualquier transacción en la cadena de bloques de Ethereum, se nos cobrará algo de ether, también conocido como tarifa de gas. Y, dado que se trata de un proyecto de prueba, no queremos pagar dinero real para ejecutar transacciones. Para obtener ETH de prueba gratis, abra MetaMask y cambie la red a red de prueba ropsten, copie la dirección de su billetera y, finalmente, envíe su billetera en ropsten faucet para obtener 0.3 ETH gratis.

### Acuñación de USDC

Dado que estamos construyendo una DApp que nos permite transferir USDC, primero queremos acuñar algunos para nosotros, desde nuestro saldo de ETH. Para hacer esto, abra el archivo `/script/mint-usdc.js` y actualícelo con el siguiente contenido:

```javascript
const provider = new ethers.providers.Web3Provider(window.ethereum, "any");

const usdc = {
  address: "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
  abi: [
    "function gimmeSome() external",
    "function balanceOf(address _owner) public view returns (uint256 balance)",
    "function transfer(address _to, uint256 _value) public returns (bool success)",
  ],
};

async function mintUsdc() {
  await provider.send("eth_requestAccounts", []);
  const signer = provider.getSigner();
  let userAddress = await signer.getAddress();
  const usdcContract = new ethers.Contract(usdc.address, usdc.abi, signer);

  const tx = await usdcContract.gimmeSome({ gasPrice: 20e9 });
  console.log(`Transaction hash: ${tx.hash}`);

  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
  console.log(`Gas used: ${receipt.gasUsed.toString()}`);
}
```

A continuación, guarde este archivo y ejecute el archivo `mint-usdc.html` disponible en nuestra carpeta raíz. Ahora, si hace clic en el botón Acuñar ahora en esta página, esto debería generar una nueva solicitud de MetaMask, y la confirmación de esta solicitud acuñará 10 USDC en nuestra billetera, así como el hash de la transacción y la tarifa de gas utilizada para la solicitud impresa en nuestra consola.

### Visualización del saldo de USDC

Ahora que hemos acuñado algo de USDC, sigamos adelante y mostrémoslo en el área designada en nuestro marcado. Para hacer esto, ábralo `/script/app.js` y actualícelo con el siguiente código:

```javascript
const provider = new ethers.providers.Web3Provider(window.ethereum, "any");

const usdc = {
  address: "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
  abi: [
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function gimmeSome() external",
    "function balanceOf(address _owner) public view returns (uint256 balance)",
    "function transfer(address _to, uint256 _value) public returns (bool success)",
  ],
};

async function main() {
  await provider.send("eth_requestAccounts", []);
  const signer = provider.getSigner();
  let userAddress = await signer.getAddress();
  document.getElementById("userAddress").innerText = userAddress;

  const usdcContract = new ethers.Contract(usdc.address, usdc.abi, signer);

  let usdcBalance = await usdcContract.balanceOf(userAddress);
  usdcBalance = ethers.utils.formatUnits(usdcBalance, 6);
  document.getElementById("usdcBalance").innerText = usdcBalance;
}
main();
```

Aquí, usamos la función `balanceOf()` disponible en el USDC ABI mientras pasábamos nuestra dirección. Y tal como se mencionó en la sección de inicio, el saldo se devolverá en Wei, por lo que usamos la función de utilidad Ethers.js para convertirlo de Wei a ETH y mostramos el resultado en nuestro `div` con un id `usdcBalance`.

Ahora, si ejecutamos `index.html`, deberíamos ver nuestro saldo de USDC, así como nuestra billetera, en su sección designada.

### Adición de funcionalidad de transferencia

El último paso es agregar la funcionalidad de transferencia. Abra `script/transfer-usdc.js` y actualice su contenido con el siguiente código:

```javascript
async function transferUsdc() {
    let receiver = document.getElementById("receiver").value;
    let amount = document.getElementById("amount").value;
    let response;
  
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    let userAddress = await signer.getAddress();
  
    const usdcContract = new ethers.Contract(usdc.address, usdc.abi, signer);
  
    try {
      receiver = ethers.utils.getAddress(receiver);
    } catch {
      response = `Invalid address: ${receiver}`;
      document.getElementById("transferResponse").innerText = response;
      document.getElementById("transferResponse").style.display = "block";
    }
  
    try {
      amount = ethers.utils.parseUnits(amount, 6);
      if (amount.isNegative()) {
        throw new Error();
      }
    } catch {
      console.error(`Invalid amount: ${amount}`);
      response = `Invalid amount: ${amount}`;
      document.getElementById("transferResponse").innerText = response;
      document.getElementById("transferResponse").style.display = "block";
    }
  
    const balance = await usdcContract.balanceOf(userAddress);
  
    if (balance.lt(amount)) {
      let amountFormatted = ethers.utils.formatUnits(amount, 6);
      let balanceFormatted = ethers.utils.formatUnits(balance, 6);
      console.error(
        `Insufficient balance receiver send ${amountFormatted} (You have ${balanceFormatted})`
      );
  
      response = `Insufficient balance receiver send ${amountFormatted} (You have ${balanceFormatted})`;
      document.getElementById("transferResponse").innerText = response;
      document.getElementById("transferResponse").style.display = "block";
    }
    let amountFormatted = ethers.utils.formatUnits(amount, 6);
  
  
    response = `Transferring ${amountFormatted} USDC receiver ${receiver.slice(
      0,
      6
    )}...`;
    document.getElementById("transferResponse").innerText = response;
    document.getElementById("transferResponse").style.display = "block";
  
    const tx = await usdcContract.transfer(receiver, amount, { gasPrice: 20e9 });
    document.getElementById(
      "transferResponse"
    ).innerText += `Transaction hash: ${tx.hash}`;
  
    const receipt = await tx.wait();
    document.getElementById(
      "transferResponse"
    ).innerText += `Transaction confirmed in block ${receipt.blockNumber}`;
  }
```

### Explicación del código

El código se explica por sí mismo. Primero, obtuvimos la entrada requerida (billetera y monto del receptor) de nuestro formulario, y después de crear nuestro contrato, verificamos si la dirección ingresada es válida y también si el usuario tenía una cantidad suficiente. Y finalmente, utilizando el método `transfer()` de nuestro ABI, iniciamos la transferencia.

## ¡Y nuestra aplicación está lista para funcionar!

Puedes probarlo creando una nueva cuenta en MetaMask y transfiriendo algo de USDC a ella.

Además, el código fuente completo está disponible aquí en GitHub, en caso de que te hayas saltado algún paso.