 /**
 * @title Babylon Method
 *
 * @author Bit Lighthouse. Henry Mo
 * AT: 2021-07-02 | VERSION: v1.0.2
 */

// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "../authority/Member.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract Babylon is Member {
    using SafeMath for uint256;

    address[] public _roots;
    address[] public _all_users;

    mapping (address => bool) public _is_users;
    mapping (address => address) public _is_superiors;

    mapping (address => uint256) public _amounts;
    mapping (address => address[]) public _lowers;

    constructor(address auth_, address root_) Member(auth_) {
        _roots.push(root_);
    }

    function _calculate_total(address account_) private view
        returns (uint256 total, uint256 myself) {
        
        for (uint i = 0; i < _lowers[account_].length; i++) {
            address item = _lowers[account_][i];
            myself = myself.add(_amounts[item]);

            if (_lowers[item].length <= 0) continue;

            uint256 babylon = 0;
            (total, babylon) = _calculate_total(item);

            myself = myself.add(babylon);
            myself = myself > 0 ? myself.div(2) : myself;

            total = total.add(myself);
        }
    }

    function _calculate_self(address account_) private view
        returns (uint256 myself) {
        
        for (uint i = 0; i < _lowers[account_].length; i++) {
            address item = _lowers[account_][i];
            myself = myself.add(_amounts[item]);

            if (_lowers[item].length <= 0) continue;

            uint256 babylon = _calculate_self(item);
            myself = myself.add(babylon);
            myself = myself > 0 ? myself.div(2) : myself;
        }
    }

    function get_amount(address account_) public view
        returns (uint256) {

        return _amounts[account_];
    }

    function set_superior(address superior) public {
        require(
            superior != address(0),
            "BABYLON: Superior address is invald"
        );

        if (_is_superiors[msg.sender] == address(0)) {
            _is_superiors[msg.sender] = superior;
        }
    }

    function deposit(
        address account_, address superior_, uint256 amount_
    ) public CheckPermit("LEMON") {
        require(
            _is_superiors[account_] == address(0) ||
            _is_superiors[account_] == superior_,
            "BABYLON: Wrong recommender"
        );

        if (_is_superiors[account_] == address(0)) {
            _all_users.push(account_);
            _is_superiors[account_] = superior_;

            _lowers[superior_].push(account_);
        }

        _amounts[account_] = _amounts[account_].add(amount_);
    }

    function withdraw(address account_) public
        CheckPermit("LEMON") {

        delete _amounts[account_];
    }

    function calculation_total() public view
        returns (uint256 total) {

        for (uint i = 0; i < _roots.length; i++) {
            uint256 myself = 0;
            (total, myself) = _calculate_total(_roots[i]);

            total = total.add(myself).add(_amounts[_roots[i]]);
        }
    }

    function calculation_myself(address account) public
        view returns (uint256 total) {

        uint256 babylon = _calculate_self(account);
        total = _amounts[account].add(babylon);
    }

    function get_tops(address account_) public pure returns (uint256) {
        return 21;
    }

    function get_period(address account_) public pure
        returns (uint256 period) {
        
        period = 1 days; uint256 top = get_tops(account_);

        if (top > 0 && top <= 21) { period = 30 days; } 
        if (top > 21 && top <= 321) { period = 15 days; }
    }
}