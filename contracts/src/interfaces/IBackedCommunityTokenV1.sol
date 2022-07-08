// SPDX-License-Identifier: MIT
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
        int256 value;
        string ipfsLink;
    }

    event CategoryScoreChanged(
        address indexed addr,
        string ipfsLink,
        string categoryId,
        uint256 newScore,
        uint256 oldScore,
        bytes32 ipfsEntryHash
    );

    event AccessoryLockChanged(
        address indexed addr,
        uint256 indexed accessoryId,
        string ipfsLink,
        bool unlocked,
        bytes32 ipfsEntryHash
    );

    event AccessorySwapped(
        address indexed addr,
        uint256 indexed oldAccessory,
        uint256 indexed newAccessory
    );

    event AccessoryAdded(
        uint256 indexed accessoryId,
        address indexed artContract,
        string xpCategory,
        uint256 qualifyingXPScore
    );

    event AccessoryRemoved(uint256 indexed accessoryId);

    event BunnyPFPLinked(address indexed owner, uint256 indexed tokenId);

    function addAccessory(IBackedCommunityTokenV1.Accessory calldata accessory)
        external
        returns (uint256);

    function removeAccessory(uint256 accessoryId) external;

    function changeAccessoryLockOrCategoryScore(
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

    function setBunnyPFPSVGFromL1(
        address owner,
        string calldata svg,
        uint256 tokenId
    ) external;
}
