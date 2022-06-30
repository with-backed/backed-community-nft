// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {IBackedCommunityTokenDescriptorV1} from "./interfaces/IBackedCommunityTokenDescriptorV1.sol";
import {IBackedCommunityTokenV1} from "./interfaces/IBackedCommunityTokenV1.sol";
import "../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract BackedCommunityStorageV1 {
    // @notice keep track of the total number of community NFTs minted
    uint256 public nonce;

    // @notice optimism cross chain messenger address
    address public cdmAddr;

    // @notice descriptor contract responsible for rendering SVG
    IBackedCommunityTokenDescriptorV1 public descriptor;

    // @notice category related storage
    uint256 public totalCategoryCount;
    mapping(address => mapping(string => uint256))
        public addressToCategoryScore;

    // @notice accessory related storage

    EnumerableSet.UintSet accessoriesSet;

    uint256 totalAccessoryCount;
    mapping(uint256 => IBackedCommunityTokenV1.Accessory)
        public accessoryIdToAccessory;
    mapping(address => mapping(uint256 => bool))
        public addressToAccessoryUnlocked;
    mapping(address => uint256) public addressToAccessoryEnabled;

    // @notice storage to link potential BackedBunny PFP series
    address public bunnyPFPContractAddress;

    // @notice this mapping is only mutable via message pass from L1 to L2
    // L2 cannot directly mutate this except to clear an entry
    mapping(address => string) public addressToPFPSVGLink;
}
