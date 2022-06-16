// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";

import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";
import {TestBackedBunnyPFP} from "./TestBackedBunnyPFP.sol";

contract BackedCommunityTokenV1Test is Test {
    event CategoryScoreChanged(
        address indexed addr,
        uint256 indexed categoryId,
        string indexed ipfsLink,
        uint256 newScore
    );

    event AccessoryUnlocked(
        address indexed addr,
        uint256 indexed accessoryId,
        string indexed ipfsLink
    );

    event AccessorySwapped(
        address indexed addr,
        uint256 indexed oldAccessory,
        uint256 indexed newAccessory
    );

    BackedCommunityTokenV1 communityToken;
    TestBackedBunnyPFP backedBunnyPfp;
    BackedCommunityTokenDescriptorV1 descriptor;

    address admin = address(1);
    address userOne = address(2);
    address userTwo = address(3);

    function setUp() public {
        communityToken = new BackedCommunityTokenV1();
        vm.startPrank(address(0));
        communityToken.transferOwnership(admin);
        vm.stopPrank();

        backedBunnyPfp = new TestBackedBunnyPFP();
        descriptor = new BackedCommunityTokenDescriptorV1();

        vm.startPrank(admin);
        communityToken.initialize(address(descriptor));
        communityToken.setBunnyPFPContract(address(backedBunnyPfp));

        communityToken.addCategory("CATEGORY_ONE");
        communityToken.addCategory("CATEGORY_TWO");
        communityToken.addSpecialAccessory(
            IBackedCommunityTokenV1.Accessory({
                name: "accessory_one",
                xpBased: false,
                artContract: address(0),
                qualifyingXPScore: 0,
                xpCategory: 0
            })
        );
        communityToken.addSpecialAccessory(
            IBackedCommunityTokenV1.Accessory({
                name: "accessory_two",
                xpBased: true,
                artContract: address(0),
                qualifyingXPScore: 2,
                xpCategory: 1
            })
        );

        vm.stopPrank();
    }

    function testInitialize() public {
        assertEq(admin, communityToken.owner());
        assertEq(address(descriptor), address(communityToken.descriptor()));
        assertEq("BackedCommunity", communityToken.name());
        assertEq("BACKED", communityToken.symbol());
    }

    function testSoulbound() public {
        communityToken.mint(userOne);
        assertEq(communityToken.ownerOf(0), userOne);
        vm.expectRevert("ERC721Soulbound: cannot own more than 1");
        communityToken.mint(userOne);

        vm.prank(userOne);
        vm.expectRevert("ERC721Soulbound: only contract owner can transfer");
        communityToken.safeTransferFrom(userOne, userTwo, 0);
    }

    // @notice categories added in set up
    function testAddCategory() public {
        assertEq(communityToken.totalCategoryCount(), 2);
        assertEq(communityToken.categoryIdToDisplayName(0), "CATEGORY_ONE");
        assertEq(communityToken.categoryIdToDisplayName(1), "CATEGORY_TWO");
    }

    function testAddCategoryFailsIfNotAdmin() public {
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.addCategory("CATEGORY");
    }

    // @notice accessories added in set up
    function testAddSpecialCategory() public {
        (string memory nameOne, , , , ) = communityToken.accessoryIdToAccessory(
            0
        );
        (string memory nameTwo, , , , ) = communityToken.accessoryIdToAccessory(
            1
        );

        assertEq(communityToken.totalSpecialyAccessoryCount(), 2);
        assertEq(nameOne, "accessory_one");
        assertEq(nameTwo, "accessory_two");
    }

    function testAddAccessoryFailsIfNotAdmin() public {
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.addSpecialAccessory(
            IBackedCommunityTokenV1.Accessory({
                name: "accessory_three",
                xpBased: false,
                artContract: address(0),
                qualifyingXPScore: 0,
                xpCategory: 0
            })
        );
    }

    function testIncrementCategoryScores() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeOne = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userOne,
                categoryId: 0,
                ipfsLink: ""
            });
        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeTwo = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userOne,
                categoryId: 0,
                ipfsLink: ""
            });
        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeThree = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userTwo,
                categoryId: 0,
                ipfsLink: ""
            });
        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeFour = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userOne,
                categoryId: 1,
                ipfsLink: ""
            });

        IBackedCommunityTokenV1.CategoryScoreChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryScoreChange[](
                4
            );
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;
        changes[3] = changeFour;

        vm.expectEmit(true, true, true, false);
        emit CategoryScoreChanged(userOne, 0, "", 1);
        emit CategoryScoreChanged(userOne, 0, "", 2);
        emit CategoryScoreChanged(userTwo, 0, "", 1);
        emit CategoryScoreChanged(userOne, 1, "", 1);
        communityToken.incrementCategoryScores(changes);

        assertEq(communityToken.addressToCategoryScore(userOne, 0), 2);
        assertEq(communityToken.addressToCategoryScore(userOne, 1), 1);
        assertEq(communityToken.addressToCategoryScore(userTwo, 0), 1);

        vm.stopPrank();
    }

    function testIncrementCategoryScoresFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.CategoryScoreChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryScoreChange[](
                0
            );
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.incrementCategoryScores(changes);
    }

    function testUnlockAccessoriesAdminBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userOne,
                accessoryId: 0,
                ipfsLink: ""
            });
        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeTwo = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userTwo,
                accessoryId: 0,
                ipfsLink: ""
            });

        IBackedCommunityTokenV1.AccessoryUnlockChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryUnlockChange[](
                2
            );
        changes[0] = changeOne;
        changes[1] = changeTwo;

        vm.expectEmit(true, true, true, false);
        emit AccessoryUnlocked(userOne, 0, "");
        emit AccessoryUnlocked(userTwo, 0, "");
        communityToken.unlockAccessories(changes);

        assertTrue(communityToken.addressToAccessoryUnlocked(userOne, 0));
        assertTrue(communityToken.addressToAccessoryUnlocked(userTwo, 0));

        vm.stopPrank();
    }

    function testUnlockAccessoriesFailsWhenXPBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userOne,
                accessoryId: 1,
                ipfsLink: ""
            });

        IBackedCommunityTokenV1.AccessoryUnlockChange[]
            memory accessoryChanges = new IBackedCommunityTokenV1.AccessoryUnlockChange[](
                1
            );
        accessoryChanges[0] = changeOne;

        vm.expectRevert(
            "BackedCommunityTokenV1: Accessory must be admin based"
        );
        communityToken.unlockAccessories(accessoryChanges);
        vm.stopPrank();
    }

    function testUnlockAccessoriesFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.AccessoryUnlockChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryUnlockChange[](
                0
            );
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.unlockAccessories(changes);
    }

    // TODO this should fail cause accessory 33 doesn't exist??
    function testSetEnabledAccessoryAdminBased() public {
        uint256 accessoryId = 33;

        vm.startPrank(userOne);
        vm.expectRevert("BackedCommunityTokenV1: accessory not unlocked");
        communityToken.setEnabledAccessory(accessoryId);
        vm.stopPrank();

        vm.startPrank(admin);
        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userOne,
                accessoryId: accessoryId,
                ipfsLink: ""
            });
        IBackedCommunityTokenV1.AccessoryUnlockChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryUnlockChange[](
                1
            );
        changes[0] = changeOne;
        communityToken.unlockAccessories(changes);
        vm.stopPrank();

        vm.startPrank(userOne);
        communityToken.setEnabledAccessory(accessoryId);
        vm.stopPrank();

        assertEq(
            communityToken.addressToAccessoryEnabled(userOne),
            accessoryId
        );
    }

    function testSetEnabledAccessoryXPBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryScoreChange
            memory categoryChangeOne = IBackedCommunityTokenV1
                .CategoryScoreChange({
                    addr: userOne,
                    categoryId: 1,
                    ipfsLink: ""
                });
        IBackedCommunityTokenV1.CategoryScoreChange
            memory categoryChangeTwo = IBackedCommunityTokenV1
                .CategoryScoreChange({
                    addr: userOne,
                    categoryId: 1,
                    ipfsLink: ""
                });

        IBackedCommunityTokenV1.CategoryScoreChange[]
            memory categoryChanges = new IBackedCommunityTokenV1.CategoryScoreChange[](
                2
            );
        categoryChanges[0] = categoryChangeOne;
        categoryChanges[1] = categoryChangeTwo;

        communityToken.incrementCategoryScores(categoryChanges);
        vm.stopPrank();

        vm.startPrank(userOne);
        communityToken.setEnabledAccessory(1);
        assertEq(communityToken.addressToAccessoryEnabled(userOne), 1);
        vm.stopPrank();
    }

    function testSetEnabledAccessoryXPBasedWhenUserDoesNotQualify() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryScoreChange
            memory categoryChangeOne = IBackedCommunityTokenV1
                .CategoryScoreChange({
                    addr: userOne,
                    categoryId: 1,
                    ipfsLink: ""
                }); // user does not qualify since their score will only be 1

        IBackedCommunityTokenV1.CategoryScoreChange[]
            memory categoryChanges = new IBackedCommunityTokenV1.CategoryScoreChange[](
                1
            );
        categoryChanges[0] = categoryChangeOne;

        communityToken.incrementCategoryScores(categoryChanges);
        vm.stopPrank();

        vm.startPrank(userOne);
        vm.expectRevert("BackedCommunityTokenV1: user does not qualify");
        communityToken.setEnabledAccessory(1);
        vm.stopPrank();
    }

    function testLinkBunnyPFP() public {
        vm.startPrank(userOne);
        uint256 tokenId = backedBunnyPfp.mint();
        communityToken.linkBunnyPFP(tokenId);
        assertEq(communityToken.addressToPFPTokenIdLink(userOne), tokenId);
        vm.stopPrank();
    }

    function testLinkBunnyPFPFailsIfAddressNotOwner() public {
        vm.startPrank(userOne);
        uint256 tokenId = backedBunnyPfp.mint();
        vm.stopPrank();

        vm.startPrank(userTwo);
        vm.expectRevert("BackedCommunityTokenV1: not owner of PFP tokenId");
        communityToken.linkBunnyPFP(tokenId);
        vm.stopPrank();
    }
}
