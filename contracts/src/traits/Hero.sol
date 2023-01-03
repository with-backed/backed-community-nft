// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./IBackedBunnyAccessory.sol";

contract Hero is IBackedBunnyAccessory {
    function renderTrait() external pure override returns (string memory) {
        return
            string.concat(
                string.concat(
                    '<g transform="translate(15 13)">',
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    '<rect x="13" y="19" width="13" height="4" fill="#FF0000"/>',
                    '<rect x="16" y="20" width="1" height="1" fill="#BB0000"/>',
                    '<rect x="22" y="20" width="1" height="1" fill="#BB0000"/>',
                    '<rect x="15" y="21" width="1" height="1" fill="#BB0000"/>',
                    '<rect x="17" y="21" width="1" height="1" fill="#BB0000"/>',
                    '<rect x="21" y="21" width="1" height="1" fill="#BB0000"/>',
                    '<rect x="23" y="21" width="1" height="1" fill="#BB0000"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "SuperHERO Mask";
    }

    function glowColor() external pure override returns (string memory) {
        return "#aaaaaa";
    }
}
