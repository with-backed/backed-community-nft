// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IBackedCommunityTokenV1 {
    struct Accessory {
        address artContract;
        string xpCategory;
        uint256 qualifyingXPScore;
    }

    struct CategoryOrAccessoryChange {
        bool isCategoryChange;
        address user;
        string categoryId;
        uint256 accessoryId;
        string ipfsLink;
    }

    event CategoryScoreChanged(
        address indexed addr,
        string indexed categoryId,
        string indexed ipfsLink,
        uint256 newScore,
        uint256 oldScore,
        string ipfsEntryHash
    );

    event AccessoryLockChanged(
        address indexed addr,
        uint256 indexed accessoryId,
        string indexed ipfsLink,
        bool unlocked,
        string ipfsEntryHash
    );

    event AccessorySwapped(
        address indexed addr,
        uint256 indexed oldAccessory,
        uint256 indexed newAccessory
    );

    function addAccessory(IBackedCommunityTokenV1.Accessory calldata accessory)
        external
        returns (uint256);

    function removeAccessory(uint256 accessoryId) external;

    function unlockAccessoryOrIncrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external;

    function relockAccessoryOrDecrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external;

    function setEnabledAccessory(uint256 accessoryId) external;

    function clearBunnyPFPLink() external;

    function setBunnyPFPContract(address addr) external;

    function setDescriptorContract(address addr) external;

    function setOptimismCrossChainMessengerAddress(address addr) external;

    function getUnlockedAccessoriesForAddress(address addr)
        external
        view
        returns (uint256[] memory);

    function setBunnyPFPSVGFromL1(bytes calldata message) external;
}
