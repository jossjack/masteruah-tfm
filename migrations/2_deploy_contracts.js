var IBTToken = artifacts.require("./IBTToken.sol");
var KYCContract = artifacts.require("./KYCContract.sol");
var DataFeedPrice = artifacts.require("./DataFeedPrice.sol");
var RouterTokenSwap = artifacts.require("./RouterTokenSwap.sol");
var ProviderContract = artifacts.require("./ProviderContract.sol");

require("dotenv").config({ path: "../.env" });

module.exports = async function (deployer) {
    let addr = await web3.eth.getAccounts();

    await deployer.deploy(IBTToken, process.env.INITIAL_TOKENS);    
    await deployer.deploy(ProviderContract, 1, addr[0], IBTToken.address);
    
    let tokenInstance = await IBTToken.deployed();
    await tokenInstance.transfer(ProviderContract.address, process.env.INITIAL_TOKENS);

    await deployer.deploy(KYCContract);
    await deployer.deploy(DataFeedPrice);
    await deployer.deploy(RouterTokenSwap, process.env.ROUTER_UNISWAP);   
};