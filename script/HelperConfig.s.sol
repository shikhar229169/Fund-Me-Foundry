// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../src/test/MockPriceFeeds.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeeds;
        uint256 minUSDPrice;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 187300000000;

    NetworkConfig public networkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            networkConfig = getSepoliaEthConfig();
        }
        else if (block.chainid == 1) {
            networkConfig = getMainnetEthConfig();
        }
        else {
            networkConfig = getAndCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306,
            50 * 1e18
        );
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            100 * 1e18
        );
    }

    function getAndCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (networkConfig.priceFeeds != address(0)) {
            return networkConfig;
        }
        
        vm.startBroadcast();

        MockV3Aggregator mockPriceFeeds = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);

        vm.stopBroadcast();

        return NetworkConfig(
            address(mockPriceFeeds),
            50 * 1e18
        );
    }
}