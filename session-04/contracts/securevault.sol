// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// ReentrancyGuard gives us the nonReentrant modifier
// it blocks any attempt to call withdraw again while it is still running
contract SecureVault is ReentrancyGuard {

    // tracks how much ether each address has deposited
    mapping(address => uint256) private balances;

    // fired every time someone deposits ether
    event Deposited(
        address indexed user,
        uint256 amount,
        uint256 depositedAt
    );

    // fired every time someone withdraws ether
    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 withdrawnAt
    );

    // lets anyone see the total ether sitting in this contract
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // lets the caller check their own balance
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // payable allows this function to receive ether
    // msg.value holds how much ether was sent with the call
    function deposit() external payable {

        // reject zero-value deposits — nothing to record
        require(msg.value > 0, "Zero amount");

        // add the sent ether to the caller's balance
        balances[msg.sender] += msg.value;

        // emit after state is updated
        emit Deposited(msg.sender, msg.value, block.timestamp);
    }

    // nonReentrant blocks re-entry — if someone tries to call
    // withdraw again while this is still running it gets rejected
    function withdraw() external nonReentrant {

        address recipient = msg.sender;
        uint256 amount = balances[recipient];

        // CHECK — does the caller have anything to withdraw
        require(amount > 0, "Nothing to withdraw");

        // EFFECT — zero the balance BEFORE sending ether
        // this is the CEI pattern from the session
        // if we sent first and cleared after, a re-entrant call
        // would still see the old balance and drain the vault
        balances[recipient] = 0;

        // INTERACTION — send ether only after state is already updated
        // .call is the preferred way — transfer and send are legacy
        // always check the result or the contract silently continues on failure
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");

        // emit after everything is done
        emit Withdrawn(recipient, amount, block.timestamp);
    }

    // receive() handles plain ether sent directly to the contract
    // without calling any function — triggered when calldata is empty
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value, block.timestamp);
    }
}