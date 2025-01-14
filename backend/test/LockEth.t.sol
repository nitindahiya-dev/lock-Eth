// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol"; // Foundry standard library
import {Proxy} from "../src/ProxyContract.sol"; // Ensure this import points to your proxy contract;
import {LockEth} from "../src/LockEth.sol";

contract LockEthTest is Test {
    Proxy proxy;
    LockEth lockEthV1;
    LockEth proxiedLockEth;

    address user = address(0x1234); // Simulate a user

    function setUp() public {
        // Deploy the first version of the LockEth contract
        lockEthV1 = new LockEth();

        // Deploy the proxy contract pointing to LockEthV1
        proxy = new Proxy(address(lockEthV1));

        // Interact with the logic contract via the proxy
        proxiedLockEth = LockEth(address(proxy));
    }

    function testStake() public {
        // Simulate user staking 1 ETH
        vm.deal(user, 1 ether); // Fund the user with 1 ETH
        vm.prank(user);         // Simulate the user sending the transaction
        proxiedLockEth.stake{value: 1 ether}();

        // Verify the user's stake is correctly recorded
        (uint256 amount, uint256 unlockTime) = proxiedLockEth.getStakeDetails(user);
        assertEq(amount, 1 ether);
        assertGt(unlockTime, block.timestamp); // Ensure the unlock time is in the future
    }

    function testWithdrawAfterLockPeriod() public {
        // Simulate user staking 1 ETH
        vm.deal(user, 1 ether);
        vm.prank(user);
        proxiedLockEth.stake{value: 1 ether}();

        // Simulate time passing beyond the lock period (21 days)
        vm.warp(block.timestamp + 21 days);

        // Simulate user withdrawing their stake
        uint256 initialUserBalance = user.balance;
        vm.prank(user);
        proxiedLockEth.withdraw();

        // Verify user's balance after withdrawal
        assertEq(user.balance, initialUserBalance + 1 ether);
    }

    function testCannotWithdrawBeforeLockPeriod() public {
        // Simulate user staking 1 ETH
        vm.deal(user, 1 ether);
        vm.prank(user);
        proxiedLockEth.stake{value: 1 ether}();

        // Attempt withdrawal before lock period ends (should revert)
        vm.expectRevert("Tokens are still locked");
        vm.prank(user);
        proxiedLockEth.withdraw();
    }
}
