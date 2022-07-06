// SPDX-License-Identifier: UNLICENSED
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
        _addAccessory(newAccessoryId, accessory);
        emit AccessoryAdded(
            newAccessoryId,
            accessory.artContract,
            accessory.xpCategory,
            accessory.qualifyingXPScore
        );
    }

    function removeAccessory(uint256 accessoryId) external override onlyOwner {
        _removeAccessory(accessoryId);
    }

    function unlockAccessoryOrIncrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external override onlyOwner {
        for (uint256 i = 0; i < changes.length; i++) {
            if (changes[i].isCategoryChange) {
                _modifyCategoryScore(changes[i], true);
            } else {
                _unlockOrLockAccessory(changes[i], true);
            }
        }
    }

    function relockAccessoryOrDecrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external override onlyOwner {
        for (uint256 i = 0; i < changes.length; i++) {
            if (changes[i].isCategoryChange) {
                _modifyCategoryScore(changes[i], false);
            } else {
                _unlockOrLockAccessory(changes[i], false);
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
    function _unlockOrLockAccessory(
        CategoryOrAccessoryChange memory change,
        bool unlock
    ) internal {
        require(
            accessoryIdToAccessory[change.accessoryId].artContract !=
                address(0),
            "BackedCommunityTokenV1: Accessory does not exist"
        );
        require(
            _isAccessoryAdminBased(change.accessoryId),
            "BackedCommunityTokenV1: Accessory must be admin based"
        );

        if (unlock) {
            addressToAccessoryUnlocked[change.user][change.accessoryId] = true;
        } else {
            addressToAccessoryUnlocked[change.user][change.accessoryId] = false;
        }

        emit AccessoryLockChanged(
            change.user,
            change.accessoryId,
            change.ipfsLink,
            unlock,
            keccak256(abi.encode(change.user, change.accessoryId, unlock))
        );
    }

    function _modifyCategoryScore(
        CategoryOrAccessoryChange memory change,
        bool increment
    ) internal {
        uint256 oldScore = addressToCategoryScore[change.user][
            change.categoryId
        ];
        uint256 newScore;
        if (increment) {
            newScore = ++addressToCategoryScore[change.user][change.categoryId];
        } else {
            newScore = --addressToCategoryScore[change.user][change.categoryId];
        }

        emit CategoryScoreChanged(
            change.user,
            change.ipfsLink,
            change.categoryId,
            newScore,
            oldScore,
            keccak256(
                abi.encode(change.user, change.categoryId, newScore, oldScore)
            )
        );
    }

    function _addAccessory(
        uint256 newAccessoryId,
        IBackedCommunityTokenV1.Accessory memory accessory
    ) internal {
        accessoryIdToAccessory[newAccessoryId] = IBackedCommunityTokenV1
            .Accessory({
                artContract: accessory.artContract,
                xpCategory: accessory.xpCategory,
                qualifyingXPScore: accessory.qualifyingXPScore
            });
        EnumerableSet.add(accessoriesSet, newAccessoryId);
    }

    function _removeAccessory(uint256 accessoryId) internal {
        EnumerableSet.remove(accessoriesSet, accessoryId);
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
