import { ethers } from "ethers";

// Only part of the ABI needed for this example
const abi = [
    {
        "inputs": [],
        "name": "createKittyGen0",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "kitties",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "genes",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "birthTime",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "momId",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "dadId",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "generation",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

// SimpleCryptoKitties deployed on sepolia
const address = '0x983236bE64Ef0f4F6440Fa6146c715CC721045fA';
// Ensure this account has enough balance to initiate transactions
const privateKey = '86025bec599bee8a7302c836abb73aadbedd2df0d7f771b7f850efd65294ea03';

const {JsonRpcProvider,formatUnits} = ethers;
async function main() {
    try {
        const provider = new JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/NhtK-EalUVBo1hkOh8G_kQljT3VOQEU8');
        const signer = new ethers.Wallet(privateKey, provider);
        const contract = new ethers.Contract(address, abi, signer);

        // Retrieve information of the kitty with ID 1
        const Kitty = await contract.kitties(1);
        // Genes: 8939624848462445358854850372772757587656232460263979629700006907634671281697
        console.log("Kitty 1 Genes:", Kitty.genes.toString());
        // BirthTime: 1715619696
        console.log("Kitty 1 BirthTime:", Kitty.birthTime.toString());
        console.log("Kitty 1 MomId:", Kitty.momId.toString());
        console.log("Kitty 1 DadId:", Kitty.dadId.toString());
        console.log("Kitty 1 Generation:", Kitty.generation.toString());

        // Get current gas price and set gas limit
        const feeData = await provider.getFeeData();
        console.log(`Current gas price: ${formatUnits(feeData.gasPrice, 'gwei')} gwei`);
        const gasLimit = 300000; 

        // Create a new Generation 0 kitty
        console.log("Attempting to create a new Generation 0 kitty...");
        const createTxResponse = await contract.createKittyGen0({ gasLimit, gasPrice: feeData.gasPrice });
        console.log("Transaction sent, waiting for receipt...");
        const receipt = await createTxResponse.wait();
        // console.log("Transaction receipt:", receipt);

        // Get newKitty's tokenId
        const newKittyId = ethers.toBigInt(receipt.logs[0].topics[3]);

        // Fetch the new kitty's details
        const newKitty = await contract.kitties(newKittyId.toString());
        console.log("New Kitty TokenId:", newKittyId.toString());
        console.log("New Kitty Genes:", newKitty.genes.toString());
        console.log("New Kitty BirthTime:", newKitty.birthTime.toString());
        console.log("New Kitty MomId:", newKitty.momId.toString());
        console.log("New Kitty DadId:", newKitty.dadId.toString());
        console.log("New Kitty Generation:", newKitty.generation.toString());
    } catch (error) {
        console.error("Error:", error);
    }
}

main();
