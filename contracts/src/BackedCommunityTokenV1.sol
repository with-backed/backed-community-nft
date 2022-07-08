// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {IBackedBunnyAccessory} from "./traits/IBackedBunnyAccessory.sol";
import {IBackedCommunityTokenV1} from "./interfaces/IBackedCommunityTokenV1.sol";
import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";
import {BackedCommunityStorageV1} from "./BackedCommunityStorageV1.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {ERC721SoulboundUpgradeable} from "./ERC721SoulboundUpgradeable.sol";
import {ICrossDomainMessenger} from "../lib/optimism/packages/contracts/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract BackedCommunityTokenV1 is
    BackedCommunityStorageV1,
    ERC721SoulboundUpgradeable,
    IBackedCommunityTokenV1
{
    // ==== constructor ====
    function initialize(address _descriptorAddress) public initializer {
        __ERC721Soulbound_init("BackedCommunity", "BACKED");
        descriptor = IBackedCommunityTokenDescriptorV1(_descriptorAddress);
    }

    // ==== state changing external functions ====

    function addAccessory(IBackedCommunityTokenV1.Accessory calldata accessory)
        external
        override
        onlyOwner
        returns (uint256 newAccessoryId)
    {
        unchecked {
            newAccessoryId = ++totalAccessoryCount;
        }

        accessoryIdToAccessory[newAccessoryId] = IBackedCommunityTokenV1
            .Accessory({
                artContract: accessory.artContract,
                xpCategory: accessory.xpCategory,
                qualifyingXPScore: accessory.qualifyingXPScore
            });
        EnumerableSet.add(accessoriesSet, newAccessoryId);

        emit AccessoryAdded(
            newAccessoryId,
            accessory.artContract,
            accessory.xpCategory,
            accessory.qualifyingXPScore
        );
    }

    function removeAccessory(uint256 accessoryId) external override onlyOwner {
        EnumerableSet.remove(accessoriesSet, accessoryId);
        emit AccessoryRemoved(accessoryId);
    }

    function changeAccessoryLockOrCategoryScore(
        CategoryOrAccessoryChange[] memory changes
    ) external override onlyOwner {
        for (uint256 i = 0; i < changes.length; i++) {
            if (changes[i].isCategoryChange) {
                _modifyCategoryScore(changes[i]);
            } else {
                _unlockOrLockAccessory(changes[i]);
            }
        }
    }

    function setEnabledAccessory(uint256 accessoryId) external override {
        uint256 oldAccessory = addressToAccessoryEnabled[msg.sender];
        require(
            _isAccessoryUnlocked(msg.sender, accessoryId),
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        addressToAccessoryEnabled[msg.sender] = accessoryId;
        emit AccessorySwapped(msg.sender, oldAccessory, accessoryId);
    }

    function setBunnyPFPSVGFromL1(
        address owner,
        string calldata svg,
        uint256 tokenId
    ) external override {
        require(
            msg.sender == cdmAddr,
            "BackedCommunityTokenV1: caller must be cross domain messenger"
        );
        require(
            ICrossDomainMessenger(cdmAddr).xDomainMessageSender() ==
                bunnyPFPContractAddress,
            "BackedCommunityTokenV1: origin must be Backed PFP"
        );
        addressToPFPSVGLink[owner] = svg;

        emit BunnyPFPLinked(owner, tokenId);
    }

    function mint(address mintTo) external {
        _mint(mintTo, nonce++);
    }

    function clearBunnyPFPLink() external override {
        addressToPFPSVGLink[msg.sender] = "";
    }

    // === owner only ===

    function setBunnyPFPContract(address addr) external override onlyOwner {
        bunnyPFPContractAddress = addr;
    }

    function setDescriptorContract(address addr) external override onlyOwner {
        descriptor = IBackedCommunityTokenDescriptorV1(addr);
    }

    function setOptimismCrossChainMessengerAddress(address addr)
        external
        override
        onlyOwner
    {
        cdmAddr = addr;
    }

    // ==== external view ====

    function getUnlockedAccessoriesForAddress(address user)
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256 totalAccessories = EnumerableSet.length(accessoriesSet);
        uint256[] memory unlocked = new uint256[](totalAccessories);
        for (uint256 i = 0; i < totalAccessories; i++) {
            unlocked[i] = _isAccessoryUnlocked(
                user,
                EnumerableSet.at(accessoriesSet, i)
            )
                ? EnumerableSet.at(accessoriesSet, i)
                : 0;
        }
        return unlocked;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        address owner = ERC721SoulboundUpgradeable(this).ownerOf(tokenId);
        return
            descriptor.tokenURI(
                tokenId,
                owner,
                IBackedBunnyAccessory(
                    accessoryIdToAccessory[addressToAccessoryEnabled[owner]]
                        .artContract
                ),
                addressToPFPSVGLink[owner]
            );
    }

    // === internal & private ===
    function _unlockOrLockAccessory(CategoryOrAccessoryChange memory change)
        internal
    {
        require(
            accessoryIdToAccessory[change.accessoryId].artContract !=
                address(0),
            "BackedCommunityTokenV1: Accessory does not exist"
        );
        require(
            _isAccessoryAdminBased(change.accessoryId),
            "BackedCommunityTokenV1: Accessory must be admin based"
        );
        bool unlock = change.value > 0;

        addressToAccessoryUnlocked[change.user][change.accessoryId] = unlock
            ? true
            : false;

        emit AccessoryLockChanged(
            change.user,
            change.accessoryId,
            change.ipfsLink,
            unlock,
            keccak256(abi.encode(change.user, change.accessoryId, unlock))
        );
    }

    function _modifyCategoryScore(CategoryOrAccessoryChange memory change)
        internal
    {
        uint256 oldScore = addressToCategoryScore[change.user][
            change.categoryId
        ];
        int256 newScore = int256(
            addressToCategoryScore[change.user][change.categoryId]
        ) + change.value;
        require(newScore >= 0, "BackedCommunityTokenV1: XP cannot go below 0");
        addressToCategoryScore[change.user][change.categoryId] = uint256(
            newScore
        );

        emit CategoryScoreChanged(
            change.user,
            change.ipfsLink,
            change.categoryId,
            uint256(newScore),
            oldScore,
            keccak256(
                abi.encode(change.user, change.categoryId, newScore, oldScore)
            )
        );
    }

    function _isAccessoryUnlocked(address user, uint256 accessoryId)
        internal
        view
        returns (bool)
    {
        if (accessoryId == 0) {
            return true;
        }
        IBackedCommunityTokenV1.Accessory
            memory accessory = accessoryIdToAccessory[accessoryId];
        if (_isAccessoryAdminBased(accessoryId)) {
            return addressToAccessoryUnlocked[user][accessoryId];
        } else {
            return
                addressToCategoryScore[user][accessory.xpCategory] >=
                accessory.qualifyingXPScore;
        }
    }

    function _isAccessoryAdminBased(uint256 accessoryId)
        internal
        view
        returns (bool)
    {
        IBackedCommunityTokenV1.Accessory
            memory accessory = accessoryIdToAccessory[accessoryId];
        return bytes(accessory.xpCategory).length == 0;
    }
}
