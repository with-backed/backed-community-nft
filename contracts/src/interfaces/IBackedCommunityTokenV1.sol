// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

interface IBackedCommunityTokenV1 {
    struct CategoryOrAccessoryChange {
        bool isCategoryChange;
        address user;
        string categoryId;
        address accessoryId;
        string ipfsLink;
    }

    event CategoryScoreChanged(
        address indexed addr,
        string indexed categoryId,
        string indexed ipfsLink,
        uint256 newScore
    );

    event AccessoryUnlocked(
        address indexed addr,
        address indexed accessory,
        string indexed ipfsLink
    );

    event AccessorySwapped(
        address indexed addr,
        address indexed oldAccessory,
        address indexed newAccessory
    );

    function addAccessory(address accessory) external;

    function removeAccessory(address accessory) external;

    function overrideSpecialAccessory(
        address oldAccessory,
        address newAccessory
    ) external;

    function unlockAccessoryOrIncrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external;

    function setEnabledAccessory(address accessory) external;

    function clearBunnyPFPLink() external;

    function setBunnyPFPContract(address addr) external;

    function setDescriptorContract(address addr) external;

    function setOptimismCrossChainMessengerAddress(address addr) external;

    function getUnlockedAccessoriesForAddress(address addr)
        external
        view
        returns (address[] memory);

    function setBunnyPFPSVGFromL1(bytes calldata message) external;
}
