// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// CensorshipToken contract inheriting from ERC20 contract
contract CensorshipToken is ERC20 {
    // Address of the contract owner with full control over the contract
    address public master;

    // Address of the censor with partial control over the contract (e.g., able to blacklist addresses)
    address public censor;

    // Mapping to track blacklisted addresses
    mapping(address => bool) public blacklist;

    // Modifier to enable access to functions for master address only
    modifier onlyMaster() {
        require(msg.sender == master, "Caller is not the master");
        _;
    }

    // Modifier to enable access to functions for either master or censor address
    modifier onlyMasterOrCensor() {
        require(msg.sender == master || msg.sender == censor, "Caller is not the master or censor");
        _;
    }

    // Modifier to make sure a considered address is not blacklisted
    modifier notBlacklisted(address _target) {
        require(!blacklist[_target], "Address is blacklisted");
        _;
    }

    // Constructor to initialize the contract with the given name, symbol, and initial supply
    constructor() ERC20("CensorshipToken", "CTK"){
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals()))); // Mint 100,000,000 tokens and assign them to the deployer
        master = msg.sender; // Set the deployer's address as master
        censor = msg.sender; // Set the deployer's address as censor
    }

    // Function to change the master address (only callable by the current master)
    function changeMaster(address newMaster) external onlyMaster {
        require(newMaster != address(0), "Invalid master address");
        master = newMaster;
    }

    // Function to change the censor address (only callable by the current master)
    function changeCensor(address newCensor) external onlyMaster{
        require(newCensor != address(0), "Invalid censor address");
        censor = newCensor;
    }

    // Function to add or remove an address from the blacklist (only callable by the master or censor)
    function setBlacklist(address target, bool blacklisted) external onlyMasterOrCensor{
        blacklist[target] = blacklisted;
    }

    // Function to claw back tokens from a specified address (only callable by the master)
    function clawBack(address target, uint256 amount) external onlyMaster{
        transferFrom(target,master , amount);
    }

    // Internal function to mint (create) new tokens and assign them to a specified address (only callable by the master)
    function mint(address target, uint256 amount) internal onlyMaster {
        _mint(target, amount);
    }

    // Internal function to burn (remove) tokens from a specified address (only callable by the master)
    function burn(address target, uint256 amount) internal  onlyMaster{
        _burn(target, amount);
    }

    // Override ERC20 transfer function with blacklist check
    function transfer(address recipient, uint256 amount) public notBlacklisted(msg.sender) notBlacklisted(recipient) override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

}
