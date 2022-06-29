// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./IBackedBunnyAccessory.sol";

contract UpgradedScarf is IBackedBunnyAccessory {
    function xpCategory() external pure override returns (string memory) {
        return "COMMUNITY";
    }

    function qualifyingXPScore() external pure override returns (uint256) {
        return 4;
    }

    function renderTrait() external pure override returns (string memory) {
        return
            string.concat(
                string.concat(
                    '<g transform="translate(15 13)">',
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    '<rect x="6" y="28" width="1" height="1" fill="#241F89"/>',
                    '<rect x="7" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="8" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="13" y="29" width="1" height="1" fill="#191660"/>',
                    '<rect x="14" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="15" y="29" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="16" y="29" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="17" y="29" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="18" y="29" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="19" y="29" width="1" height="1" fill="#241F89"/>'
                ),
                string.concat(
                    '<rect x="20" y="29" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="21" y="29" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="22" y="29" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="23" y="29" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="24" y="29" width="1" height="1" fill="#241F89"/>',
                    '<rect x="6" y="30" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="8" y="30" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="9" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="12" y="30" width="1" height="1" fill="#191660"/>',
                    '<rect x="13" y="30" width="1" height="1" fill="#4742B2"/>',
                    '<rect x="14" y="30" width="1" height="1" fill="#160F90"/>'
                ),
                string.concat(
                    '<rect x="15" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="30" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="17" y="30" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="18" y="30" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="19" y="30" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="20" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="21" y="30" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="22" y="30" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="23" y="30" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="24" y="30" width="1" height="1" fill="#241F89"/>',
                    '<rect x="7" y="31" width="1" height="1" fill="#1F16CE"/>'
                ),
                string.concat(
                    '<rect x="8" y="31" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="9" y="31" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="10" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="11" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="12" y="31" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="13" y="31" width="1" height="1" fill="#160F90"/>',
                    '<rect x="14" y="31" width="1" height="1" fill="#4742B2"/>',
                    '<rect x="15" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="31" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="17" y="31" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="18" y="31" width="1" height="1" fill="#423BDC"/>'
                ),
                string.concat(
                    '<rect x="19" y="31" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="20" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="21" y="31" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="22" y="31" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="23" y="31" width="1" height="1" fill="#241F89"/>',
                    '<rect x="6" y="32" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="8" y="32" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="9" y="32" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="10" y="32" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="11" y="32" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="12" y="32" width="1" height="1" fill="#423BDC"/>'
                ),
                string.concat(
                    '<rect x="13" y="32" width="1" height="1" fill="#4742B2"/>',
                    '<rect x="14" y="32" width="1" height="1" fill="#160F90"/>',
                    '<rect x="15" y="32" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="32" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="17" y="32" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="18" y="32" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="19" y="32" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="20" y="32" width="1" height="1" fill="#241F89"/>',
                    '<rect x="7" y="33" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="8" y="33" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="9" y="33" width="1" height="1" fill="#423BDC"/>'
                ),
                string.concat(
                    '<rect x="10" y="33" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="11" y="33" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="12" y="33" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="13" y="33" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="14" y="33" width="1" height="1" fill="#6966B0"/>',
                    '<rect x="16" y="33" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="17" y="33" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="18" y="33" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="19" y="33" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="20" y="33" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="21" y="33" width="1" height="1" fill="#241F89"/>'
                ),
                string.concat(
                    '<rect x="10" y="34" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="11" y="34" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="12" y="34" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="13" y="34" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="17" y="34" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="18" y="34" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="19" y="34" width="1" height="1" fill="#423BDC"/>',
                    '<rect x="20" y="34" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="21" y="34" width="1" height="1" fill="#241F89"/>',
                    '<rect x="17" y="35" width="1" height="1" fill="#9691FC"/>',
                    '<rect x="18" y="35" width="1" height="1" fill="#423BDC"/>'
                ),
                string.concat(
                    '<rect x="19" y="35" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="20" y="35" width="1" height="1" fill="#1F16CE"/>',
                    '<rect x="21" y="35" width="1" height="1" fill="#241F89"/>',
                    '<rect x="16" y="36" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="18" y="36" width="1" height="1" fill="#655EFE"/>',
                    '<rect x="20" y="36" width="1" height="1" fill="#241F89"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "Super Community Scarf";
    }

    function glowColor() external pure override returns (string memory) {
        return "#5653ff";
    }
}
