// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe currFundMeContract;
    event fund_added(address, uint);
    event funds_withdrawn(uint);
    address defaultSender = msg.sender;

    function setUp() external {
        currFundMeContract = ((new DeployFundMe())).run();
    }

    function test_checkMinUsdNeeded() public view {
        assertEq(currFundMeContract.MIN_USD(), 5e18);
    }

    function test_isOwnerProperlySet() public view {
        assertEq(currFundMeContract.owner(), defaultSender);
    }

    function test_isVersionOK() public view {
        assertEq(currFundMeContract.getVersion(), 4);
    }

    function test_isFundingProper() public {
        address tempUser = address(1001);
        startHoax(tempUser, 10 ether);
        vm.expectEmit(true, true, false, true, address(currFundMeContract));
        emit fund_added(tempUser, 1 ether);
        currFundMeContract.fund{value: 1 ether}();

        assertEq(currFundMeContract.funders(0), tempUser);
        assertEq(currFundMeContract.individualFundings(tempUser), 1 ether);
    }

    function test_areRevertsWorking() public {
        vm.startPrank(address(20));
        vm.deal(address(20), 1 ether);

        vm.expectRevert(address(currFundMeContract));
        currFundMeContract.fund{value: 0.000005 ether}();

        vm.expectRevert(address(currFundMeContract));
        currFundMeContract.withdraw();

        vm.stopPrank();
    }

    function test_isWithdrawWorking() public {
        address prankAddress = address(2);
        vm.prank(prankAddress);
        vm.deal(prankAddress, 10 ether);
        currFundMeContract.fund{value: 1 ether}();

        uint balance = currFundMeContract.getBalance();
        vm.expectEmit(true, true, false, true, address(currFundMeContract));
        emit funds_withdrawn(balance);
        vm.prank(defaultSender);
        currFundMeContract.withdraw();

        assertEq(currFundMeContract.getBalance(), 0 ether);
    }
}
