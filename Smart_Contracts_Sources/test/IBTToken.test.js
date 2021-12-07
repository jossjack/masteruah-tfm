const IBTToken = artifacts.require("IBTToken");

const chai = require("./setupchai.js");
const BN = web3.utils.BN;
const expect = chai.expect;

require('dotenv').config({ path: '../.env' });

contract("Token IBT Test", function (accounts) {

    const [initialHolder, recipient, anotherAccount] = accounts;  

    beforeEach(async () => {
        this.myToken = await IBTToken.new(process.env.INITIAL_TOKENS);
    });

    it("all tokens should be in my account", async () => {
        let instance = this.myToken;
        let totalSupply = await instance.totalSupply();
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply);
    });

    it("I can send tokens from Account 1 to Account 2", async () => {
        const sendTokens = 1;
        let instance = this.myToken;
        let totalSupply = await instance.totalSupply();
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply);
        await expect(instance.transfer(recipient, sendTokens)).to.eventually.be.fulfilled;
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply.sub(new BN(sendTokens)));
        await expect(instance.balanceOf(recipient)).to.eventually.be.a.bignumber.equal(new BN(sendTokens));
    });

    it("It's not possible to send more tokens than account 1 has", async () => {
        let instance = this.myToken;
        let balanceOfAccount = await instance.balanceOf(initialHolder);
        await expect(instance.transfer(recipient, new BN(balanceOfAccount + 1))).to.eventually.be.rejected;
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(balanceOfAccount);
    });

    it("I can mint new tokens in account 1", async () => {
        const newTokens = 100;
        let instance = this.myToken;
        let totalSupply = await instance.totalSupply();      
        await expect(instance.mint(initialHolder, newTokens)).to.eventually.be.fulfilled;
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply.add(new BN(newTokens)));
    });

    it("I can burn tokens in account 1", async () => {
        const burnTokens = 100;
        let instance = this.myToken;
        let totalSupply = await instance.totalSupply();      
        await expect(instance.burn(initialHolder, burnTokens)).to.eventually.be.fulfilled;
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply.sub(new BN(burnTokens)));
    });
});