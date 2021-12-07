const IBTToken = artifacts.require("IBTToken");
const ProviderContract = artifacts.require("ProviderContract");
const KYCContract = artifacts.require("KYCContract");


const chai = require("./setupchai.js");
const BN = web3.utils.BN;
const expect = chai.expect;
const error = new Error;

require('dotenv').config({ path: '../.env' });

contract("ProviderContract Test", async function (accounts) {
    
    const [initialHolder, recipient, anotherAccount] = accounts;

    it("should not have any tokens in my deployerAccount", async() => {
        let instance = await IBTToken.deployed();
        return expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(new BN(0));
    });

    it("all tokens be in the ProviderContract Smart Contract by default", async() => {
        let instance = await IBTToken.deployed();
        let balanceOfTokenSaleSmartContract = await instance.balanceOf(ProviderContract.address);
        let totalSupply = await instance.totalSupply();
        expect(balanceOfTokenSaleSmartContract).to.be.a.bignumber.equal(totalSupply);
    });   

    it("Can I buy a new tokens", async () => {     
        let tokenInstance = await IBTToken.deployed();
        let tokenSaleInstance = await ProviderContract.deployed();
        let balanceBeforeAccount = await tokenInstance.balanceOf.call(recipient);         

        await tokenSaleInstance.addTransferRole(initialHolder); 
        
        await expect(tokenSaleInstance.sendTransaction.call({from: recipient, value: web3.utils.toWei("1", "wei")})).to.eventually.be.rejected;
        await expect(balanceBeforeAccount).to.be.bignumber.equal(await tokenInstance.balanceOf.call(recipient));        
       
        await tokenSaleInstance.sendTransaction({from: recipient, value: web3.utils.toWei("1", "wei")});
        await expect(balanceBeforeAccount + 1).to.be.bignumber.equal(await tokenInstance.balanceOf.call(recipient));
    });

    it("Can I set a new token price", async () => {
        let instance = await ProviderContract.deployed();
        let newPrice = 500;
        await expect(instance.setPrices(newPrice)).to.eventually.be.fulfilled;
    });

    it("Can I set a new token rate", async () => {
        let instance = await ProviderContract.deployed();
        let newRate = 100;
        await expect(instance.setRate(newRate)).to.eventually.be.fulfilled;
    });

    it("Can I sell a tokens", async () => {
        let instance = await ProviderContract.deployed();    
        const sendTokens = 10;
        const amount = 1;

        await instance.addTransferRole(initialHolder);  
        await instance.sendTransaction({from: initialHolder, value: web3.utils.toWei("1", "wei")});
        await expect(instance.sellTokens.call(sendTokens, { value: amount })).to.eventually.be.fulfilled;
    });

    it("Can I withdraw tokens to another address", async () => {
        let instance = await ProviderContract.deployed();    
        await expect(instance.withdrawMoneyTo(recipient, {from: initialHolder, value: web3.utils.toWei("1", "wei")})).to.be.fulfilled;
    });
});