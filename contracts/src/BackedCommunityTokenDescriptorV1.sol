// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";

contract BackedCommunityTokenDescriptorV1 is IBackedCommunityTokenDescriptorV1 {
    uint256 constant activityCategoryId = 0;
    uint256 constant contributorCateogryId = 1;
    uint256 constant communityCategoryId = 2;
    uint256 constant communityCallsCategoryId = 3;
    uint256 constant loansReceivedCateogryId = 4;
    uint256 constant loansGivenCateogryId = 5;
    uint256 constant pullRequestsCategoryId = 6;

    function tokenURI(
        address owner,
        uint256[] memory scores,
        address specialTraitAddress
    ) external view override returns (string memory) {
        return "";
    }
}
