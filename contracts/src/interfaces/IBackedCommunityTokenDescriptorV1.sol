// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IBackedCommunityTokenDescriptorV1 {
    function tokenURI(
        address owner,
        uint256[] memory scores,
        address specialTraitAddress
    ) external view returns (string memory);
}
