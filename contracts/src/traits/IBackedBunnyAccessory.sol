// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IBackedBunnyAccessory {
    function xpCategory() external view returns (string memory);

    function qualifyingXPScore() external view returns (uint256);

    function renderTrait() external view returns (string memory);

    function traitName() external view returns (string memory);

    function glowColor() external view returns (string memory);
}