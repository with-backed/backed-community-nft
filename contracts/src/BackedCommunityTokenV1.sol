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
    // ==== modifiers ====
    modifier onlyAdmin() {
        require(msg.sender == admin, "BackedCommunityTokenV1: not admin");
        _;
    }

    // ==== constructor ====
    function initialize(address _admin, address _descriptor)
        public
        initializer
    {
        __ERC721Soulbound_init("BackedCommunity", "BACKED");
        admin = _admin;
        descriptor = _descriptor;
    }

    // ==== state changing external functions ====

    function addCategory(string memory displayName)
        external
        override
        onlyAdmin
    {
        uint256 currentCategoryId = categoryCount++;
        categoryIdToDisplayName[currentCategoryId] = displayName;
    }

    function addSpecialAccessory(address artContract)
        external
        override
        onlyAdmin
    {
        uint256 currentAccessoryId = specialAccessoryCount++;
        accessoryIdToArtContract[currentAccessoryId] = artContract;
    }

    function setCategoryScores(CategoryScoreChange[] memory changes)
        external
        override
        onlyAdmin
    {
        for (uint256 i = 0; i < changes.length; i++) {
            _setCategoryScore(changes[i]);
        }
    }

    function unlockAccessories(AccessoryUnlockChange[] memory changes)
        external
        override
        onlyAdmin
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

    function setBunnyPFPContract(address addr) external override onlyAdmin {
        bunnyPFPContractAddress = addr;
    }

    function setDescriptorContract(address addr) external override onlyAdmin {
        descriptor = addr;
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
        int256[] memory unlocked = new int256[](specialAccessoryCount);
        for (uint256 i = 0; i < specialAccessoryCount; i++) {
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
        uint256[] memory scores = new uint256[](categoryCount);
        for (uint256 i = 0; i < categoryCount; i++) {
            scores[i] = addressToCategoryScore[owner][i];
        }
        return
            IBackedCommunityTokenDescriptorV1(descriptor).tokenURI(
                owner,
                scores,
                accessoryIdToArtContract[addressToAccessoryEnabled[owner]]
            );
    }

    // === internal & private ===
    function _unlockAccessory(AccessoryUnlockChange memory change) internal {
        addressToAccessoryUnlocked[change.addr][change.accessoryId] = true;
    }

    function _setCategoryScore(CategoryScoreChange memory change) internal {
        addressToCategoryScore[change.addr][change.categoryId] = change.score;
    }
}
