import { ethers } from "ethers";

// 1.
const contractABI = [
// ...
    {
        "constant": true,
        "inputs": [],
        "name": "name",
        "outputs": [
            {
                "name": "",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    }
// ...
];

// 2.
const contractABI = ["function name() view returns (string)"];

const contractAddress = "0x983236bE64Ef0f4F6440Fa6146c715CC721045fA";

async function main() {
    try {
        const provider = ethers.getDefaultProvider("sepolia");
        const readOnlyContract = new ethers.Contract(contractAddress, contractABI, provider);
        const name = await readOnlyContract.name();
        console.log("Token Name:", name);
    } catch (error) {
        console.error("Error in contract interaction:", error);
    }
}

main();