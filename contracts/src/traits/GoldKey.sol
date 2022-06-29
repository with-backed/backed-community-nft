// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./IBackedBunnyAccessory.sol";

contract GoldKey is IBackedBunnyAccessory {
    function xpCategory() external pure override returns (string memory) {
        return "";
    }

    function qualifyingXPScore() external pure override returns (uint256) {
        return 0;
    }

    function renderTrait() external pure override returns (string memory) {
        return
            string.concat(
                string.concat(
                    '<g transform="translate(15 13)">',
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    '<rect x="16" y="29" width="1" height="1" fill="#75B4FF"/>',
                    '<rect x="17" y="30" width="1" height="1" fill="#75B4FF"/>',
                    '<rect x="18" y="31" width="1" height="1" fill="#FFE5A1"/>',
                    '<rect x="19" y="30" width="1" height="1" fill="#F8D270"/>',
                    '<rect x="20" y="30" width="1" height="1" fill="#F8D270"/>',
                    '<rect x="18" y="30" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="19" y="33" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="19" y="33" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="19" y="32" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="18" y="32" width="1" height="1" fill="#FFE5A2"/>'
                ),
                string.concat(
                    '<rect x="20" y="32" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="19" y="34" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="19" y="34" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="20" y="34" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="20" y="35" width="1" height="1" fill="#F8D270"/>',
                    '<rect x="19" y="35" width="1" height="1" fill="#FFE5A2"/>',
                    '<rect x="22" y="29" width="1" height="1" fill="#75B4FF"/>',
                    '<rect x="21" y="30" width="1" height="1" fill="#75B4FF"/>',
                    '<rect x="20" y="31" width="1" height="1" fill="#F8D270"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "Gold Key";
    }

    function glowColor() external pure override returns (string memory) {
        return "#F8D270";
    }
}
