import { ethers } from 'ethers';
const documentData = "secret document";
// SHA-256
const sha256Hash = ethers.sha256(ethers.toUtf8Bytes(documentData));

// Keccak-256  
const keccak256Hash = ethers.keccak256(sha256Hash);
console.log(`final hash: ${keccak256Hash}`);