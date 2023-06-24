// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

error FundMe__lessETHSent();
error FundMe__notOwner();
error FundMe__txnFailed();

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    address private immutable owner;
    address[] private donators;
    mapping (address => uint256) private donationsBy;

    AggregatorV3Interface private priceFeeds;
    uint256 private immutable minUSDFundAmt;

    constructor(address priceFeedsAddress, uint256 _minFundAmt) {
        require(_minFundAmt > 0, "Minimum funding amount can't be 0");

        owner = msg.sender;
        priceFeeds = AggregatorV3Interface(priceFeedsAddress);
        minUSDFundAmt = _minFundAmt;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert FundMe__notOwner();
        }
        _;
    }

    function getUSDPrice(uint256 ethAmount) public view returns (uint256 amtInUSD) {
        (,int256 answer,,,) = priceFeeds.latestRoundData();
        uint256 ethPrice = uint256(answer * 1e10);
        amtInUSD = (ethAmount * ethPrice) / 1e18;
    }

    function fundMe() public payable {
        if (getUSDPrice(msg.value) < minUSDFundAmt) {
            revert FundMe__lessETHSent();
        }

        if (donationsBy[msg.sender] == 0) {
            donators.push(msg.sender);
        }

        donationsBy[msg.sender] += msg.value;
    }


    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Cannot withdraw zero eth");

        uint256 fundersLen = donators.length; 
        address[] memory allDonators = donators;

        for (uint256 i=0; i<fundersLen; i++) {
            donationsBy[allDonators[i]] = 0;
        }

        donators = new address[](0);

        (bool success, ) = payable(owner).call{value: address(this).balance}("");

        if (!success) {
            revert FundMe__txnFailed();
        }
    }

    function getDonatorAtIdx(uint256 idx) public view returns (address) {
        return donators[idx];
    }

    function getDonationsBy(address by) public view returns (uint256) {
        return donationsBy[by];
    }

    function getVersion() public view returns (uint256) {
        return priceFeeds.version();
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getMinFundAmt() public view returns (uint256) {
        return minUSDFundAmt;
    }

    function getPriceFeedsAddress() public view returns (address) {
        return address(priceFeeds);
    }

    receive() external payable {
        fundMe();
    }

    fallback() external payable {
        fundMe();
    }
}