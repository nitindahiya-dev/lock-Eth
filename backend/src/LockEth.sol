// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract LockEth {
    struct Stake {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Stake) public stakes;
    uint256 public constant LOCK_PERIOD = 21 days;

    // Storage slot for admin (used for proxy upgrade compatibility)
    address public admin;

    event Staked(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    // Stake function
    function stake() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(
            stakes[msg.sender].amount == 0 || block.timestamp >= stakes[msg.sender].unlockTime,
            "Cannot stake until previous lock expires"
        );

        stakes[msg.sender] = Stake({
            amount: msg.value,
            unlockTime: block.timestamp + LOCK_PERIOD
        });

        emit Staked(msg.sender, msg.value, stakes[msg.sender].unlockTime);
    }

    // Withdraw function
    function withdraw() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No funds to withdraw");
        require(block.timestamp >= userStake.unlockTime, "Tokens are still locked");

        uint256 amountToWithdraw = userStake.amount;

        // Reset the stake
        userStake.amount = 0;
        userStake.unlockTime = 0;

        payable(msg.sender).transfer(amountToWithdraw);

        emit Withdrawn(msg.sender, amountToWithdraw);
    }

    // Utility functions
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getStakeDetails(address user) external view returns (uint256 amount, uint256 unlockTime) {
        Stake memory userStake = stakes[user];
        return (userStake.amount, userStake.unlockTime);
    }
}
