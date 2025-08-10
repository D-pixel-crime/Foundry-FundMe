// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundScript, WithdrawScript} from "../../script/IndividualFuncScript.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeIntegrate is Test {
    FundMe fundMe;

    function setUp() external {
        HelperConfig hc = new HelperConfig();
        vm.startBroadcast();
        fundMe = new FundMe(hc.getEthToUsdProxy());
        vm.stopBroadcast();
        console.log("Contract Address", address(fundMe));
    }

    function test_fundingAndWithdraw() public {
        uint256 totalFunded = 0;
        for (uint160 i = 100; i < 110; i++) {
            address temp = address(100 + i);
            vm.prank(temp);
            vm.deal(temp, 10 ether);
            new FundScript().run(address(fundMe));
            totalFunded += 1 ether;
        }

        assertGe(fundMe.getBalance(), 10 ether);

        vm.prank(msg.sender);
        new WithdrawScript().run(address(fundMe));

        assertEq(fundMe.getBalance(), 0 ether);
    }
}
