/**
 * @title Authority Of Administrator & Members
 *
 * @author Bit Lighthouse. Henry Mo
 * AT: 2021-07-02 | VERSION: v1.0.2
 */

// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "./Authority.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Member is Ownable {
    // Authority's manager
    Authority public _authority;
    
    // Member of administrator or contract
    mapping (string => address) public _members;

    // Permit of members
    mapping (address => mapping(string => bool)) public _permits;

    constructor(address authority_) {
        _authority = Authority(authority_);
    }

    /**
     * @notice Check Operator Permit - modifier
     * @param _permit name of permit
     */
    modifier CheckPermit(string memory _permit) {
        require(
            _authority._permits(msg.sender, _permit),
            "Member: The operation is not allowed"
        );
        _;
    }
    
    /**
     * @notice Set new manager
     * @param authority_ address of manager
     *
     * This function is onwer only
     */
    function setAuthority(address authority_) external
        onlyOwner {
        
        _authority = Authority(authority_);
    }
}