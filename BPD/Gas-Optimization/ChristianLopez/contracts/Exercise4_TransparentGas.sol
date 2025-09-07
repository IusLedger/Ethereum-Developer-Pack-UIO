// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TransparentGasContract {
    mapping(address => uint256) public balances;
    
    uint256 public constant BASE_GAS = 21000;
    uint256 public constant GAS_PER_TRANSFER = 15000;
    uint256 public constant MAX_GAS_LIMIT = 300000;
    
    constructor() {
        balances[msg.sender] = 1000000; // Balance inicial para pruebas
    }
    
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "Arrays must match");
        
        for(uint i = 0; i < recipients.length; i++) {
            require(balances[msg.sender] >= amounts[i], "Insufficient balance");
            balances[msg.sender] -= amounts[i];
            balances[recipients[i]] += amounts[i];
        }
    }
    
    function safeBatchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        (bool viable, string memory reason) = isOperationViable(recipients.length);
        require(viable, reason);

        batchTransfer(recipients, amounts);
    }
    
    function estimateBatchTransferGas(uint256 transferCount) public pure returns (uint256) {
        return BASE_GAS + transferCount * GAS_PER_TRANSFER;
    }
    
    function getOperationCost(uint256 transferCount, uint256 gasPriceGwei) public pure returns
        (uint256 gasEstimate, uint256 costWei, uint256 costGwei, uint256 costEther) {
        
        gasEstimate = estimateBatchTransferGas(transferCount);
        costWei = gasEstimate * gasPriceGwei * 1e9;
        costGwei = gasEstimate * gasPriceGwei;
        costEther = gasEstimate * gasPriceGwei / 1e9;

        return (gasEstimate, costWei, costGwei, costEther);
    }
    
    function isOperationViable(uint256 transferCount) public pure returns (bool viable, string memory reason) {
        if (transferCount < 1) {
            return (false, "Empty operations are not permitted");
        }
        
        uint256 estimatedGas = estimateBatchTransferGas(transferCount);

        if (estimatedGas <= MAX_GAS_LIMIT) {
            return (true, "Operation cost acceptable");
        }

        return (false, "Operation too expensive");
    }
    
    // Funciones auxiliares para testing
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
    
    function setBalance(address user, uint256 amount) public {
        balances[user] = amount;
    }
    
    function getMultiplePriceEstimates(uint256 transferCount) 
        public pure returns (
            uint256 gasEstimate,
            uint256 lowCost,    // 20 gwei
            uint256 mediumCost, // 50 gwei  
            uint256 highCost    // 100 gwei
        ) {

        gasEstimate = estimateBatchTransferGas(transferCount);
        lowCost = gasEstimate * 20 * 1e9;
        mediumCost = gasEstimate * 50 * 1e9;
        highCost = gasEstimate * 100 * 1e9;
        
        return (gasEstimate, lowCost, mediumCost, highCost);
    }
    
    function getMaxTransfersForBudget(uint256 gasBudget) public pure returns (uint256) {
        if (gasBudget <= BASE_GAS) {
            return 0;
        }
        return (gasBudget - BASE_GAS) / GAS_PER_TRANSFER;
    }
}
