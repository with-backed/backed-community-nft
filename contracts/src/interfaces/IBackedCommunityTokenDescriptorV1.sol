// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "../traits/IBackedBunnyAccessory.sol";

interface IBackedCommunityTokenDescriptorV1 {
    function tokenURI(
        uint256 tokenId,
        address owner,
        IBackedBunnyAccessory accessory,
        string memory bunnyPFPSVG
    ) external view returns (string memory);

    function svgImage(
        address owner,
        IBackedBunnyAccessory accessory,
        string memory bunnyPFPSVG
    ) external view returns (string memory);

    function setBackedCommunityNFTAddress(address addr) external;
}
