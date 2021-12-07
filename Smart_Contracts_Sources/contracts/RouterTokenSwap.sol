// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract Router {
    function swapExactTokensForTokens(uint amount1, uint amount2, address[] calldata path, address to, uint deadline) external returns(uint[] memory amounts){}
}

contract RouterTokenSwap is Ownable {
    
    Router router;
    
    mapping(string => address) private tokens;
    
    //@tokenAdress allow to set the address of contract in which you can do SWAP of diferent tokens
    //Ethereum Uniswap V2: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //Polygon Quickswap: 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff
    constructor(address tokenAdress) {
       router = Router(tokenAdress);
    }
    
    function swap(string memory from_, string memory to_, uint amount) public {
        
        require(tokens[from_] != address(0), "The tokenFrom doesn't allowed");
        require(tokens[to_] != address(0), "The tokenTo doesn't allowed");
        require(tokens[from_] != tokens[to_], "Tokens must be different");
        
        ERC20 tokenFrom = ERC20(tokens[from_]);
        ERC20 tokenTo = ERC20(tokens[to_]);
        
        tokenFrom.transferFrom(msg.sender, address(this), amount);

        address[] memory path = new address[](2);
        path[0] = address(tokenFrom);
        path[1] = address(tokenTo);

        tokenFrom.approve(address(router), amount);

        router.swapExactTokensForTokens(amount, 0, path, msg.sender, block.timestamp);
    }
    
    function addTokenRoute(string memory _symbol, address _address) public onlyOwner returns(bool) {
        bool isAddedToListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(tokens[_symbol] == address(0), "This Token is already registered!");
        
        tokens[_symbol] = _address;
        
        isAddedToListFlag = true;
        return isAddedToListFlag;
    }
    
    function removeTokenRoute(string memory _symbol) public onlyOwner returns(bool) {
        bool isAddedToListFlag = false;
        
        require(tokens[_symbol] != address(0), "This Token is not registered!");
        
        delete tokens[_symbol];
        
        isAddedToListFlag = true;
        return isAddedToListFlag;
    }
}