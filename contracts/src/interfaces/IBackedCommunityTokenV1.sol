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

    function addSpecialAccessory(address accessory) external;

    function deleteSpecialAccessory(address accessory) external;

    function unlockAccessoryOrIncrementCategory(
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
        returns (int256[] memory);

    function setBunnyPFPSVGFromL1(bytes calldata message) external;
}
