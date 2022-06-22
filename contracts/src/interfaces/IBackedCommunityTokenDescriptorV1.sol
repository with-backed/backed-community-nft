// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyTraitRenderer} from "../traits/IBackedBunnyTraitRenderer.sol";

interface IBackedCommunityTokenDescriptorV1 {
    function tokenURI(
        address owner,
        uint256[] memory scores,
        IBackedBunnyTraitRenderer specialTraitRenderer,
        string memory bunnyPFPSVG
    ) external view returns (string memory);
}
