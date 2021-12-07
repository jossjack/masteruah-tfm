
const chai = require("./setupchai.js");
const expect = chai.expect;
const error = new Error;

const DataFeedPrice = artifacts.require("DataFeedPrice");

contract("DataFeedPrice Test", function (accounts) {
    const [initialHolder, recipient, anotherAccount] = accounts;

    it("Can I get the price of the ETH from oracle", async () => {
        let instance = await DataFeedPrice.deployed();
        let _decimals = 18;   
        let _price = await instance.getPriceETHtoUSD(_decimals);
        expect(_price > 0).to.be.equal(true);
    });

    it("Can I get the price of the ETH in ETH/EUR from oracle", async () => {
        let instance = await DataFeedPrice.deployed();
        let _decimals = 8;
        let _base = "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e";
        let _quote = "0x78F9e60608bF48a1155b4B2A5e31F32318a1d85F";        
        let _price = await instance.getDerivedPrice(_base, _quote, _decimals);
        expect(_price > 0).to.be.equal(true);
    });
});