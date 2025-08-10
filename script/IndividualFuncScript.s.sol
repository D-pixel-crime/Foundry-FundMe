// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FundMe} from "../src/FundMe.sol";
import {Script, console} from "forge-std/Script.sol";

contract FundScript is Script {
    function run(address recentDeployment) external {
        vm.startBroadcast();
        FundMe(payable(recentDeployment)).fund{value: 1 ether}();
        vm.stopBroadcast();
    }
}

contract WithdrawScript is Script {
    function run(address recentDeployment) external {
        vm.startBroadcast();
        FundMe(payable(recentDeployment)).withdraw();
        vm.stopBroadcast();
    }
}
