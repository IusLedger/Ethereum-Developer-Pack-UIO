import { ethers } from 'ethers';
const { JsonRpcProvider,formatUnits,parseUnits } = ethers;

const provider = new JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8');
//const provider = ethers.getDefaultProvider("sepolia");
const accountAddress = "0xBf49Bd2B2c2f69c53A40306917112945e27577A4";
async function main() {
    try {
        // Convert small units to large units
        // For example, the balance returned is in wei, which is not easy to read, so it should be converted to ether units
        const balance = await provider.getBalance(accountAddress);
        console.log(`Balance in Ether: ${formatUnits(balance, "ether")}`);
        // Convert large units to small units
        // For example, if a user inputs 0.05 ether, it should be converted to the machine-readable Wei units for processing
        const transactionAmount = parseUnits("0.05", "ether");
        console.log(`0.05 Ether in Wei: ${transactionAmount.toString()}`);
    } catch (error) {
        console.error('Error fetching:', error);
    }
}
main();