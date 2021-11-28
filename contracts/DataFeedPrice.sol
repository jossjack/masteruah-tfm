// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DataFeedPrice is Ownable {

    AggregatorV3Interface internal priceFeed;
    address public stakePriceOracle;
    
    event OracleChanged(address newOracle);

    constructor() {
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }
    
    function setOracle(address _oracle) public onlyOwner {
        priceFeed = AggregatorV3Interface(_oracle);
        emit OracleChanged(_oracle);
    }

    function getPriceETHtoUSD(uint8 _decimals) public view returns (int256) {
        require(_decimals > uint8(0) && _decimals <= uint8(18), "Invalid _decimals");
        ( , int price , , , ) = priceFeed.latestRoundData();
        int256 _price = scalePrice(price, 8, _decimals);
        return _price;
    }
    
    /**
     * Network: Rinkeby
     * Base: ETH/USD
     * Base Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     * Quote: EUR/USD
     * Quote Address: 0x78F9e60608bF48a1155b4B2A5e31F32318a1d85F
     * Decimals: 8
     * Output: ETH/EUR
     */
    function getDerivedPrice(address _base, address _quote, uint8 _decimals) public view returns (int256) {
        require(_decimals > uint8(0) && _decimals <= uint8(18), "Invalid _decimals");
        int256 decimals = int256(10 ** uint256(_decimals));
        ( , int256 basePrice, , , ) = AggregatorV3Interface(_base).latestRoundData();
        uint8 baseDecimals = AggregatorV3Interface(_base).decimals();
        basePrice = scalePrice(basePrice, baseDecimals, _decimals);

        ( , int256 quotePrice, , , ) = AggregatorV3Interface(_quote).latestRoundData();
        uint8 quoteDecimals = AggregatorV3Interface(_quote).decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimals, _decimals);

        return basePrice * decimals / quotePrice;
    }
    
    function scalePrice(int256 _price, uint8 _priceDecimals, uint8 _decimals) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }
}