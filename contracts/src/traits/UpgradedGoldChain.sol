// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyTraitRenderer} from "./IBackedBunnyTraitRenderer.sol";

contract UpgradedGoldChain is IBackedBunnyTraitRenderer {
    function renderTrait() external pure override returns (string memory) {
        return
            string.concat(
                string.concat(
                    '<g transform="translate(15 13)">',
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    '<rect x="13" y="29" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="15" y="29" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="16" y="29" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="22" y="29" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="23" y="29" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="25" y="29" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="14" y="30" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="15" y="30" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="16" y="30" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="17" y="30" width="1" height="1" fill="#FFEEA4"/>'
                ),
                string.concat(
                    '<rect x="21" y="30" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="22" y="30" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="23" y="30" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="24" y="30" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="14" y="31" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="16" y="31" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="17" y="31" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="18" y="31" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="20" y="31" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="21" y="31" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="22" y="31" width="1" height="1" fill="#FFEEA4"/>'
                ),
                string.concat(
                    '<rect x="24" y="31" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="15" y="32" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="17" y="32" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="18" y="32" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="19" y="32" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="20" y="32" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="21" y="32" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="23" y="32" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="16" y="33" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="18" y="33" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="19" y="33" width="1" height="1" fill="#FFEEA4"/>'
                ),
                string.concat(
                    '<rect x="20" y="33" width="1" height="1" fill="#FFEEA4"/>',
                    '<rect x="22" y="33" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="17" y="34" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="19" y="34" width="1" height="1" fill="#F8D749"/>',
                    '<rect x="21" y="34" width="1" height="1" fill="#F8D749"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "Super Chain Contributor";
    }

    function glowColor() external pure override returns (string memory) {
        return "#ffcf53";
    }
}
