// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract IneffientStorage {
    uint256 public largeNumber;  // Usa 32 bytes ✓

    uint128 public mediumNumber; // Usa 32 bytes, desperdicia 16
    uint128 public anotherMedium;// Usa 32 bytes, desperdicia 16

    address public owner;        // Usa 32 bytes, desperdicia 12
    bool public isActive;        // Usa 32 bytes, desperdicia 31
    bool public isPaused;        // Usa 32 bytes, desperdicia 31

    // Before: 6 slots => Now: 3 slots
}