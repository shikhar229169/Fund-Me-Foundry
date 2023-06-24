// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/deployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Fund_FundMe, Withdraw_FundMe} from "../../script/interactions.s.sol";
 
contract InteractionsTest is Test {
    FundMe fundMe;
    address owner;

    address user = makeAddr("user");
    uint256 START_ETH = 50 ether;
    uint256 FUND_AMT = 1 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();

        (fundMe, ) = deployer.run();

        owner = fundMe.getOwner();

        vm.deal(user, START_ETH);
    }

    function test_UserCanFundAndOwnerInteractions() public {
        Fund_FundMe fundFundMe = new Fund_FundMe();
        fundFundMe.fundFundMe(address(fundMe));

        Withdraw_FundMe withdrawFundMe = new Withdraw_FundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}