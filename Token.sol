// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyBSCCoin is IERC20Metadata, Ownable {
    using SafeMath for uint256;

    string private _name = "My BSC Coin";
    string private _symbol = "MBSC";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Token allocations
    uint256 public liquidityAllocation = 600; // 60%
    uint256 public cexAllocation = 200; // 20%
    uint256 public developmentAllocation = 100; // 10%
    uint256 public marketingAllocation = 50; // 5%
    uint256 public founderAllocation = 50; // 5%

    address public liquidityWallet;
    address public cexWallet;
    address public developmentWallet;
    address public marketingWallet;
    address public founderWallet;

    constructor() {
        uint256 initialSupply = 1_000_000_000 * 10 ** uint256(_decimals); // 1 billion tokens
        _totalSupply = initialSupply;
        
        // Assign allocations to respective wallets
        liquidityWallet = msg.sender;
        cexWallet = msg.sender;
        developmentWallet = msg.sender;
        marketingWallet = msg.sender;
        founderWallet = msg.sender;

        // Distribute tokens to allocation wallets
        _balances[liquidityWallet] = initialSupply.mul(liquidityAllocation).div(1000);
        _balances[cexWallet] = initialSupply.mul(cexAllocation).div(1000);
        _balances[developmentWallet] = initialSupply.mul(developmentAllocation).div(1000);
        _balances[marketingWallet] = initialSupply.mul(marketingAllocation).div(1000);
        _balances[founderWallet] = initialSupply.mul(founderAllocation).div(1000);

        emit Transfer(address(0), liquidityWallet, _balances[liquidityWallet]);
        emit Transfer(address(0), cexWallet, _balances[cexWallet]);
        emit Transfer(address(0), developmentWallet, _balances[developmentWallet]);
        emit Transfer(address(0), marketingWallet, _balances[marketingWallet]);
        emit Transfer(address(0), founderWallet, _balances[founderWallet]);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
