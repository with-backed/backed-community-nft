// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedBunnyTraitRenderer} from "./traits/IBackedBunnyTraitRenderer.sol";
import {IBackedCommunityTokenV1} from "./interfaces/IBackedCommunityTokenV1.sol";
import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";
import {BackedCommunityStorageV1} from "./BackedCommunityStorageV1.sol";
import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
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
        IBackedCommunityTokenV1.Accessory
            memory accessory = accessoryIdToAccessory[accessoryId];
        if (accessory.xpBased) {
            require(
                addressToCategoryScore[msg.sender][accessory.xpCategory] >=
                    accessory.qualifyingXPScore,
                "BackedCommunityTokenV1: user does not qualify"
            );
        } else {
            require(
                addressToAccessoryUnlocked[msg.sender][accessoryId],
                "BackedCommunityTokenV1: accessory not unlocked"
            );
        }
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

    function getUnlockedAccessoriesForAddress(address addr)
        external
        view
        override
        returns (int256[] memory)
    {
        int256[] memory unlocked = new int256[](totalSpecialyAccessoryCount);
        for (uint256 i = 0; i < totalSpecialyAccessoryCount; i++) {
            IBackedCommunityTokenV1.Accessory
                memory accessory = accessoryIdToAccessory[i];
            if (accessory.xpBased) {
                unlocked[i] = addressToCategoryScore[addr][
                    accessory.xpCategory
                ] >= accessory.qualifyingXPScore
                    ? int256(i)
                    : -1;
            } else {
                unlocked[i] = addressToAccessoryUnlocked[addr][i]
                    ? int256(i)
                    : -1;
            }
        }
        return unlocked;
    }

    // TODO(adamgobes): write tests for tokenURI
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
                IBackedBunnyTraitRenderer(
                    accessoryIdToAccessory[addressToAccessoryEnabled[owner]]
                        .artContract
                ),
                addressToPFPSVGLink[owner]
            );
    }

    // === internal & private ===
    function _unlockAccessory(CategoryOrAccessoryChange memory change)
        internal
    {
        IBackedCommunityTokenV1.Accessory
            memory accessory = accessoryIdToAccessory[change.changeableId];
        require(
            !accessory.xpBased,
            "BackedCommunityTokenV1: Accessory must be admin based"
        );
        require(
            accessory.artContract != address(0),
            "BackedCommunityTokenV1: Accessory does not exist"
        );

        addressToAccessoryUnlocked[change.addr][change.changeableId] = true;
        emit AccessoryUnlocked(
            change.addr,
            change.changeableId,
            change.ipfsLink
        );
    }

    function _incrementCategoryScore(CategoryOrAccessoryChange memory change)
        internal
    {
        uint256 newScore = ++addressToCategoryScore[change.addr][
            change.changeableId
        ];
        emit CategoryScoreChanged(
            change.addr,
            change.changeableId,
            change.ipfsLink,
            newScore
        );
    }
}
