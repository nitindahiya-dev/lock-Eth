// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LockEth} from "../src/LockEth.sol";

contract CounterScript is Script {
    LockEth public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new LockEth();

        vm.stopBroadcast();
    }
}
