const chai = require("./setupchai.js");
const expect = chai.expect;
const error = new Error;

const RouterTokenSwap = artifacts.require("RouterTokenSwap");

contract("RouterTokenSwap DEX Test", function (accounts) {
    const [initialHolder, recipient, anotherAccount] = accounts;

    it("Can I add a new token route", async () => {     
        let instance = await RouterTokenSwap.deployed();

        let _symbol = "DAI";
        let _address = "0x95b58a6Bff3D14B7DB2f5cb5F0Ad413DC2940658";
        expect(await instance.addTokenRoute.call(_symbol, _address)).to.be.equal(true);
    });

    it("Can I remove a token route registered", async () => {     
        let instance = await RouterTokenSwap.deployed();

        let _symbol = "USDC";
        let _address = "0xeb8f08a975Ab53E34D8a0330E0D34de942C95926";
        await instance.addTokenRoute(_symbol, _address); 
        expect(await instance.removeTokenRoute.call(_symbol)).to.be.equal(true);
    });

    it("Can I swap any amount from token 1 to token 2", async () => {    
        let instance = await RouterTokenSwap.deployed();
       
        let amount = 1;   
        let _symbol1 = "DAI";  
        let _address1 = "0x95b58a6Bff3D14B7DB2f5cb5F0Ad413DC2940658";   
        await instance.addTokenRoute(_symbol1, _address1); 
        
        let _symbol2 = "USDT";
        let _address2 = "0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD";   
        await instance.addTokenRoute(_symbol2, _address2);    
        expect(await instance.swap.call(_address1, _address2, amount)).to.eventually.be.fulfilled;
    });
});