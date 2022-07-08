// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./IBackedBunnyAccessory.sol";

contract PurpleScarf is IBackedBunnyAccessory {
    function renderTrait() external pure override returns (string memory) {
        return
            string.concat(
                string.concat(
                    '<g transform="translate(15 13)">',
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    '<rect x="7" y="28" width="1" height="1" fill="#241F89"/>',
                    '<rect x="8" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="13" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="14" y="29" width="2" height="1" fill="#423BDC"/>',
                    '<rect x="16" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="17" y="29" width="4" height="1" fill="#423BDC"/>',
                    '<rect x="21" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="22" y="29" width="2" height="1" fill="#423BDC"/>',
                    '<rect x="24" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="8" y="30" width="1" height="1" fill="#241F89"/>'
                ),
                string.concat(
                    '<rect x="12" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="13" y="30" width="2" height="1" fill="#423BDC"/>',
                    '<rect x="15" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="30" width="4" height="1" fill="#423BDC"/>',
                    '<rect x="20" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="21" y="30" width="3" height="1" fill="#423BDC"/>',
                    '<rect x="24" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="7" y="30" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="8" y="31" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="9" y="31" width="3" height="1" fill="#241F89"/>',
                    '<rect x="12" y="31" width="3" height="1" fill="#423BDC"/>'
                ),
                string.concat(
                    '<rect x="15" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="31" width="4" height="1" fill="#423BDC"/>',
                    '<rect x="20" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="21" y="31" width="2" height="1" fill="#423BDC"/>',
                    '<rect x="23" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="8" y="32" width="7" height="1" fill="#423BDC"/>',
                    '<rect x="15" y="32" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="32" width="4" height="1" fill="#423BDC"/>',
                    '<rect x="20" y="32" width="1" height="1" fill="#241F89"/>',
                    '<rect x="7" y="32" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="8" y="33" width="7" height="1" fill="#423BDC"/>'
                ),
                string.concat(
                    '<rect x="16" y="33" width="5" height="1" fill="#423BDC"/>',
                    '<rect x="21" y="33" width="1" height="1" fill="#241F89"/>',
                    '<rect x="10" y="34" width="3" height="1" fill="#423BDC"/>',
                    '<rect x="17" y="34" width="4" height="1" fill="#423BDC"/>',
                    '<rect x="21" y="34" width="1" height="1" fill="#241F89"/>',
                    '<rect x="17" y="35" width="4" height="1" fill="#423BDC"/>',
                    '<rect x="21" y="35" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="36" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="18" y="36" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="20" y="36" width="1" height="1" fill="#241F89"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "Purple Community Scarf";
    }

    function glowColor() external pure override returns (string memory) {
        return "#5653ff";
    }
}
