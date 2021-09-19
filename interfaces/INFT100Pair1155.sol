// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INFT100Common.sol";

// Interface for our erc20 token
interface INFT100Pair1155 is INFT100Common{
  
    function swap1155(
        uint256[] calldata in_ids,
        uint256[] calldata in_amounts,
        uint256[] calldata out_ids,
        uint256[] calldata out_amounts
    ) external;
}