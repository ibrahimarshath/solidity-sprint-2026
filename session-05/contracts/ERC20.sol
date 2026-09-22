// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ERC20 from OpenZeppelin gives us the full standard interface for free
// — balanceOf, transfer, approve, transferFrom, totalSupply, allowance
// we just need to add our own identity, minting and burning on top
contract IA28Token is ERC20 {

    // owner is the only one allowed to mint new tokens
    address private owner;

    // constructor runs once at deploy
    // ERC20("name", "symbol") sets the token's identity
    // _mint gives the deployer the initial supply
    constructor(uint256 initialSupply) ERC20("IA28", "IA28") {
        owner = msg.sender;

        // mint the initial supply to whoever deployed the contract
        // initialSupply should be passed in as full units e.g. 1000000
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // only the owner can create new tokens
    // minting increases totalSupply and adds to the recipient's balance
    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint");
        _mint(to, amount * 10 ** decimals());
    }

    // any token holder can burn their own tokens
    // burning reduces totalSupply and removes from the caller's balance
    function burn(uint256 amount) external {
        _burn(msg.sender, amount * 10 ** decimals());
    }
}