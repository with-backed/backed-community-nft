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

    function addSpecialAccessory(address accessory)
        external
        override
        onlyOwner
    {
        EnumerableSet.add(accessoriesSet, accessory);
    }

    function deleteSpecialAccessory(address accessory)
        external
        override
        onlyOwner
    {
        EnumerableSet.remove(accessoriesSet, accessory);
    }

    function overrideSpecialAccessory(
        address oldAccessory,
        address newAccessory
    ) {
        deleteSpecialAccessory(oldAccessory);
        addSpecialAccessory(newAccessory);
    }

    function unlockAccessoryOrIncrementCategory(
        CategoryOrAccessoryChange[] memory changes
    ) external override onlyOwner {
        for (uint256 i = 0; i < changes.length; i++) {
            if (changes[i].isCategoryChange) {
                _incrementCategoryScore(changes[i]);
            } else {
                _unlockAccessory(changes[i]);
            }
        }
    }

    function setEnabledAccessory(uint256 accessoryId) external override {
        uint256 oldAccessoryId = addressToAccessoryEnabled[msg.sender];
        require(
            _isAccessoryUnlocked(msg.sender, accessoryId),
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        addressToAccessoryEnabled[msg.sender] = accessoryId;
        emit AccessorySwapped(msg.sender, oldAccessoryId, accessoryId);
    }

    function setBunnyPFPSVGFromL1(bytes calldata message) external override {
        (address owner, string memory svg) = abi.decode(
            message,
            (address, string)
        );
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
        returns (address[] memory)
    {
        uint256 totalAccessories = EnumerableSet.length(accessoriesSet);
        int256[] memory unlocked = new int256[](totalAccessories);
        for (uint256 i = 0; i < totalAccessories; i++) {
            unlocked[i] = _isAccessoryUnlocked(
                user,
                EnumerableSet.at(accessoriesSet, i)
            )
                ? int256(i)
                : -1;
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
                tokenId,
                owner,
                scores,
                IBackedBunnyAccessory(addressToAccessoryEnabled[owner]),
                addressToPFPSVGLink[owner]
            );
    }

    // === internal & private ===
    function _unlockAccessory(CategoryOrAccessoryChange memory change)
        internal
    {
        require(
            change.accessoryId != address(0),
            "BackedCommunityTokenV1: Accessory does not exist"
        );
        require(
            _isAccessoryAdminBased(change.accessoryId),
            "BackedCommunityTokenV1: Accessory must be admin based"
        );

        addressToAccessoryUnlocked[change.user][change.accessoryId] = true;
        emit AccessoryUnlocked(
            change.addr,
            change.accessoryId,
            change.ipfsLink
        );
    }

    function _incrementCategoryScore(CategoryOrAccessoryChange memory change)
        internal
    {
        uint256 newScore = ++addressToCategoryScore[change.user][
            change.categoryId
        ];
        emit CategoryScoreChanged(
            change.user,
            change.categoryId,
            change.ipfsLink,
            newScore
        );
    }

    function _isAccessoryUnlocked(address user, address accessory)
        internal
        view
        returns (bool)
    {
        if (isAccessoryAdminBased(accessory)) {
            return addressToAccessoryUnlocked[addr][accessoryId];
        } else {
            return
                addressToCategoryScore[user][category] >=
                IBackedBunnyAccessory(accessory).qualifyingXPScore();
        }
    }

    function _isAccessoryAdminBased(address accessory) internal view {
        IBackedBunnyAccessory accessory = IBackedBunnyAccessory(accessory);
        return address.xpCategory() == "";
    }
}
