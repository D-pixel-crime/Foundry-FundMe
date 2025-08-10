// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

error unsupported_chain();

contract HelperConfig is Script {
    struct Config {
        address ethToUsdProxy;
    }

    Config public currConfig;

    constructor() {
        if (block.chainid == 11155111) {
            currConfig = Config({ethToUsdProxy: scopeIsSepoliaTestnet()});
        } else {
            currConfig = Config({ethToUsdProxy: scopeIsAnvil()});
        }
    }

    function getEthToUsdProxy() public view returns (address) {
        return currConfig.ethToUsdProxy;
    }

    function scopeIsSepoliaTestnet() internal view returns (address) {
        return vm.envAddress("SEPOLIA_ETH_TO_USD_PROXY");
    }

    function scopeIsAnvil() internal returns (address) {
        // Checking whether there already exists a proxy
        if (currConfig.ethToUsdProxy != address(0)) {
            return currConfig.ethToUsdProxy;
        }

        vm.startBroadcast();
        uint8 decimals = 8;
        MockV3Aggregator mock = new MockV3Aggregator(decimals, 2000 * int256(10 ** decimals)); // Initial roundData;
        vm.stopBroadcast();

        return address(mock);
    }
}
