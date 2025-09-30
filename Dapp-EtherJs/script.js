import { ethers } from './node_modules/ethers/dist/ethers.esm.min.js';

window.addEventListener('load', async function () {
  console.log("Ethers cargado:", ethers);
  
  if (typeof window.ethereum === 'undefined') {
    document.getElementById("wallet").innerText = 
      "⚠️ Por favor instala MetaMask!";
    return;
  }

  try {
    const provider = new ethers.providers.Web3Provider(
      window.ethereum,
      "any"
    );
    
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    
    let userAddress = await signer.getAddress();
    document.getElementById("wallet").innerText =
      "✅ Your wallet is: " + userAddress;
      
    console.log("Conectado a:", userAddress);
  } catch (error) {
    console.error("Error:", error);
    document.getElementById("wallet").innerText = 
      "❌ Error: " + error.message;
  }
});