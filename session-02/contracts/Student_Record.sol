// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentRegistry {

    // three possible states a student can be in
    enum Status {
        Active,     // 0 - currently studying
        Inactive,   // 1 - not currently studying
        Graduated   // 2 - completed the course
    }

    // a student has a name, an enrolment ID and a status
    struct Student {
        string name;
        uint256 enrolmentId;
        Status status;
    }

    // custom error so the caller knows exactly why it failed
    error AlreadyRegistered(address student);

    // maps a wallet address to its student record
    mapping(address => Student) private students;

    // tracks whether an address has registered or not
    // used to prevent duplicates and handle unregistered addresses
    mapping(address => bool) private isRegistered;


    // anyone can call this to register themselves
    // we use msg.sender so the student registers their own wallet
    function register(string memory name, uint256 enrolmentId) public {

        // stop here if this address already registered
        if (isRegistered[msg.sender]) {
            revert AlreadyRegistered(msg.sender);
        }

        // save the student record using named fields — safer than positional
        students[msg.sender] = Student({
            name: name,
            enrolmentId: enrolmentId,
            status: Status.Active  // everyone starts as Active
        });

        // mark this address as registered
        isRegistered[msg.sender] = true;
    }


    // lets a registered student change their own status
    function updateStatus(Status newStatus) public {

        // only registered students can update
        require(isRegistered[msg.sender], "Not registered");

        // storage pointer — this edits the actual record on chain
        // if we used memory here the change would be thrown away
        Student storage s = students[msg.sender];
        s.status = newStatus;
    }


    // anyone can look up a student by their wallet address
    // returns all four fields so the caller gets the full picture
    function getStudent(address wallet) public view returns (
        string memory name,
        uint256 enrolmentId,
        Status status,
        bool registered
    ) {
        // handle unregistered addresses explicitly instead of returning garbage
        if (!isRegistered[wallet]) {
            return ("", 0, Status.Active, false);
        }

        // memory copy is fine here — we are only reading, not writing
        Student memory s = students[wallet];
        return (s.name, s.enrolmentId, s.status, true);
    }
}