// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    address public user1;
    address public user2;

    // Se ejecuta antes de cada test
    function setUp() public {
        vault = new Vault();
        user1 = address(0x1);
        user2 = address(0x2);
    }

    // Test básico de deposit
    function test_Deposit() public {
        vm.prank(user1);
        vault.deposit(100);
        
        assertEq(vault.balances(user1), 100);
        assertEq(vault.totalDeposits(), 100);
    }

    // Test de múltiples deposits
    function test_MultipleDeposits() public {
        vm.prank(user1);
        vault.deposit(100);
        
        vm.prank(user1);
        vault.deposit(50);
        
        assertEq(vault.balances(user1), 150);
        assertEq(vault.totalDeposits(), 150);
    }

    // Test de deposits de diferentes usuarios
    function test_MultipleUsers() public {
        vm.prank(user1);
        vault.deposit(100);
        
        vm.prank(user2);
        vault.deposit(200);
        
        assertEq(vault.balances(user1), 100);
        assertEq(vault.balances(user2), 200);
        assertEq(vault.totalDeposits(), 300);
    }

    // Test de withdraw exitoso
    function test_Withdraw() public {
        vm.prank(user1);
        vault.deposit(100);
        
        vm.prank(user1);
        vault.withdraw(30);
        
        assertEq(vault.balances(user1), 70);
        assertEq(vault.totalDeposits(), 70);
    }

    // Test de withdraw completo
    function test_WithdrawAll() public {
        vm.prank(user1);
        vault.deposit(100);
        
        vm.prank(user1);
        vault.withdraw(100);
        
        assertEq(vault.balances(user1), 0);
        assertEq(vault.totalDeposits(), 0);
    }

    // Test con expectRevert cuando no hay balance suficiente
    function test_RevertWhen_InsufficientBalance() public {
        vm.prank(user1);
        vault.deposit(50);
        
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        vault.withdraw(100);
    }

    // Test con expectRevert cuando intenta withdraw sin depositar
    function test_RevertWhen_WithdrawWithoutDeposit() public {
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        vault.withdraw(100);
    }

    // Test de getBalance
    function test_GetBalance() public {
        vm.prank(user1);
        vault.deposit(100);
        
        uint256 balance = vault.getBalance(user1);
        assertEq(balance, 100);
    }

    // Test de eventos: Deposited
    function test_DepositEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Vault.Deposited(user1, 100);
        
        vm.prank(user1);
        vault.deposit(100);
    }

    // Test de eventos: Withdrawn
    function test_WithdrawEvent() public {
        vm.prank(user1);
        vault.deposit(100);
        
        vm.expectEmit(true, false, false, true);
        emit Vault.Withdrawn(user1, 50);
        
        vm.prank(user1);
        vault.withdraw(50);
    }

    // Fuzz testing: deposit con cantidades aleatorias
    function testFuzz_Deposit(uint256 amount) public {
        vm.assume(amount > 0 && amount < type(uint256).max);
        
        vm.prank(user1);
        vault.deposit(amount);
        
        assertEq(vault.balances(user1), amount);
        assertEq(vault.totalDeposits(), amount);
    }

    // Fuzz testing: withdraw
    function testFuzz_Withdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        vm.assume(depositAmount > 0 && depositAmount < type(uint256).max / 2);
        vm.assume(withdrawAmount > 0 && withdrawAmount <= depositAmount);
        
        vm.prank(user1);
        vault.deposit(depositAmount);
        
        vm.prank(user1);
        vault.withdraw(withdrawAmount);
        
        assertEq(vault.balances(user1), depositAmount - withdrawAmount);
    }

    // Test de estado inicial
    function test_InitialState() public view {
        assertEq(vault.totalDeposits(), 0);
        assertEq(vault.balances(user1), 0);
        assertEq(vault.balances(user2), 0);
    }

    // Test de deposit con valor 0
    function test_DepositZero() public {
        vm.prank(user1);
        vault.deposit(0);
        
        assertEq(vault.balances(user1), 0);
        assertEq(vault.totalDeposits(), 0);
    }
}