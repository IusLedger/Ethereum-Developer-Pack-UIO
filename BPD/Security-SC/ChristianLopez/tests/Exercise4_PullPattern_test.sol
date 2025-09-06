// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../contracts/Exercise4_PullPattern.sol";

contract TestExercise4 {
    SimpleEmergency bank;
    
    function beforeAll() public {
        bank = new SimpleEmergency();
    }
    
    /// Test: emergencyWithdraw debe marcar fondos como pendientes
    /// #value: 1000000000000000000
    function testEmergencyWithdrawPullPattern() public payable {
        // Depositar algo al contrato
        bank.deposit{value: 1 ether}();
        
        // Emergency withdraw no debería transferir directamente
        bank.emergencyWithdraw();
        
        // Debería existir una función para ver pending withdrawals
        try bank.getPendingWithdrawal() returns (uint256 pending) {
            Assert.ok(pending > 0, "Should have pending withdrawal after emergency");
        } catch {
            Assert.ok(false, "Should implement getPendingWithdrawal function");
        }
    }
    
    /// Test: Debe existir función withdrawPending
    function testWithdrawPendingExists() public {
        try bank.withdrawPending() {
            Assert.ok(true, "withdrawPending function exists");
        } catch {
            Assert.ok(false, "Should implement withdrawPending function");
        }
    }
}