// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IBackedCommunityTokenV1 {
    struct CategoryScoreChange {
        address addr;
        uint256 categoryId;
        uint256 score;
    }

    struct AccessoryUnlockChange {
        address addr;
        uint256 accessoryId;
    }

    function addCategory(string memory displayName) external;

    function addSpecialAccessory(address artContract) external;

    function unlockAccessories(AccessoryUnlockChange[] memory changes) external;

    function setEnabledAccessory(uint256 accessoryId) external;

    function setCategoryScores(CategoryScoreChange[] memory changes) external;

    function linkBunnyPFP(uint256 tokenId) external;

    function setBunnyPFPContract(address addr) external;

    function setDescriptorContract(address addr) external;

    function getUnlockedAccessoriesForAddress(address addr)
        external
        view
        returns (int256[] memory);
}
