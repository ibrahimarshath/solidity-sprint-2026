// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title MessageStorage
 * @dev Store a message string and track who last updated it
 */
contract MessageStorage {

    string private message;
    address private lastEditor;

    /**
     * @dev Update the message and record who made the change
     * @param newMessage The new message to store
     */
    function updateMessage(string memory newMessage) public {
        message = newMessage;
        lastEditor = msg.sender;
    }

    /**
     * @dev Read the current message
     * @return The stored message string
     */
    function getMessage() public view returns (string memory) {
        return message;
    }

    /**
     * @dev Read the last editor's address
     * @return The address of whoever last changed the message
     */
    function getLastEditor() public view returns (address) {
        return lastEditor;
    }
}