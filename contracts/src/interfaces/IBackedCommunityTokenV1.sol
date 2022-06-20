// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IBackedCommunityTokenV1 {
    struct Accessory {
        string name;
        bool xpBased;
        address artContract;
        uint256 qualifyingXPScore;
        uint256 xpCategory;
    }

    struct CategoryOrAccessoryChange {
        bool isCategoryChange;
        address addr;
        uint256 changeableId;
        string ipfsLink;
    }

    event CategoryScoreChanged(
        address indexed addr,
        uint256 indexed categoryId,
        string indexed ipfsLink,
        uint256 newScore
    );

    event AccessoryUnlocked(
        address indexed addr,
        uint256 indexed accessoryId,
        string indexed ipfsLink
    );

    event AccessorySwapped(
        address indexed addr,
        uint256 indexed oldAccessory,
        uint256 indexed newAccessory
    );

    function addCategory(string memory displayName) external;

    function addSpecialAccessory(Accessory memory accessory) external;

    function unlockAccessoryOrIncrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external;

    function setEnabledAccessory(uint256 accessoryId) external;

    function linkBunnyPFP(uint256 tokenId) external;

    function setBunnyPFPContract(address addr) external;

    function setDescriptorContract(address addr) external;

    function getUnlockedAccessoriesForAddress(address addr)
        external
        view
        returns (int256[] memory);
}
