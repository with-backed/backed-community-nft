// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./IBackedBunnyAccessory.sol";

contract LifePreserver is IBackedBunnyAccessory {
    function renderTrait() external pure override returns (string memory) {
        return
            string.concat(
                string.concat(
                    '<g transform="translate(15 13)">',
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    '<rect x="12" y="23" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="26" y="23" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="11" y="24" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="12" y="24" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="26" y="24" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="27" y="24" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="10" y="25" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="11" y="25" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="12" y="25" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="26" y="25" width="1" height="1" fill="#FB9000"/>'
                ),
                string.concat(
                    '<rect x="27" y="25" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="10" y="26" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="11" y="26" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="12" y="26" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="26" y="26" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="27" y="26" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="28" y="26" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="10" y="27" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="11" y="27" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="12" y="27" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="26" y="27" width="1" height="1" fill="#DDDDDD"/>'
                ),
                string.concat(
                    '<rect x="27" y="27" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="28" y="27" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="10" y="28" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="11" y="28" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="12" y="28" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="26" y="28" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="27" y="28" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="28" y="28" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="11" y="29" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="12" y="29" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="13" y="29" width="1" height="1" fill="#FFA62E"/>'
                ),
                string.concat(
                    '<rect x="14" y="29" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="15" y="29" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="16" y="29" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="17" y="29" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="18" y="29" width="1" height="1" fill="#FAFAFA"/>',
                    '<rect x="19" y="29" width="1" height="1" fill="#FAFAFA"/>',
                    '<rect x="20" y="29" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="21" y="29" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="22" y="29" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="23" y="29" width="1" height="1" fill="#FFB653"/>',
                    '<rect x="24" y="29" width="1" height="1" fill="#FFB653"/>'
                ),
                string.concat(
                    '<rect x="25" y="29" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="26" y="29" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="27" y="29" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="12" y="30" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="13" y="30" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="14" y="30" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="15" y="30" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="16" y="30" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="17" y="30" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="18" y="30" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="19" y="30" width="1" height="1" fill="#EEEEEE"/>'
                ),
                string.concat(
                    '<rect x="20" y="30" width="1" height="1" fill="#FAFAFA"/>',
                    '<rect x="21" y="30" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="22" y="30" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="23" y="30" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="24" y="30" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="25" y="30" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="26" y="30" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="13" y="31" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="14" y="31" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="15" y="31" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="16" y="31" width="1" height="1" fill="#EEEEEE"/>'
                ),
                string.concat(
                    '<rect x="17" y="31" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="18" y="31" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="19" y="31" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="20" y="31" width="1" height="1" fill="#EEEEEE"/>',
                    '<rect x="21" y="31" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="22" y="31" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="23" y="31" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="24" y="31" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="25" y="31" width="1" height="1" fill="#FFA62E"/>',
                    '<rect x="15" y="32" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="16" y="32" width="1" height="1" fill="#DDDDDD"/>'
                ),
                string.concat(
                    '<rect x="17" y="32" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="18" y="32" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="19" y="32" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="20" y="32" width="1" height="1" fill="#DDDDDD"/>',
                    '<rect x="21" y="32" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="22" y="32" width="1" height="1" fill="#FB9000"/>',
                    '<rect x="23" y="32" width="1" height="1" fill="#FB9000"/>',
                    "</svg>",
                    "</g>"
                )
            );
    }

    function traitName() external pure override returns (string memory) {
        return "Preserver of Wisdom";
    }

    function glowColor() external pure override returns (string memory) {
        return "#FFB653";
    }
}
