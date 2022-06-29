// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./IBackedBunnyAccessory.sol";

contract Snake is IBackedBunnyAccessory {
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
                    '<rect x="29" y="23" width="1" height="1" fill="#86A362"/>',
                    '<rect x="30" y="23" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="24" width="1" height="1" fill="#788947"/>',
                    '<rect x="28" y="24" width="1" height="1" fill="#86A362"/>',
                    '<rect x="29" y="24" width="1" height="1" fill="#344635"/>',
                    '<rect x="30" y="24" width="1" height="1" fill="#86A362"/>',
                    '<rect x="31" y="24" width="1" height="1" fill="#344635"/>',
                    '<rect x="10" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="11" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="25" width="1" height="1" fill="#86A362"/>'
                ),
                string.concat(
                    '<rect x="26" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="27" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="28" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="29" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="30" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="31" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="32" y="25" width="1" height="1" fill="#86A362"/>',
                    '<rect x="10" y="26" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="11" y="26" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="26" width="1" height="1" fill="#788947"/>',
                    '<rect x="26" y="26" width="1" height="1" fill="#86A362"/>'
                ),
                string.concat(
                    '<rect x="27" y="26" width="1" height="1" fill="#91B36D"/>',
                    '<rect x="28" y="26" width="1" height="1" fill="#91B36D"/>',
                    '<rect x="29" y="26" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="30" y="26" width="1" height="1" fill="#86A362"/>',
                    '<rect x="31" y="26" width="1" height="1" fill="#86A362"/>',
                    '<rect x="32" y="26" width="1" height="1" fill="#D93333"/>',
                    '<rect x="10" y="27" width="1" height="1" fill="#86A362"/>',
                    '<rect x="11" y="27" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="27" width="1" height="1" fill="#86A362"/>',
                    '<rect x="26" y="27" width="1" height="1" fill="#86A362"/>',
                    '<rect x="27" y="27" width="1" height="1" fill="#A9C38D"/>'
                ),
                string.concat(
                    '<rect x="28" y="27" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="33" y="27" width="1" height="1" fill="#D93333"/>',
                    '<rect x="10" y="28" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="11" y="28" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="28" width="1" height="1" fill="#788947"/>',
                    '<rect x="13" y="28" width="1" height="1" fill="#86A362"/>',
                    '<rect x="14" y="28" width="1" height="1" fill="#788947"/>',
                    '<rect x="15" y="28" width="1" height="1" fill="#86A362"/>',
                    '<rect x="16" y="28" width="1" height="1" fill="#788947"/>',
                    '<rect x="17" y="28" width="1" height="1" fill="#86A362"/>',
                    '<rect x="18" y="28" width="1" height="1" fill="#788947"/>'
                ),
                string.concat(
                    '<rect x="19" y="28" width="1" height="1" fill="#86A362"/>',
                    '<rect x="20" y="28" width="1" height="1" fill="#788947"/>',
                    '<rect x="10" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="11" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="13" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="14" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="15" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="16" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="17" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="18" y="29" width="1" height="1" fill="#86A362"/>'
                ),
                string.concat(
                    '<rect x="19" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="20" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="21" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="22" y="29" width="1" height="1" fill="#788947"/>',
                    '<rect x="23" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="24" y="29" width="1" height="1" fill="#86A362"/>',
                    '<rect x="12" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="13" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="14" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="15" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="16" y="30" width="1" height="1" fill="#86A362"/>'
                ),
                string.concat(
                    '<rect x="17" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="18" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="19" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="20" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="21" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="22" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="23" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="24" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="25" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="26" y="30" width="1" height="1" fill="#86A362"/>',
                    '<rect x="19" y="31" width="1" height="1" fill="#A9C38D"/>'
                ),
                string.concat(
                    '<rect x="20" y="31" width="1" height="1" fill="#86A362"/>',
                    '<rect x="21" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="22" y="31" width="1" height="1" fill="#86A362"/>',
                    '<rect x="23" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="24" y="31" width="1" height="1" fill="#86A362"/>',
                    '<rect x="25" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="26" y="31" width="1" height="1" fill="#86A362"/>',
                    '<rect x="27" y="31" width="1" height="1" fill="#86A362"/>',
                    '<rect x="25" y="32" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="26" y="32" width="1" height="1" fill="#86A362"/>',
                    '<rect x="27" y="32" width="1" height="1" fill="#86A362"/>'
                ),
                string.concat(
                    '<rect x="28" y="32" width="1" height="1" fill="#86A362"/>',
                    '<rect x="27" y="33" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="28" y="33" width="1" height="1" fill="#86A362"/>',
                    '<rect x="28" y="34" width="1" height="1" fill="#86A362"/>',
                    '<rect x="29" y="34" width="1" height="1" fill="#86A362"/>',
                    '<rect x="29" y="35" width="1" height="1" fill="#86A362"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "Alpha-Snake";
    }

    function glowColor() external pure override returns (string memory) {
        return "#86A362";
    }
}
