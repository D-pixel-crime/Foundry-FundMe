// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig hc = new HelperConfig();
        vm.startBroadcast();
        FundMe temp = new FundMe(hc.getEthToUsdProxy());
        vm.stopBroadcast();

        return temp;
    }
}
