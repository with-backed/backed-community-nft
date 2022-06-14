// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";

import {IBackedBunnyTraitRenderer} from "./traits/IBackedBunnyTraitRenderer.sol";
import "./utils/Strings.sol";

contract BackedCommunityTokenDescriptorV1 is IBackedCommunityTokenDescriptorV1 {
    uint256 constant activityCategoryId = 0;
    uint256 constant contributorCategoryId = 1;
    uint256 constant communityCategoryId = 2;

    function tokenURI(
        address owner,
        uint256[] memory scores,
        address specialTraitAddress
    ) external view override returns (string memory) {
        bool hasSpecialTrait = specialTraitAddress != address(0);
        string memory traitSVG = hasSpecialTrait
            ? IBackedBunnyTraitRenderer(specialTraitAddress).renderTrait()
            : "";
        string memory traitName = hasSpecialTrait
            ? IBackedBunnyTraitRenderer(specialTraitAddress).traitName()
            : "No trait"; // TODO ask joe about default trait placeholder name
        string memory glowColor = hasSpecialTrait
            ? IBackedBunnyTraitRenderer(specialTraitAddress).glowColor()
            : "#000000";

        return
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 79 99" style="width: 474; height: 594; margin: 100px auto;" xml:space="preserve">',
                    styles(),
                    stars(glowColor),
                    tamogatchi(),
                    stats(owner, scores, traitName),
                    bunnyPfp(),
                    traitSVG,
                    "</svg>"
                )
            );
    }

    function styles() internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<style type="text/css">',
                    ".checker{fill: #fff; opacity: 0.8;}",
                    ".background{fill: #EFEBE7; opacity: 0.4;}",
                    ".st1{font-family: monospace; font-size: 2px; letter-spacing: 0.2px; text-anchor: end;}",
                    ".st2{font-family: monospace; font-size: 2px;}",
                    ".st3{font-family: monospace; font-size: 2px; text-anchor: middle;}",
                    ".empty{fill: #EFEBE7; opacity: 0.8;}",
                    ".activity{fill: #FF5CDB;}",
                    ".contributor{fill: #5653ff;}",
                    ".community{fill: #ffcf53;}",
                    ".starshine{opacity: 0; fill: white;}",
                    "</style>"
                )
            );
    }

    function stars(string memory glowColor)
        internal
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    /* Define XP Stars */
                    "<defs>",
                    '<g id="star" width="3" height="3">',
                    '<rect x="1" y="0" width="1" height="1" />',
                    '<rect x="0" y="1" width="1" height="1" />',
                    '<rect x="1" y="1" width="1" height="1" />',
                    '<rect x="2" y="1" width="1" height="1" />',
                    '<rect x="1" y="2" width="1" height="1" />',
                    "</g>",
                    '<g id="starrow" class="empty" width="21" height="3">',
                    '<use x="0" xlink:href="#star"/>',
                    '<use x="5" xlink:href="#star"/>',
                    '<use x="10" xlink:href="#star"/>',
                    "</g>",
                    '<g id="earnedxp" width="3" height="3">',
                    '<use x="0" xlink:href="#star"/>',
                    '<rect class="starshine" x="0" y="1" width="1" height="1"><animate attributeName="opacity" values="0;.6;0" dur="5s" begin="0s" repeatCount="indefinite" /></rect>',
                    '<rect class="starshine" x="1" y="2" width="1" height="1"><animate attributeName="opacity" values="0;.8;0" dur="5s" begin="2s" repeatCount="indefinite" /></rect>',
                    '<rect class="starshine" x="1" y="1" width="1" height="1"><animate attributeName="opacity" values="0;.5;0" dur="5s" begin="1200ms" repeatCount="indefinite" /></rect>',
                    "</g>",
                    '<g id="counter">',
                    '<use x="3" xlink:href="#star"/>',
                    '<rect class="starshine" x="3" y="1" width="1" height="1"><animate attributeName="opacity" values="0;.6;0" dur="3s" begin="0s" repeatCount="indefinite" /></rect>',
                    '<rect class="starshine" x="4" y="2" width="1" height="1"><animate attributeName="opacity" values="0;.8;0" dur="3s" begin="2s" repeatCount="indefinite" /></rect>',
                    '<rect class="starshine" x="4" y="1" width="1" height="1"><animate attributeName="opacity" values="0;.5;0" dur="3s" begin="1200ms" repeatCount="indefinite" /></rect>',
                    '<rect x="0" y="0" width="1" height="1" />',
                    '<rect x="1" y="2" width="1" height="1" />',
                    '<rect x="7" y="0" width="1" height="1" />',
                    '<rect class="starshine" x="0" y="0" width="1" height="1"><animate attributeName="opacity" values="0;.6;0" dur="4s" begin="0s" repeatCount="indefinite" /></rect>',
                    '<rect class="starshine" x="1" y="2" width="1" height="1"><animate attributeName="opacity" values="0;.8;0" dur="4s" begin="2s" repeatCount="indefinite" /></rect>',
                    '<rect class="starshine" x="7" y="0" width="1" height="1"><animate attributeName="opacity" values="0;.8;0" dur="4s" begin="3s" repeatCount="indefinite" /></rect>',
                    "</g>",
                    /* Define glow filter */
                    '<filter id="glow" x="0" y="0" width="79" height="99" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">',
                    '<feFlood flood-opacity="0" result="BackgroundImageFix"/>',
                    '<feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>',
                    '<feGaussianBlur stdDeviation="6.5"/>',
                    '<feComposite in2="hardAlpha" operator="out"/>',
                    '<feColorMatrix type="matrix" values="0 0 0 0 0.509804 0 0 0 0 0.639216 0 0 0 0 0.368627 0 0 0 0.25 0"/>',
                    "</filter>",
                    '<filter id="shadow" x="-30%" y="-30%" width="160%" height="160%">',
                    '<feFlood result="flood" flood-color="',
                    glowColor,
                    '" flood-opacity=".1"></feFlood>',
                    '<feComposite in="flood" result="mask" in2="SourceGraphic" operator="in"></feComposite>',
                    '<feMorphology in="mask" result="dilated" operator="dilate" radius="4"></feMorphology>',
                    '<feGaussianBlur in="dilated" result="blurred" stdDeviation="3"></feGaussianBlur>',
                    "<feMerge>",
                    '<feMergeNode in="blurred"></feMergeNode>',
                    '<feMergeNode in="SourceGraphic"></feMergeNode>',
                    "</feMerge>",
                    "</filter>",
                    "</defs>"
                )
            );
    }

    function tamogatchi() public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g filter="url(#shadow)">',
                    '<path d="M60.5683 42.4258C62.4008 68.8515 59.2417 79 34.456 79C9.67025 79 6.65071 69.3435 8.41338 42.6718C10.1761 16 14.7636 8 34.456 8C54.1484 8 58.7359 16 60.5683 42.4258Z" fill="white"/>',
                    "</g>"
                )
            );
    }

    function bunnyPfp() internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg" x="15" y="13">',
                    '<rect x="11" y="14" width="17" height="17" fill="black"/>',
                    '<rect x="12" y="15" width="15" height="15" fill="white"/>',
                    '<rect width="1" height="13" transform="matrix(-1 0 0 1 26 16)" fill="#010101"/>',
                    '<rect width="1" height="13" transform="matrix(-1 0 0 1 14 16)" fill="#010101"/>',
                    '<rect width="3" height="1" transform="matrix(-1 0 0 1 21 16)" fill="#010101"/>',
                    '<rect x="6" y="8" width="1" height="4" fill="#010101"/>',
                    '<rect x="16" y="8" width="1" height="2" fill="#010101"/>',
                    '<rect x="24" y="2" width="1" height="2" fill="#010101"/>',
                    '<rect x="20" y="8" width="1" height="4" fill="#010101"/>',
                    '<rect x="19" y="4" width="1" height="4" fill="#010101"/>',
                    '<rect x="25" y="4" width="1" height="3" fill="#010101"/>',
                    '<rect x="26" y="7" width="1" height="3" fill="#010101"/>',
                    '<rect x="25" y="10" width="1" height="4" fill="#010101"/>',
                    '<rect x="13" y="13" width="1" height="2" fill="#010101"/>',
                    '<rect x="14" y="15" width="1" height="2" fill="#010101"/>',
                    '<rect x="24" y="14" width="1" height="3" fill="#010101"/>',
                    '<rect x="17" y="10" width="1" height="7" fill="#010101"/>',
                    '<rect x="21" y="12" width="1" height="5" fill="#010101"/>',
                    '<rect x="7" y="7" width="1" height="1" fill="#010101"/>',
                    '<rect x="14" y="6" width="1" height="1" fill="#010101"/>',
                    '<rect x="15" y="7" width="1" height="1" fill="#010101"/>',
                    '<rect x="20" y="2" width="1" height="2" fill="#010101"/>',
                    '<rect x="14" y="9" width="1" height="1" fill="#010101"/>',
                    '<rect x="12" y="12" width="1" height="1" fill="#010101"/>',
                    '<rect x="8" y="6" width="3" height="1" fill="#010101"/>',
                    '<rect x="7" y="12" width="3" height="1" fill="#010101"/>',
                    '<rect x="12" y="10" width="2" height="1" fill="#010101"/>',
                    '<rect x="10" y="11" width="3" height="1" fill="#010101"/>',
                    '<rect x="11" y="5" width="3" height="1" fill="#010101"/>',
                    '<rect x="11" y="6" width="3" height="1" fill="#FEFEFE"/>',
                    '<rect x="21" y="2" width="3" height="2" fill="#FEFEFE"/>',
                    '<rect x="20" y="4" width="5" height="3" fill="#FEFEFE"/>',
                    '<rect x="20" y="7" width="6" height="1" fill="#FEFEFE"/>',
                    '<rect x="21" y="8" width="5" height="2" fill="#FEFEFE"/>',
                    '<rect x="21" y="10" width="4" height="2" fill="#FEFEFE"/>',
                    '<rect x="22" y="12" width="3" height="2" fill="#FEFEFE"/>',
                    '<rect x="22" y="14" width="2" height="3" fill="#FEFEFE"/>',
                    '<rect x="14" y="10" width="3" height="1" fill="#FEFEFE"/>',
                    '<rect x="13" y="11" width="4" height="2" fill="#FEFEFE"/>',
                    '<rect x="14" y="13" width="3" height="2" fill="#FEFEFE"/>',
                    '<rect x="15" y="15" width="2" height="2" fill="#FEFEFE"/>',
                    '<rect x="7" y="11" width="3" height="1" fill="#FEFEFE"/>',
                    '<rect x="8" y="7" width="7" height="1" fill="#FEFEFE"/>',
                    '<rect x="7" y="8" width="9" height="1" fill="#FEFEFE"/>',
                    '<rect x="15" y="9" width="1" height="1" fill="#FEFEFE"/>',
                    '<rect x="7" y="9" width="7" height="1" fill="#FEFEFE"/>',
                    '<rect x="7" y="10" width="5" height="1" fill="#FEFEFE"/>',
                    '<rect x="21" y="1" width="3" height="1" fill="#010101"/>',
                    '<rect width="11" height="1" transform="matrix(-1 0 0 1 25 28)" fill="#010101"/>',
                    '<rect width="11" height="11" transform="matrix(-1 0 0 1 25 17)" fill="#FEFEFE"/>',
                    '<rect x="16" y="20" width="1" height="1" fill="#010101"/>',
                    '<rect x="22" y="20" width="1" height="1" fill="#010101"/>',
                    '<rect x="15" y="21" width="1" height="1" fill="#010101"/>',
                    '<rect x="17" y="21" width="1" height="1" fill="#010101"/>',
                    '<rect x="21" y="21" width="1" height="1" fill="#010101"/>',
                    '<rect x="23" y="21" width="1" height="1" fill="#010101"/>',
                    '<rect x="18" y="24" width="3" height="1" fill="#010101"/>',
                    '<rect x="19" y="25" width="1" height="1" fill="#010101"/>',
                    "</svg>"
                )
            );
    }

    function stats(
        address owner,
        uint256[] memory scores,
        string memory traitName
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g transform="translate(36 51)">',
                    '<text><tspan x="-2" y="2" class="st1">ACTIVITY</tspan><tspan x="-2" y="8" class="st1">CONTRIBUTOR</tspan><tspan x="-2" y="14" class="st1">COMMUNITY</tspan></text>',
                    /* Activity */
                    starRow(scores[activityCategoryId], 0, "activity"),
                    /* Contributor */
                    starRow(scores[contributorCategoryId], 6, "contributor"),
                    /* Community */
                    starRow(scores[communityCategoryId], 12, "community"),
                    "</g>",
                    '<text class="st3"><tspan x="35" y="69">',
                    traitName,
                    '</tspan><tspan x="35" y="72">',
                    substring(Strings.toHexString(owner), 0, 6),
                    "...",
                    substring(Strings.toHexString(owner), 38, 42),
                    "</tspan></text>"
                )
            );
    }

    function starRow(
        uint256 score,
        uint256 yPos,
        string memory className
    ) internal view returns (string memory) {
        bool showStars = score <= 4;
        if (showStars) {
            return
                string(
                    abi.encodePacked(
                        '<use x="0" y="',
                        Strings.toString(yPos),
                        '" xlink:href="#starrow"/>',
                        score >= 1
                            ? string(
                                abi.encodePacked(
                                    '<use x="0" y="',
                                    Strings.toString(yPos),
                                    '" xlink:href="#earnedxp" class="',
                                    className,
                                    '"/>'
                                )
                            )
                            : "",
                        score >= 2
                            ? string(
                                abi.encodePacked(
                                    '<use x="5" y="',
                                    Strings.toString(yPos),
                                    '" xlink:href="#earnedxp" class="',
                                    className,
                                    '"/>'
                                )
                            )
                            : "",
                        score >= 3
                            ? string(
                                abi.encodePacked(
                                    '<use x="10" y="',
                                    Strings.toString(yPos),
                                    '" xlink:href="#earnedxp" class="',
                                    className,
                                    '"/>'
                                )
                            )
                            : "",
                        score >= 4
                            ? string(
                                abi.encodePacked(
                                    '<use x="13" y="',
                                    Strings.toString(yPos),
                                    '" xlink:href="#earnedxp" class="',
                                    className,
                                    '"/>'
                                )
                            )
                            : ""
                    )
                );
        } else {
            return
                string(
                    abi.encodePacked(
                        '<use x="0" y="',
                        Strings.toString(yPos),
                        '" xlink:href="#counter" class="',
                        className,
                        '"/>',
                        '<text x="',
                        Strings.toString(getXPosForCounter(score)),
                        '" y="',
                        Strings.toString(yPos + 2),
                        '" class="st1">x',
                        Strings.toString(score),
                        "</text>"
                    )
                );
        }
    }

    function getXPosForCounter(uint256 value) public pure returns (uint256) {
        if (value < 10) {
            return 14;
        } else if (value < 100) {
            return 15;
        } else {
            return 17;
        }
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}
