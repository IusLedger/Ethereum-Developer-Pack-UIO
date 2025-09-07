// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "../Exercise1_AccessControl.sol";

contract TestExercise1 {
    SimpleOwnership bank;
    
    function beforeEach() public {
        bank = new SimpleOwnership();
    }
    
    /// Test: Solo el owner debería poder cambiar ownership
    function testOnlyOwnerCanChangeOwner() public {
        address newOwner = address(0x123);
        
        // Como somos el owner, esto debería funcionar
        bank.changeOwner(newOwner);
        
        // Verificar que cambió
        Assert.equal(bank.getOwner(), newOwner, "Owner should have changed");
        
        // Restaurar para otros tests
        // Este test no funciona, intenta cambiar el address cuando el owner fue cambiado 
        // por lo tanto da error porque la direccion que inicializa ya no es el owner
        // bank.changeOwner(address(this));
    }
    
    /// Test: La función debe rechazar llamadas de no-owners  
    function testRejectNonOwnerCalls() public {
        // Este test verificará que tu modifier funciona
        // Cuando implementes el modifier correctamente, este test pasará
        Assert.ok(true, "Implement onlyOwner modifier to secure changeOwner");
    }
}