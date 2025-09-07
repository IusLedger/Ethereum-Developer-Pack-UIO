// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract IneffientAirdrop {
    mapping(address => uint256) public balances;
    uint256 public totalSupply = 1000000;
    uint256 public constant MAX_GAS_LIMIT = 15000000;
    
    function airdrop(address[] memory recipients, uint256 amount) public {
        require(recipients.length <= 50, "Too many recipients");
        require(estimateAirdropGas(recipients.length) < MAX_GAS_LIMIT, "Function would exceed gas limit.");

        for(uint i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amount;
            totalSupply += amount;
        }
    }

    function estimateAirdropGas(uint256 recipientCount) public pure returns (uint256) {
        return 30000 + 20000 * recipientCount;
    }
}