// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ProviderContract is Context, AccessControl, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");
    
    uint256 private _weiRaised;
    uint256 private _rate;
    
    IERC20 private _token;
    address payable private _wallet;
  
    event BuyTokens(address indexed buyer, address indexed beneficiary, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address indexed seller, address indexed beneficiary, uint256 amountOfTokens, uint256 amountOfETH);
    
    constructor(uint256 rate_, address payable wallet_, IERC20 token_) {
        require(rate_ > 0, "ProviderContract: rate is 0");
        require(wallet_ != address(0), "ProviderContract: wallet is the zero address");
        require(address(token_) != address(0), "ProviderContract: token is the zero address");
        _token = token_;
        _wallet = wallet_;
        _rate = rate_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function setPrices(uint256 newBuyPrice) onlyRole(DEFAULT_ADMIN_ROLE) public {
        _weiRaised = newBuyPrice;
    }

    function weiPrices() public view returns (uint256) {
        return _weiRaised;
    }
    
    function setRate(uint256 _tokensPerEth) onlyRole(DEFAULT_ADMIN_ROLE) public {
        _rate = _tokensPerEth;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }
    
    function buyTokens(address beneficiary) onlyRole(TRANSFER_ROLE) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokensToBuy = _getTokenAmount(weiAmount);        

        uint256 balance = _token.balanceOf(_wallet);
        require(balance >= tokensToBuy, "ProviderContract: Contract has not enough tokens in its balance");
    
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokensToBuy);
        emit BuyTokens(_msgSender(), beneficiary, weiAmount, tokensToBuy);     

        _updatePurchasingState(beneficiary, weiAmount);   

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    function _forwardFunds() internal virtual {
        _wallet.transfer(msg.value);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal virtual {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal virtual {
        _deliverTokens(beneficiary, tokenAmount);
    }

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
        // solhint-disable-previous-line no-empty-blocks
    }
    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view virtual {
        require(beneficiary != address(0), "ProviderContract: Beneficiary is the zero address");
        require(weiAmount > 0, "ProviderContract: Send ETH to buy some tokens, weiAmount is 0");
        this;
    }
    
    function _getTokenAmount(uint256 weiAmount) internal view virtual returns (uint256) {
        return weiAmount.mul(_rate);
    }
    
    function sellTokens(uint256 tokenAmountToSell) onlyRole(TRANSFER_ROLE) public nonReentrant payable {
        require(tokenAmountToSell > 0, "You need to sell at least some tokens");
        
        uint256 userBalance = _token.balanceOf(_msgSender());
        require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");
        
        uint256 amountOfETHToTransfer = (tokenAmountToSell * 1 ether) / _rate;
        uint256 ownerETHBalance = address(_wallet).balance;
        require(ownerETHBalance >= amountOfETHToTransfer, "The contract has not enough funds to accept the sell request!");
        
        (bool sent_token) = _token.transferFrom(_msgSender(), address(_wallet), (tokenAmountToSell * 1 ether));
        require(sent_token, "Failed to transfer tokens from user to provider");
        
  
        (bool sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
        require(sent, "Failed to send Ether");   
      
        emit SellTokens(_msgSender(), _wallet, amountOfETHToTransfer, tokenAmountToSell);          
    }
    
    function withdraw() public nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 ownerBalance = address(_wallet).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");
            
        address payable to = payable(_msgSender());
        (bool sent,) = to.call{value: address(_wallet).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }
    
    function withdrawMoneyTo(address payable _to) public nonReentrant onlyRole(DEFAULT_ADMIN_ROLE)  {
        _to.transfer(address(_wallet).balance);
    }
    
    function getBalance() public view returns (uint) {
        return address(_wallet).balance;
    }
    
    function addTransferRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(TRANSFER_ROLE, account);
    }
    
    function _removeTransferRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(TRANSFER_ROLE, account);
    }

    receive () external payable {
        buyTokens(_msgSender());
    }

    function token() public view returns (IERC20) {
        return _token;
    }

    function wallet() public view returns (address payable) {
        return _wallet;
    }
}