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

    function addAccessory(address accessory) external override onlyOwner {
        _addAccessory(accessory);
    }

    function removeAccessory(address accessory) external override onlyOwner {
        _removeAccessory(accessory);
    }

    function overrideSpecialAccessory(
        address oldAccessory,
        address newAccessory
    ) external override onlyOwner {
        _removeAccessory(oldAccessory);
        _addAccessory(newAccessory);
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

    function setEnabledAccessory(address accessory) external override {
        address oldAccessory = addressToAccessoryEnabled[msg.sender];
        require(
            _isAccessoryUnlocked(msg.sender, accessory),
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        addressToAccessoryEnabled[msg.sender] = accessory;
        emit AccessorySwapped(msg.sender, oldAccessory, accessory);
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
        address[] memory unlocked = new address[](totalAccessories);
        for (uint256 i = 0; i < totalAccessories; i++) {
            unlocked[i] = _isAccessoryUnlocked(
                user,
                EnumerableSet.at(accessoriesSet, i)
            )
                ? EnumerableSet.at(accessoriesSet, i)
                : address(0);
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
            change.user,
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

    function _addAccessory(address accessory) internal {
        EnumerableSet.add(accessoriesSet, accessory);
    }

    function _removeAccessory(address accessory) internal {
        EnumerableSet.remove(accessoriesSet, accessory);
    }

    function _isAccessoryUnlocked(address user, address accessory)
        internal
        view
        returns (bool)
    {
        if (_isAccessoryAdminBased(accessory)) {
            return addressToAccessoryUnlocked[user][accessory];
        } else {
            return
                addressToCategoryScore[user][
                    IBackedBunnyAccessory(accessory).xpCategory()
                ] >= IBackedBunnyAccessory(accessory).qualifyingXPScore();
        }
    }

    function _isAccessoryAdminBased(address accessoryAddress)
        internal
        view
        returns (bool)
    {
        IBackedBunnyAccessory accessory = IBackedBunnyAccessory(
            accessoryAddress
        );
        return bytes(accessory.xpCategory()).length == 0;
    }
}
