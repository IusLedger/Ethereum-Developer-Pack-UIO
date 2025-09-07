// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../Exercise3_CEIPattern.sol";

contract TestExercise3 {
    SimpleWithdrawals bank;

    receive() external payable {}
    
    function beforeEach() public {
        bank = new SimpleWithdrawals();
    }
    
    /// Test: Withdraw debe actualizar balance correctamente
    /// #value: 2000000000000000000
    function testWithdrawUpdatesBalance() public payable {
        // Depositar primero
        bank.deposit{value: 1 ether}();
        uint256 balanceAfterDeposit = bank.getBalance();
        
        // Retirar la mitad
        bank.withdraw(0.5 ether);
        uint256 balanceAfterWithdraw = bank.getBalance();
        
        // El balance debe haberse actualizado correctamente
        Assert.equal(balanceAfterWithdraw, balanceAfterDeposit - 0.5 ether, "Balance should update correctly");
    }
    
    /// Test: Withdraw no debe permitir retirar más del balance
    /// #value: 1000000000000000000  
    function testWithdrawValidation() public payable {
        bank.deposit{value: 0.5 ether}();
        
        try bank.withdraw(1 ether) {
            Assert.ok(false, "Should not allow overdraw");
        } catch {
            Assert.ok(true, "Correctly prevents overdraw");
        }
    }
}