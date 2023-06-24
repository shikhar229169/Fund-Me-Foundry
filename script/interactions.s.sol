// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract Fund_FundMe is Script {
    uint256 constant FUND_AMT = 1 ether;
    function fundFundMe(address fundMe) public {
        vm.startBroadcast();
        FundMe(payable(fundMe)).fundMe{value: FUND_AMT}();
        vm.stopBroadcast();
        console.log("Funded Fundme with value", FUND_AMT);
    }

    function run() external {
        address fundMeAddr =  DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(fundMeAddr);
    }
}

contract Withdraw_FundMe is Script {
    function withdrawFundMe(address fundMe) public {
        vm.startBroadcast();
        FundMe(payable(fundMe)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address fundMeAddr =  DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        withdrawFundMe(fundMeAddr);
    }
}