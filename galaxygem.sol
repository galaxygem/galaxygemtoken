/**
 *Submitted for verification at Etherscan.io on 2023-05-30
*/

/**
   telegram : https://t.me/galaxygem_global_group
   website : https://galaxygem.online/
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractRenounced(address indexed previousOwner);
}

contract GalaxyGem is IERC20 {
    string public name = "GalaxyGem";
    string public symbol = "GLXGEM";
    address public ownerWallet;
    address public marketing;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public constant marketingFeePercentage = 2;

    address private _owner;
    address private _marketingWallet;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(address marketingWallet) {
        _owner = msg.sender;
        ownerWallet = msg.sender;
        _marketingWallet = marketingWallet;
        marketing = marketingWallet;
        totalSupply = 1000000 * 10 ** uint256(decimals);
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount, true);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount, false);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount, bool isSale) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "Insufficient balance");

        uint256 marketingFee = 0;
        if (!isSale && sender != _owner && sender != _marketingWallet) {
            marketingFee = (amount * marketingFeePercentage) / 100;
            _balances[_marketingWallet] += marketingFee;
        }

        uint256 transferAmount = amount - marketingFee;

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;

        emit Transfer(sender, recipient, transferAmount);
        if (marketingFee > 0) {
            emit Transfer(sender, _marketingWallet, marketingFee);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function renounceOwnership() external {
        require(msg.sender == _owner, "Only the owner can renounce ownership");
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        emit ContractRenounced(_owner);
    }
}
