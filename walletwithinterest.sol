// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface cETH {
    
    // define functions of COMPOUND we'll be using
    
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    
    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract SmartAccount {
    
    uint totalContractBalance = 0;
    
    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);
    
    function getContractBalance() public view returns(uint) {
        return totalContractBalance;
    }
    
    mapping(address => uint) balances; 
    mapping(address => uint) depositTimestamps;
    
    function addBalance() public payable {
        uint256 cEthContractBeforeMinting = ceth.balanceOf(address(this));
        // send ethers to mint()
        ceth.mint{value: msg.value}();
        
        uint256 cEthContractAfterMinting = ceth.balanceOf(address(this));
        
        uint ethofUserC = cEthContractAfterMinting - cEthContractBeforeMinting;
        balances[msg.sender] = ethofUserC;
    }
    
    function getBalance(address userAddress) public view returns(uint) {
        return ceth.balanceOf(userAddress) * ceth.exchangeRateStored() / 1e18;
    }
    
    function getcETHbalance() public view returns (uint) {
        return (ceth.balanceOf(address(this))*ceth.exchangeRateStored() - ceth.balanceOf(address(this))) / 1e18;
    }
    
    function withdraw() public payable {
        address payable withdrawTo = payable(msg.sender);
        uint withdrawAmount = getBalance(msg.sender);
        
        totalContractBalance += balances[msg.sender];
        balances[msg.sender] = 0;
        ceth.redeem(withdrawAmount);
        withdrawTo.transfer(withdrawAmount);
    }
    
    fallback () external payable {
        
    }
    
    receive () external payable {
        
    }
    
    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }
    
}
