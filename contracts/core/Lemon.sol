 /**
 * @title Lemon Deposit
 *
 * @author Bit Lighthouse. Henry Mo
 * AT: 2021-07-02 | VERSION: v1.0.2
 */

// SPDX-License-Identifier: SimPL-2.0

pragma solidity ^0.7.0;

import "./Fuse.sol";
import "./Babylon.sol";
import "../authority/Member.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Lemon is Member, ERC20 {
    using SafeMath for uint256;

    uint256 public _start_at = block.timestamp;
    uint256 constant public MIN_AMOUNT = 8;
    uint256 constant public START_REWARDS = 0;

    mapping (address => uint256) public _periods;

    event Deposit(address superior, uint256 amount);
    event Claim(address account, uint256 reward);

    constructor(address auth_, uint256 start_at_)
        Member(auth_) ERC20("Lemon LP", "LLP") {

        _start_at = start_at_;
    }

    function _reward_total() private view returns (uint256 total) {
        total = START_REWARDS; uint now_year = 1;

        for (uint i = 1; i < 1000; i++) {
            uint256 year = _start_at.add(i.mul(365 days));

            if (block.timestamp >= year) {
                now_year = i;
                total = total.mul(8).div(10).div(365);
                break;
            }
        }
    }

    function deposit(uint256 amount_) public {
        require(
            amount_ >= MIN_AMOUNT * 10000 ** 18,
            "LEMON: The minimum amount of deposit is invalid"
        );

        address b = _authority._members("BABYLON");
        Babylon(b).deposit(msg.sender, address(0), amount_);

        IERC20 lemon = IERC20(_authority._members("LEMON"));

        require(
            lemon.transfer(address(this), amount_),
            "LEMON: Deposit transaction failed"
        );

        _mint(msg.sender, amount_);
        _periods[msg.sender] = block.timestamp;
        emit Deposit(address(0), amount_);
    }

    function rewards(address account_) public view returns (uint256) {
        address b = _authority._members("BABYLON");
        Babylon baby = Babylon(b);
        uint256 m = baby.calculation_myself(account_);

        if (m <= 0) return 0;

        uint256 x = _reward_total();
        uint256 mt = baby.calculation_total();
        Fuse fuse = Fuse(_authority._members("FUSE"));
        uint256 y = fuse.get_fuse_point();


        return m.div(mt).mul(y).mul(x);
    }

    function claim(address account_) public {
        uint256 reward = rewards(account_);

        if (reward > 0) {
            IERC20 lemon = IERC20(_authority._members("LEMON"));
            lemon.transfer(account_, reward);
        }

        emit Claim(account_, reward);
    }

    function withdraw() public {
        Babylon baby = Babylon(_authority._members("BABYLON"));
        uint256 period = baby.get_period(msg.sender);
        uint256 amount = baby.get_amount(msg.sender);

        require(
            _periods[msg.sender] + period >= block.timestamp,
            "LEMON: Can not withdraw now"
        );

        IERC20 lemon = IERC20(_authority._members("LEMON"));
        require(
            lemon.transferFrom(address(this), msg.sender, amount),
            "LEMON: Deposit transaction failed"
        );

        claim(msg.sender);
        baby.withdraw(msg.sender);
        _burn(msg.sender, amount);
        delete _periods[msg.sender];
    }
}