// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {

    string constant NOT_CURRENT_OWNER = "Not current owner";
    string constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "Cannot transfer to zero address";

    address public owner;

    event OwnershipChanged (
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        this.owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, NOT_CURRENT_OWNER);
        _;
    }

    function changeOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}
