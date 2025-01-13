// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol"; // Foundry standard library
import "../src/ProxyContract.sol"; // Ensure this import points to your proxy contract
import "../src/LockEth.sol";

contract LockEthTest is Test {
    Proxy proxy;
    LockEth lockEthV1;
    LockEth lockEthV2;
    LockEth proxiedLockEth;

    address owner = address(0xABCD); // Simulate admin
    address user = address(0x1234); // Simulate a user

    function setUp() public {
        // Deploy the first version of the LockEth contract
        lockEthV1 = new LockEth();

        // Deploy the proxy contract pointing to LockEthV1
        vm.prank(owner); // Simulate as the owner/admin
        proxy = new Proxy(address(lockEthV1));

        // Interact with the logic contract via the proxy
        proxiedLockEth = LockEth(address(proxy));
    }

    function testStake() public {
        // Simulate user staking 1 ETH
        vm.deal(user, 1 ether); // Fund the user with 1 ETH
        vm.prank(user);         // Simulate the user sending the transaction
        proxiedLockEth.stake{value: 1 ether}();

        // Verify user's stake and contract balance
        (uint256 amount, uint256 unlockTime) = proxiedLockEth.getStakeDetails(user);
        assertEq(amount, 1 ether);
        assertGt(unlockTime, block.timestamp); // Check lock period is applied
        assertEq(proxiedLockEth.getContractBalance(), 1 ether);
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

        // Verify user's balance and contract balance
        assertEq(user.balance, initialUserBalance + 1 ether);
        (uint256 amount, ) = proxiedLockEth.getStakeDetails(user);
        assertEq(amount, 0); // Stake should be reset
    }

    function testCannotWithdrawBeforeLockPeriod() public {
        // Simulate user staking 1 ETH
        vm.deal(user, 1 ether);
        vm.prank(user);
        proxiedLockEth.stake{value: 1 ether}();

        // Attempt withdrawal before lock period ends
        vm.expectRevert("Tokens are still locked");
        vm.prank(user);
        proxiedLockEth.withdraw();
    }

    function testUpgradeImplementation() public {
        // Deploy the second version of the LockEth contract (V2)
        lockEthV2 = new LockEth();

        // Upgrade the proxy contract to use LockEthV2
        vm.prank(owner);
        proxy.upgrade(address(lockEthV2));

        // Verify the implementation address is updated
        assertEq(proxy.implementation(), address(lockEthV2));
    }

    function testStatePreservationAfterUpgrade() public {
        // Simulate user staking 1 ETH
        vm.deal(user, 1 ether);
        vm.prank(user);
        proxiedLockEth.stake{value: 1 ether}();

        // Deploy the second version of the LockEth contract (V2)
        lockEthV2 = new LockEth();

        // Upgrade the proxy contract to use LockEthV2
        vm.prank(owner);
        proxy.upgrade(address(lockEthV2));

        // Verify state is preserved
        (uint256 amount, uint256 unlockTime) = proxiedLockEth.getStakeDetails(user);
        assertEq(amount, 1 ether);
        assertGt(unlockTime, block.timestamp); // Lock period remains valid
    }
}
