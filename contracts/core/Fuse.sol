 /**
 * @title Fuse Method
 *
 * @author Bit Lighthouse. Henry Mo
 * AT: 2021-07-02 | VERSION: v1.0.2
 */

// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "../authority/Member.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract Fuse is Member {
    constructor(address auth_) Member(auth_) {

    }

    function get_fuse_point() public pure returns (uint256) {
        return 0;
    }
}