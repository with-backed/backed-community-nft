// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedCommunityTokenV1} from "./interfaces/IBackedCommunityTokenV1.sol";
import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";
import {BackedCommunityStorageV1} from "./BackedCommunityStorageV1.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ERC721SoulboundUpgradeable} from "./ERC721SoulboundUpgradeable.sol";

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

    function addCategory(string memory displayName)
        external
        override
        onlyOwner
    {
        categoryIdToDisplayName[totalCategoryCount++] = displayName;
    }

    function addSpecialAccessory(
        IBackedCommunityTokenV1.Accessory memory accessory
    ) external override onlyOwner {
        accessoryIdToAccessory[
            totalSpecialyAccessoryCount++
        ] = IBackedCommunityTokenV1.Accessory({
            name: accessory.name,
            xpBased: accessory.xpBased,
            artContract: accessory.artContract,
            qualifyingXPScore: accessory.qualifyingXPScore,
            xpCategory: accessory.xpCategory
        });
    }

    function setCategoryScores(CategoryScoreChange[] memory changes)
        external
        override
        onlyOwner
    {
        for (uint256 i = 0; i < changes.length; i++) {
            _setCategoryScore(changes[i]);
        }
    }

    function unlockAccessories(AccessoryUnlockChange[] memory changes)
        external
        override
        onlyOwner
    {
        for (uint256 i = 0; i < changes.length; i++) {
            _unlockAccessory(changes[i]);
        }
    }

    function setEnabledAccessory(uint256 accessoryId) external override {
        require(
            addressToAccessoryUnlocked[msg.sender][accessoryId],
            "BackedCommunityTokenV1: accessory not unlocked"
        );
        addressToAccessoryEnabled[msg.sender] = accessoryId;
    }

    function linkBunnyPFP(uint256 tokenId) external override {
        require(
            IERC721(bunnyPFPContractAddress).ownerOf(tokenId) == msg.sender,
            "BackedCommunityTokenV1: not owner of PFP tokenId"
        );
        addressToPFPTokenIdLink[msg.sender] = tokenId;
    }

    function setBunnyPFPContract(address addr) external override onlyOwner {
        bunnyPFPContractAddress = addr;
    }

    function setDescriptorContract(address addr) external override onlyOwner {
        descriptor = IBackedCommunityTokenDescriptorV1(addr);
    }

    function mint(address mintTo) external {
        _mint(mintTo, nonce++);
    }

    // ==== external view ====

    function getUnlockedAccessoriesForAddress(address addr)
        external
        view
        override
        returns (int256[] memory)
    {
        int256[] memory unlocked = new int256[](totalSpecialyAccessoryCount);
        for (uint256 i = 0; i < totalSpecialyAccessoryCount; i++) {
            if (addressToAccessoryUnlocked[addr][i]) {
                unlocked[i] = int256(i);
            } else {
                unlocked[i] = -1;
            }
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
        uint256[] memory scores = new uint256[](totalCategoryCount);
        for (uint256 i = 0; i < totalCategoryCount; i++) {
            scores[i] = addressToCategoryScore[owner][i];
        }
        return
            descriptor.tokenURI(
                owner,
                scores,
                accessoryIdToAccessory[addressToAccessoryEnabled[owner]]
                    .artContract
            );
    }

    // === internal & private ===
    function _unlockAccessory(AccessoryUnlockChange memory change) internal {
        IBackedCommunityTokenV1.Accessory
            memory accessory = accessoryIdToAccessory[change.accessoryId];
        if (accessory.xpBased) {
            require(
                addressToCategoryScore[change.addr][accessory.xpCategory] >=
                    accessory.qualifyingXPScore,
                "BackedCommunityTokenV1: user does not qualify"
            );
        }
        addressToAccessoryUnlocked[change.addr][change.accessoryId] = true;
    }

    function _setCategoryScore(CategoryScoreChange memory change) internal {
        addressToCategoryScore[change.addr][change.categoryId] = change.score;
    }
}
