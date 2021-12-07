const chai = require("./setupchai.js");
const expect = chai.expect;
const error = new Error;

const KYCContract = artifacts.require("KYCContract");

contract("KYCContract Test", function (accounts) {
    const [initialHolder, recipient, anotherAccount] = accounts;

    it("Can I add a new bank in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let name = "BANCO ECUADOR A";
        let _address = "0x1c7D3Eef242473c2C9d3aDe0B21caE7251aec1F8";
        let _identifier = "EC-PAC01";
        expect(await instance.addBank.call(name, _address, _identifier)).to.be.equal(true);
    });

    it("Can I change the bank address by another in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let name = "BANCO ECUADOR B";
        let _address = "0xa1b66127Fa2C8A6d7871FaB4aCCB5e12C548759b";
        let _identifier = "EC-PAC01";

        let _newAddress = '0x92fe4ecB478689A4c3950914DFF892f30960Fab9';
        await instance.addBank(name, _address, _identifier);
        expect(await instance.updateBankAddress.call(_address, _newAddress)).to.be.equal(true);
    });

    it("Can I remove an existent bank from my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let name = "BANCO ECUADOR C";
        let _address = "0x7E607013549291e1464C7e714Ecef34d1ff9387d";
        let _identifier = "EC-PAC02";
        await instance.addBank(name, _address, _identifier);
        let bank = await instance.getBankDetails(_address);
        expect(bank.bankAddress).to.be.equal(_address);       
        expect(await instance.removeBank.call(_address)).to.be.equal(true);
    });

    it("Can I validate a duplicate bank in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();   
        
        let name1 = "BANCO ECUADOR A";
        let _address1 = "0x92fe4ecB478689A4c3950914DFF892f30960Fab9";
        let _identifier1 = "EC-PAC03";
        await instance.addBank(name1, _address1, _identifier1);

        let name2 = "BANCO ECUADOR B";
        let _address2 = "0x92fe4ecB478689A4c3950914DFF892f30960Fab9";
        let _identifier2 = "EC-PAC04";

        await expect(instance.addBank.call(name2, _address2, _identifier2)).to.be.eventually.rejectedWith('This Bank is already exist!');
    });

    it("Can I add a new customer with ICAP in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let _identifier = "XE36IBTPAC1ECGYE0001";
        let _address = "0x1c7D3Eef242473c2C9d3aDe0B21caE7251aec1F8";
        let _bankAddress= "0x92fe4ecB478689A4c3950914DFF892f30960Fab9";
        expect(await instance.addCustomer.call(_identifier, _address, _bankAddress)).to.be.equal(true);
    });

    it("Validate a new customer with ICAP in which Bank not exist in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let _identifier = "XE36IBTPAC1ECGYE0001";
        let _address = "0x1c7D3Eef242473c2C9d3aDe0B21caE7251aec1F8";
        let _fakeBankAddress= "0xe96733F411A086543B5D550B42Ab3853131c03c8";
        await expect(instance.addCustomer.call(_identifier, _address, _fakeBankAddress)).to.be.eventually.rejectedWith('This Bank is not exist!');
    });

    it("Can I remove an existent customer from my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let _identifier = "XE36IBTPAC1ECGYE0001";
        let _address = "0x1c7D3Eef242473c2C9d3aDe0B21caE7251aec1F8";
        let _bankAddress= "0x92fe4ecB478689A4c3950914DFF892f30960Fab9";
        await instance.addCustomer(_identifier, _address, _bankAddress);
        let customer = await instance.getCustomerDetails(_address);
        expect(customer.customerAddress).to.be.equal(_address);       
        expect(await instance.removeCustomer.call(_address)).to.be.equal(true);
    });

    it("Get ICAP from customer in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();
        let _identifier = "XE36IBTPAC1ECGYE0001";   

        let customerAddress = await instance.getCustomerAddressFromICAP(_identifier);
        let customer = await instance.getCustomerDetails(customerAddress);
        expect(customer.addressICAP).to.be.equal(_identifier);
    });

    it("Change Status from customer in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();        
        
        let _address = "0x1c7D3Eef242473c2C9d3aDe0B21caE7251aec1F8";   
        expect(await instance.changeStatusCustomer.call(_address, false)).to.be.equal(true);
    });

    it("Can I change the customer address by another in my Know Your Customer Contract", async () => {
        let instance = await KYCContract.deployed();

        let _identifier = "XE09IBTPAC1ECGYE0002";
        let _address = "0x1dd39176D300c059A79D2d4c265bD714492EDF9e";
        let _bankAddress= "0x92fe4ecB478689A4c3950914DFF892f30960Fab9";

        let _newAddress = "0xFbb48F938f2BC530d5f06505200971cc7244eA51";
        await instance.addCustomer(_identifier, _address, _bankAddress);
        expect(await instance.updateCustomerAddress.call(_address, _newAddress)).to.be.equal(true);
    });
});