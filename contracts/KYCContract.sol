// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract KYCContract is Ownable {
    
    struct Customer {        
        string _addressICAP;
        address _address;
        bool isAllowed;    
        Bank _bank;
    }

    struct Bank {
        string _name;
        address _address;
        string _identifier;
        uint _totalCustomers;
    }

    mapping(address => Bank) private banks;
    mapping(string => address) private bankRegStore;
    mapping(address => Customer) private customers;
    mapping(string => address) private customerRegStore;
    mapping(address => bool) bankAllowed;
    
    function setKycBankCompleted(address _addr) public onlyOwner {
        bankAllowed[_addr] = true;
    }

    function setKycBankRevoked(address _addr) public onlyOwner {
        bankAllowed[_addr] = false;
    }

    function kycBankCompleted(address _addr) public view returns(bool) {
        return bankAllowed[_addr];
    }
   
    function addBank(string memory _name, address _address, string memory _identifier) public onlyOwner returns(bool) {
        bool isAddedToBankListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(banks[_address]._address == address(0), "This Bank is already exist!");
        require(bankRegStore[_identifier] == address(0), "This Bank Identifier Code is already exist!");
        
        Bank storage _bank = banks[_address];
        _bank._name = _name;
        _bank._address = _address;
        _bank._identifier = _identifier;
        
        bankRegStore[_identifier] = _address;
        setKycBankCompleted(_address);
        
        isAddedToBankListFlag = true;
        return isAddedToBankListFlag;
    }
    
    function removeBank(address _address) public onlyOwner returns(bool) {
        bool isRemovedFromBankListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(banks[_address]._address != address(0), "Bank not exists!");
        
        Bank memory _bank = banks[_address];
        
        require(_bank._totalCustomers == 0, "This Banks has some users registered!");
        require(bankRegStore[_bank._identifier] != address(0), "This Bank Identifier Code is not exist!");
        
        delete bankRegStore[_bank._identifier];
        delete banks[_address];
        setKycBankRevoked(_address);
        
        isRemovedFromBankListFlag = true;
        return isRemovedFromBankListFlag;
    }
    
    function updateBankAddress(address oldAddress, address newAddress) public onlyOwner returns(bool) {
        bool isUpdateFromBankListFlag = false;
        
        require(oldAddress != address(0), "No valid old address!");
        require(banks[oldAddress]._address != address(0), "Bank not exists!");
        
        require(newAddress != address(0), "No valid new address!");
        require(banks[newAddress]._address == address(0), "This Bank is already exist!");
        
        Bank storage oldBank = banks[oldAddress];
        
        require(bankRegStore[oldBank._identifier] != address(0), "This Bank Identifier Code is not exist!");
        
        delete bankRegStore[oldBank._identifier];
        
        Bank storage newBank = banks[newAddress];
        
        newBank._name = oldBank._name;
        newBank._address = newAddress;
        newBank._identifier = oldBank._identifier;
        newBank._totalCustomers = oldBank._totalCustomers;
       
        delete banks[oldAddress];
        
        bankRegStore[newBank._identifier] = newAddress;
        
        isUpdateFromBankListFlag = true;
        return isUpdateFromBankListFlag;
    }
    
    function updateBankInfo(address _address, string memory newName, string memory newIdentifier) public onlyOwner returns(bool) {
        bool isUpdateFromBankListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(banks[_address]._address != address(0), "Bank not exists!");
        require(bytes(newName).length > 0, "Name of Bank is required!");
        require(bytes(newIdentifier).length > 0, "Bank Identifier Code is required!");
        
        Bank storage _bank = banks[_address];
        
        require(bankRegStore[_bank._identifier] != address(0), "This Bank Identifier Code is not exist!");
        require(hashCompareWithLengthCheck(_bank._identifier, newIdentifier) || bankRegStore[newIdentifier] == address(0), "This Bank Identifier Code is already exist!");
       
        _bank._name = newName;
        _bank._identifier = newIdentifier;
        
        delete bankRegStore[_bank._identifier];
        
        bankRegStore[newIdentifier] = _address;
        
        isUpdateFromBankListFlag = true;
        return isUpdateFromBankListFlag;
    }
    
    function getBankDetails(address _address) public view returns (string memory bankName, address bankAddress, string memory bankIdentifier, uint totalCustomersRegistered) {
        require(_address != address(0), "No valid address!");
        require(banks[_address]._address != address(0), "Bank not exists!");
        
        Bank memory _bank = banks[_address];
         
        return (_bank._name, _bank._address, _bank._identifier, _bank._totalCustomers);
    }
    
    function addCustomer(string memory _addressICAP, address _customerAddress, address _bankAddress) public onlyOwner returns(bool) {
        bool isAddedToBankListFlag = false;
        
        
        require(_customerAddress != address(0), "No valid customer address!");
        require(_bankAddress != address(0), "No valid bank address!");
        
        require(customers[_customerAddress]._address == address(0), "This Customer is already exist!");
        require(customerRegStore[_addressICAP] == address(0), "The ICAP address is already exist!");
        require(banks[_bankAddress]._address != address(0), "This Bank is not exist!");
        
        
        Bank storage _bank = banks[_bankAddress];
        _bank._totalCustomers ++;
        
        Customer storage _customer = customers[_customerAddress];
        _customer._addressICAP = _addressICAP;
        _customer._address = _customerAddress;
        _customer.isAllowed = true;
        _customer._bank = _bank;
        
        customerRegStore[_addressICAP] = _customerAddress;
        
        isAddedToBankListFlag = true;
        return isAddedToBankListFlag;
    }
    
    function removeCustomer(address _address) public onlyOwner returns(bool)  {
        bool isRemovedFromCustomerListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(customers[_address]._address != address(0), "Customer not exists!");
        
        Customer memory _customer = customers[_address];
        
        require(customerRegStore[_customer._addressICAP] != address(0), "The ICAP address is not exist!");
        
        delete customerRegStore[_customer._addressICAP];
        delete customers[_address];
        
        Bank storage _bank = banks[_customer._bank._address];
        _bank._totalCustomers --;
        
        isRemovedFromCustomerListFlag = true;
        return isRemovedFromCustomerListFlag;
    }
    
    function updateCustomerAddress(address oldAddress, address newAddress) public onlyOwner returns(bool) {
        bool isUpdateFromCustomerListFlag = false;
        
        require(oldAddress != address(0), "No valid old address!");
        require(customers[oldAddress]._address != address(0), "Customer not exists!");
        
        require(newAddress != address(0), "No valid new address!");
        require(customers[newAddress]._address == address(0), "This Customer is already exist!");
        
        Customer storage oldCustomer = customers[oldAddress];
        
        require(customerRegStore[oldCustomer._addressICAP] != address(0), "The ICAP address is not exist!");
        
        delete customerRegStore[oldCustomer._addressICAP];
        
        Customer storage newCustomer = customers[newAddress];
        
        newCustomer._addressICAP = oldCustomer._addressICAP;
        newCustomer._address = newAddress;
        newCustomer.isAllowed = oldCustomer.isAllowed;
        newCustomer._bank = oldCustomer._bank;
       
        delete customers[oldAddress];
        
        customerRegStore[newCustomer._addressICAP] = newAddress;
        
        isUpdateFromCustomerListFlag = true;
        return isUpdateFromCustomerListFlag;
    }
    
    function updateCustomerICAPaddress(address _address, string memory newAddressICAP) public onlyOwner returns(bool) {
        bool isUpdateFromCustomerListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(customers[_address]._address != address(0), "Customer not exists!");
        require(bytes(newAddressICAP).length > 0, "ICAP address is required!");
        
        Customer storage _customer = customers[_address];
        
        require(customerRegStore[_customer._addressICAP] != address(0), "The ICAP address is not exist!");
        require(hashCompareWithLengthCheck(_customer._addressICAP, newAddressICAP) || customerRegStore[newAddressICAP] == address(0), "The ICAP address is already exist!");
       
        _customer._addressICAP = newAddressICAP;
        
        delete customerRegStore[_customer._addressICAP];
        
        customerRegStore[newAddressICAP] = _address;
        
        isUpdateFromCustomerListFlag = true;
        return isUpdateFromCustomerListFlag;
    }
    
    
    function changeStatusCustomer(address _address, bool isAllowed) public onlyOwner returns(bool) {
        bool isUpdateFromCustomerListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(customers[_address]._address != address(0), "Customer not exists!");
        
        Customer storage _customer = customers[_address];
        
        require(customerRegStore[_customer._addressICAP] != address(0), "The ICAP address is not exist!");
       
        _customer.isAllowed = isAllowed;
        
        isUpdateFromCustomerListFlag = true;
        return isUpdateFromCustomerListFlag;
    }
    
    
    function updateCustomerBankRegistered(address _address, address newAddressBank) public onlyOwner returns(bool) {
        bool isUpdateFromCustomerListFlag = false;
        
        require(_address != address(0), "No valid address!");
        require(customers[_address]._address != address(0), "Customer not exists!");
        
        Customer storage _customer = customers[_address];
        
        require(customerRegStore[_customer._addressICAP] != address(0), "The ICAP address is not exist!");
        require(banks[newAddressBank]._address != address(0), "This Bank is not exist!");
        
        Bank memory _bank = banks[newAddressBank];
        _customer._bank = _bank;
        
        isUpdateFromCustomerListFlag = true;
        return isUpdateFromCustomerListFlag;
    }
    
    
    function getCustomerDetails(address _address) public view returns (string memory addressICAP, address customerAddress, bool isAllowed,Bank memory bank) {
        require(_address != address(0), "No valid address!");
        require(customers[_address]._address != address(0), "Customer not exists!");
        
        Customer memory _customer = customers[_address];
         
        return (_customer._addressICAP, _customer._address, _customer.isAllowed, _customer._bank);
    }
    
    function getCustomerAddressFromICAP(string memory _icap) public view returns (address customerAddress) {
        require(customerRegStore[_icap] != address(0), "The ICAP address is not already registered!");
        return customerRegStore[_icap];
    }
 
    function hashCompareWithLengthCheck(string memory a, string memory b) internal pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
    }
    
    function concatenate(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}