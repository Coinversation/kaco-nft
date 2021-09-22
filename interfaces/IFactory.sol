// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    function fee() external view returns (uint256);

    function feeTo() external view returns (address);

    function getReferralFee(address) external view returns (uint256);

    function lockFeePerBlock() external view returns (uint256);
}