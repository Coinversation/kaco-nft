// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INFT100Common.sol";

// Interface for our erc20 token
interface INFT100Pair721 is INFT100Common{
   
    function swap721(uint256 _in, uint256 _out) external;

    function multi721Deposit(uint256[] calldata _ids, address _referral)
        external;
}