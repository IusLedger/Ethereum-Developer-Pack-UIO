// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SecureBank {
    // TODO: Agregar todas las variables necesarias
    // Pista: balances, owner, pendingWithdrawals, locked (para nonReentrant)
    mapping(address => uint256) private balances;
    mapping(address => uint256) private pendingWithdrawals;
    address private owner;
    uint256 private totalFunds;
    bool private locked;
    
    constructor() {
        // TODO: Inicializar owner
        owner = msg.sender;
        locked = false;
    }
    
    // TODO: Implementar modifier onlyOwner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // TODO: Implementar modifier nonReentrant
    // Pista: usar variable locked para prevenir reentrada
    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    function deposit() public payable {
        // TODO: Implementar con validación de entrada
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
        totalFunds += msg.value;
    }
    
    function withdraw(uint256 amount) public nonReentrant{
        // TODO: Implementar con patrón CEI y nonReentrant
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Must withdrawl more than 0");
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        totalFunds -= amount;
    }
    
    function initiateWithdrawal(uint256 amount) public nonReentrant{
        // TODO: Implementar patrón pull - paso 1
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Must withdrawl more than 0");
        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;

    }
    
    function withdrawPending() public {
        // TODO: Implementar patrón pull - paso 2
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawal");
        pendingWithdrawals[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        totalFunds -= amount;
    }
    
    function emergencyWithdraw() public onlyOwner{
        // TODO: Implementar con onlyOwner y patrón pull
        uint256 amount = address(this).balance;
        pendingWithdrawals[owner] += amount;
    }
    
    function adminTransfer(address from, address to, uint256 amount) public onlyOwner nonReentrant {
        // TODO: Implementar con onlyOwner y validaciones completas
        require(from != address(0), "Invalid from address");
        require(to != address(0), "Invalid to address");
        require(from != to, "Cannot transfer to self");
        
        require(amount > 0, "Invalid amount");
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;
    }
    
    // TODO: Implementar funciones view necesarias
    // getBalance(), getPendingWithdrawal(), getOwner(), getTotalFunds()
        function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getPendingWithdrawal() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getTotalFunds() public view returns(uint256){
        return address(this).balance;
    }
    
}