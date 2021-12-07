// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external;
}

contract IBTToken is ERC20, AccessControl {
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    
    event TokensTransfered (
        address from,
        address to,
        uint256 amount
    );

    constructor(uint256 initialSupply) ERC20('International Banking Simple Transfer Token', 'IBT') {
        _mint(msg.sender, initialSupply);       
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);       
    }

    function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) returns (bool) {
        _mint(account, amount);
        return true;
    }
    
    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) returns (bool) {
        _burn(from, amount);
        return true;
    }
    
    function revokeRole(bytes32 role, address account) public onlyRole(DEFAULT_ADMIN_ROLE) override {
        require(role != DEFAULT_ADMIN_ROLE, "ModifiedAccessControl: cannot revoke default admin role");
        super.revokeRole(role, account);
    }
    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
        emit TokensTransfered(from, to, amount);
    }
}