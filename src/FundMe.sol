// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error not_owner();
error withdraw_failed();
error insufficient_funds();

library conversionMath {
    function convertEthToUSD(
        uint val,
        AggregatorV3Interface proxy
    ) internal view returns (uint) {
        uint8 decimals = proxy.decimals();
        (, int256 answer, , , ) = proxy.latestRoundData();
        uint rate = uint(answer) * 10 ** (18 - decimals);

        return (rate * val) / 1e18;
    }
}

contract FundMe {
    using conversionMath for uint;
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert not_owner();
        }
        _;
    }
    event funds_withdrawn(uint);
    event fund_added(address, uint);
    address public immutable owner;
    uint public constant MIN_USD = 5e18;
    AggregatorV3Interface public proxy;

    mapping(address => uint) public individualFundings;
    address[] public funders;

    constructor(address proxy_addr) {
        owner = msg.sender;
        proxy = AggregatorV3Interface(proxy_addr);
    }

    function getVersion() public view returns (uint) {
        return proxy.version();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function fund() public payable {
        if (msg.value.convertEthToUSD(proxy) < MIN_USD) {
            revert insufficient_funds();
        }
        if (individualFundings[msg.sender] == 0) {
            funders.push(msg.sender);
        }
        individualFundings[msg.sender] += msg.value;

        emit fund_added(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        for (uint i = 0; i < funders.length; i++) {
            individualFundings[funders[i]] = 0;
        }
        funders = new address[](0);
        uint balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: address(this).balance}(
            ""
        );

        if (!success) {
            revert withdraw_failed();
        } else {
            emit funds_withdrawn(balance);
        }
    }
}
