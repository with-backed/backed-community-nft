// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyTraitRenderer} from "./IBackedBunnyTraitRenderer.sol";

contract DefaultTrait is IBackedBunnyTraitRenderer {
    function renderTrait() external pure override returns (string memory) {
        return "";
    }

    function traitName() external pure override returns (string memory) {
        return "Backed Community Member";
    }

    function glowColor() external pure override returns (string memory) {
        return "#aaaaaa";
    }
}
