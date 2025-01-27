//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceProcessing {
    //function to get price
    function getPriceInUSD() internal view returns (int256) {
        AggregatorV3Interface getPriceData = AggregatorV3Interface(0x001382149eBa3441043c1c66972b4772963f5D43);
        (, int256 answer,,,) = getPriceData.latestRoundData();
        return answer * 1e10;
    }

    //price converter
    function cryptoToFiatConverter(uint256 amount) internal view returns (uint256) {
        uint256 cryptoUSD = uint256(getPriceInUSD());
        require(cryptoUSD > 0, "value must be positive");
        require(amount > 0, "value must be positive");

        uint256 usdValue = (amount * cryptoUSD) / 1e18;
        return usdValue;
    }

    //convert usd to naira
    function USDtoNaira(uint256 USD) internal pure returns (uint256) {
        // GET API data and set parameter to process Conversion in the real world
        uint256 nairaValue = USD;
        return nairaValue;
    }
}
