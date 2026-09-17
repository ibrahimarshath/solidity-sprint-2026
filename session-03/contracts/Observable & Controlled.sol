// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// the interface exposes only the read functions — no implementation here
// anything that wants to read student data can use this shape
interface IStudentRegistry {
    function getStudent(address wallet) external view returns (
        string memory name,
        uint256 enrolmentId,
        uint8 status,
        bool registered
    );
}

// we inherit Ownable from OpenZeppelin so we don't have to write
// the owner tracking and onlyOwner modifier ourselves
contract StudentRegistry is Ownable, IStudentRegistry {

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

    // fired when the owner registers a new student
    // indexed on the wallet so it is easy to filter logs by address
    event Registered(
        address indexed student,
        string name,
        uint256 enrolmentId,
        Status status
    );

    // fired when a student updates their own status
    event StatusUpdated(
        address indexed student,
        Status oldStatus,
        Status newStatus
    );

    // maps a wallet address to its student record
    mapping(address => Student) private students;

    // tracks whether an address has registered or not
    // used to prevent duplicates and handle unregistered addresses
    mapping(address => bool) private isRegistered;

    // constructor runs once at deploy — passes msg.sender to Ownable
    // so whoever deploys the contract becomes the owner automatically
    constructor() Ownable(msg.sender) {}

    // reusable check — if this address is not registered, stop here
    // we write it once and apply it wherever we need it
    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "Not registered");
        _;
    }

    // only the owner can register students
    // a student cannot register themselves anymore — the owner does it for them
    function register(string memory name, uint256 enrolmentId, address wallet) public onlyOwner {

        // stop here if this address is already in the registry
        if (isRegistered[wallet]) {
            revert AlreadyRegistered(wallet);
        }

        // save the student record using named fields — safer than positional
        students[wallet] = Student({
            name: name,
            enrolmentId: enrolmentId,
            status: Status.Active  // everyone starts as Active
        });

        // mark this address as registered
        isRegistered[wallet] = true;

        // emit after all state changes are done
        emit Registered(wallet, name, enrolmentId, Status.Active);
    }

    // lets a registered student change their own status
    // onlyRegistered modifier runs the check before the function body
    function updateStatus(Status newStatus) public onlyRegistered {

        // storage pointer — edits the actual record on chain
        // memory here would throw the change away
        Student storage s = students[msg.sender];

        // save the old status so we can include it in the event
        Status oldStatus = s.status;
        s.status = newStatus;

        emit StatusUpdated(msg.sender, oldStatus, newStatus);
    }

    // anyone can look up a student by wallet address
    // returns uint8 for status so the interface stays simple
    function getStudent(address wallet) public view override returns (
        string memory name,
        uint256 enrolmentId,
        uint8 status,
        bool registered
    ) {
        // handle unregistered addresses explicitly instead of returning garbage
        if (!isRegistered[wallet]) {
            return ("", 0, 0, false);
        }

        // memory copy is fine here — we are only reading, not writing
        Student memory s = students[wallet];
        return (s.name, s.enrolmentId, uint8(s.status), true);
    }
}