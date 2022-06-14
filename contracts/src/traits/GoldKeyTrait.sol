// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyTraitRenderer} from "./IBackedBunnyTraitRenderer.sol";

contract GoldKeyTrait is IBackedBunnyTraitRenderer {
    function renderTrait() external view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg" x="15" y="13">',
                    '<rect x="29" y="23" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="30" y="23" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="24" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="28" y="24" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="29" y="24" width="1" height="1" fill="#344635"/>',
                    '<rect x="30" y="24" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="31" y="24" width="1" height="1" fill="#344635"/>',
                    '<rect x="10" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="11" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="26" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="27" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="28" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="29" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="30" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="31" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="32" y="25" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="10" y="26" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="11" y="26" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="26" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="26" y="26" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="27" y="26" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="28" y="26" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="29" y="26" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="30" y="26" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="31" y="26" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="32" y="26" width="1" height="1" fill="#D93333"/>',
                    '<rect x="10" y="27" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="11" y="27" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="27" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="26" y="27" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="27" y="27" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="28" y="27" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="33" y="27" width="1" height="1" fill="#D93333"/>',
                    '<rect x="10" y="28" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="11" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="13" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="14" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="15" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="16" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="17" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="18" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="19" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="20" y="28" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="10" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="11" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="13" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="14" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="15" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="16" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="17" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="18" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="19" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="20" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="21" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="22" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="23" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="24" y="29" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="12" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="13" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="14" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="15" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="16" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="17" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="18" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="19" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="20" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="21" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="22" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="23" y="30" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="24" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="25" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="26" y="30" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="19" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="20" y="31" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="21" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="22" y="31" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="23" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="24" y="31" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="25" y="31" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="26" y="31" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="27" y="31" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="25" y="32" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="26" y="32" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="27" y="32" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="28" y="32" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="27" y="33" width="1" height="1" fill="#A9C38D"/>',
                    '<rect x="28" y="33" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="28" y="34" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="29" y="34" width="1" height="1" fill="#82A35E"/>',
                    '<rect x="29" y="35" width="1" height="1" fill="#82A35E"/>',
                    "</svg>"
                )
            );
    }

    function traitName() external view override returns (string memory) {
        return "Arbitrary Update Scarf";
    }

    function glowColor() external view override returns (string memory) {
        return "#82A35E";
    }
}
