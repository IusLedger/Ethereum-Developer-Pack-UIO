import { ethers } from 'ethers';
const { toUtf8Bytes, encodeRlp, toBeHex } = ethers;
// transactionData 
const transactionData = {
    assetId: 1,
    owner: '0xBf49Bd2B2c2f69c53A40306917112945e27577A4',
    description: "fantastic token"
};
// Encode as a hexadecimal string
const assetIdHex = toBeHex(BigInt(transactionData.assetId));
const owner = toBeHex(BigInt(transactionData.owner));
// Convert to UTF-8 bytes
const descriptionBytes = toUtf8Bytes(transactionData.description);
// RLP encode the complete transaction data
const rlpEncodedTransaction = encodeRlp([assetIdHex, owner, descriptionBytes]);
console.log(`RLP encoded transaction data: ${rlpEncodedTransaction}`);