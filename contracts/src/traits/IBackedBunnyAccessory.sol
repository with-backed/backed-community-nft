// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IBackedBunnyAccessory {
    function renderTrait() external view returns (string memory);

    function traitName() external view returns (string memory);

    function glowColor() external view returns (string memory);
}
