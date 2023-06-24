// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/deployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address public user = makeAddr("user");

    address priceFeeds;
    uint256 minUSDFundAmt;

    uint256 public constant FUND_AMT = 10 ether;
    uint256 public constant START_ETH = 20 ether;
    address owner;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();

        HelperConfig helperConfig;

        (fundMe, helperConfig) = deployer.run();
        
        (priceFeeds, minUSDFundAmt) = helperConfig.networkConfig();

        owner = fundMe.getOwner();

        vm.deal(user, START_ETH);
    }

    function testMinUSDAmountSetUpCorrectly() public {
        uint256 minUSDAmt = fundMe.getMinFundAmt();
        assertEq(minUSDFundAmt, minUSDAmt);
    }

    function testOwnerSetUpCorrectly() public {
        console.log(msg.sender);
        assertEq(owner, msg.sender);
    }

    function testPriceFeeds() public {
        address priceFeedsAddress = address(fundMe.getPriceFeedsAddress());
        assertEq(priceFeedsAddress, priceFeeds);
    }

    function testPriceFeedsVersionSetUpCorrectly() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testRevertsIfZeroEthFunded() public {
        vm.expectRevert();   // next line should revert
        fundMe.fundMe{value: 0}();
    }

    modifier funded() {
        vm.prank(user);
        fundMe.fundMe{value: FUND_AMT}();
        _;
    }

    function testFundMeUpdatesCorrectly() public funded {
        assertEq(address(fundMe).balance, 10 ether);
        assertEq(fundMe.getDonatorAtIdx(0), user);
        assertEq(fundMe.getDonationsBy(user), 10 ether);
    }

    function test_Withdraw_RevertWhen_CallerNotOwner() public funded {
        vm.prank(user);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function test_Withdraw_WithSingleFunder() public funded {
        uint256 initOwnerBalance = owner.balance;
        uint256 contractInitBalance = address(fundMe).balance;

        vm.prank(owner);
        fundMe.withdraw();

        uint256 finalOwnerBalance = owner.balance;
        uint256 contractFinalBalance = address(fundMe).balance;

        assertEq(contractFinalBalance, 0);
        assertEq(finalOwnerBalance, initOwnerBalance + contractInitBalance);
    }

    function test_Withdraw_WithMultipleFunders() public funded {
        // Arrange
        uint160 numOfFunders = 10;
        uint160 st = 1;
        for (uint160 i = st; i<numOfFunders; i++) {
            // hoax fakes address(i) as msg.sender
            // and funds FUND_AMT to it
            hoax(address(i), START_ETH);
            fundMe.fundMe{value: FUND_AMT}();
        }

        uint256 initOwnerBalance = owner.balance;
        uint256 initFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        uint256 finalOwnerBalance = owner.balance;
        uint256 finalFundMeBalance = address(fundMe).balance;

        // Assert
        assertEq(finalFundMeBalance, 0);
        assertEq(finalOwnerBalance, initOwnerBalance + initFundMeBalance);
        
        vm.expectRevert();
        fundMe.getDonatorAtIdx(0);
    }
}