

import { ethers } from "ethers";
const { JsonRpcProvider, parseEther, parseUnits } = ethers;
const provider = new JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8');
// Your wallet's private key (replace with your actual private key)
const privateKey = '86025bec599bee8a7302c836abb73aadbedd2df0d7f771b7f850efd65294ea03';

const wallet = new ethers.Wallet(privateKey, provider);
const recipientAddress = '0x2D35b11eF1C29F2F1E838ecF6Eab83F84B992D2b';
const amountToSend = '0.001'; // In ETH
async function main() {
    const tx = {
        to: recipientAddress,
        // Convert ETH to Wei 
        value: parseEther(amountToSend),
        gasLimit: 21000,
        gasPrice: parseUnits('10', 'gwei'),
    };
    try {
        console.log('Sending transaction...');
        const txResponse = await wallet.sendTransaction(tx);
        console.log(`Transaction hash: ${txResponse.hash}`);
        // Wait for the transaction to be mined
        const receipt = await txResponse.wait();
        console.log('Transaction confirmed in block:', receipt.blockNumber);
    } catch (error) {
        console.error('Transaction failed:', error);
    }
}
main();