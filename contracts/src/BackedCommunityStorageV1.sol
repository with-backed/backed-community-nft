// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";
import {IBackedCommunityTokenV1} from "./interfaces/IBackedCommunityTokenV1.sol";

contract BackedCommunityStorageV1 {
    // @notice keep track of the total number of community NFTs minted
    uint256 public nonce;

    // @notice admin multi sig that stat changes must come from
    address public admin;

    // @notice descriptor contract responsible for rendering SVG
    IBackedCommunityTokenDescriptorV1 public descriptor;

    // @notice category related storage
    uint256 public totalCategoryCount;
    mapping(uint256 => string) public categoryIdToDisplayName;
    mapping(address => mapping(uint256 => uint256))
        public addressToCategoryScore;

    // @notice accessory related storage
    uint256 public totalSpecialyAccessoryCount;
    mapping(uint256 => IBackedCommunityTokenV1.Accessory)
        public accessoryIdToAccessory;
    mapping(address => mapping(uint256 => bool))
        public addressToAccessoryUnlocked;
    mapping(address => uint256) public addressToAccessoryEnabled;

    // @notice storage to link potential BackedBunny PFP series
    address public bunnyPFPContractAddress;
    mapping(address => uint256) public addressToPFPTokenIdLink;

    // @notice storage to map address to when they minted
    mapping(address => uint256) public addressToTimeMinted;
}
