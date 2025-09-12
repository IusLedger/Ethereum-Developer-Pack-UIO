// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise2_InputValidation.sol";

contract TestExercise2 {
    SimpleDeposits bank;
    
    function beforeAll() public {
        bank = new SimpleDeposits();
    }
    
    /// Test: Depósitos válidos deben funcionar
    /// #value: 1000000000000000000
    function testValidDeposit() public payable {
        uint256 initialBalance = bank.getBalance();
        
        bank.deposit{value: 1 ether}();
        
        uint256 finalBalance = bank.getBalance();
        Assert.equal(finalBalance, initialBalance + 1 ether, "Valid deposit should work");
    }
    
    /// Test: Depósitos de 0 deben ser rechazados
    function testRejectZeroDeposit() public {
        try bank.deposit{value: 0}() {
            Assert.ok(false, "Should reject deposits of 0");
        } catch Error(string memory reason) {
            Assert.ok(true, "Correctly rejects zero deposits");
        } catch {
            Assert.ok(true, "Zero deposit rejected");
        }
    }
}