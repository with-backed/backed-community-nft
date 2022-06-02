// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";

import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";
import {TestBackedBunnyPFP} from "./TestBackedBunnyPFP.sol";

contract BackedCommunityTokenV1Test is Test {
    BackedCommunityTokenV1 communityToken;
    TestBackedBunnyPFP backedBunnyPfp;
    BackedCommunityTokenDescriptorV1 descriptor;

    address admin = address(1);
    address userOne = address(2);
    address userTwo = address(3);

    function setUp() public {
        communityToken = new BackedCommunityTokenV1();
        backedBunnyPfp = new TestBackedBunnyPFP();
        descriptor = new BackedCommunityTokenDescriptorV1();

        communityToken.initialize(admin, address(descriptor));
        vm.startPrank(admin);
        communityToken.setBunnyPFPContract(address(backedBunnyPfp));

        communityToken.addCategory("CATEGORY_ONE");
        communityToken.addCategory("CATEGORY_TWO");
        communityToken.addSpecialAccessory(address(4));
        communityToken.addSpecialAccessory(address(5));

        vm.stopPrank();
    }

    function testInitialize() public {
        assertEq(admin, communityToken.admin());
        assertEq(address(descriptor), communityToken.descriptor());
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
        assertEq(communityToken.categoryCount(), 2);
        assertEq(communityToken.categoryIdToDisplayName(0), "CATEGORY_ONE");
        assertEq(communityToken.categoryIdToDisplayName(1), "CATEGORY_TWO");
    }

    function testAddCategoryFailsIfNotAdmin() public {
        vm.expectRevert("BackedCommunityTokenV1: not admin");
        communityToken.addCategory("CATEGORY");
    }

    // @notice accessories added in set up
    function testAddSpecialCategory() public {
        assertEq(communityToken.specialAccessoryCount(), 2);
        assertEq(communityToken.accessoryIdToArtContract(0), address(4));
        assertEq(communityToken.accessoryIdToArtContract(1), address(5));
    }

    function testAddAccessoryFailsIfNotAdmin() public {
        vm.expectRevert("BackedCommunityTokenV1: not admin");
        communityToken.addSpecialAccessory(address(1));
    }

    function testSetCategoryScores() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeOne = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userOne,
                categoryId: 0,
                score: 10
            });
        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeTwo = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userTwo,
                categoryId: 0,
                score: 20
            });
        IBackedCommunityTokenV1.CategoryScoreChange
            memory changeThree = IBackedCommunityTokenV1.CategoryScoreChange({
                addr: userOne,
                categoryId: 1,
                score: 50
            });

        IBackedCommunityTokenV1.CategoryScoreChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryScoreChange[](
                3
            );
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;

        communityToken.setCategoryScores(changes);

        assertEq(communityToken.addressToCategoryScore(userOne, 0), 10);
        assertEq(communityToken.addressToCategoryScore(userOne, 1), 50);
        assertEq(communityToken.addressToCategoryScore(userTwo, 0), 20);

        vm.stopPrank();
    }

    function testSetCategoryScoresFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.CategoryScoreChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryScoreChange[](
                0
            );
        vm.expectRevert("BackedCommunityTokenV1: not admin");
        communityToken.setCategoryScores(changes);
    }

    function testUnlockAccessories() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userOne,
                accessoryId: 0
            });
        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeTwo = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userTwo,
                accessoryId: 0
            });
        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeThree = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userOne,
                accessoryId: 1
            });

        IBackedCommunityTokenV1.AccessoryUnlockChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryUnlockChange[](
                3
            );
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;

        communityToken.unlockAccessories(changes);

        assertTrue(communityToken.addressToAccessoryUnlocked(userOne, 0));
        assertTrue(communityToken.addressToAccessoryUnlocked(userOne, 1));
        assertTrue(communityToken.addressToAccessoryUnlocked(userTwo, 0));

        vm.stopPrank();
    }

    function testUnlockAccessoriesFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.AccessoryUnlockChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryUnlockChange[](
                0
            );
        vm.expectRevert("BackedCommunityTokenV1: not admin");
        communityToken.unlockAccessories(changes);
    }

    function testSetEnabledAccessory() public {
        uint256 accessoryId = 33;

        vm.startPrank(userOne);
        vm.expectRevert("BackedCommunityTokenV1: accessory not unlocked");
        communityToken.setEnabledAccessory(accessoryId);
        vm.stopPrank();

        vm.startPrank(admin);
        IBackedCommunityTokenV1.AccessoryUnlockChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryUnlockChange({
                addr: userOne,
                accessoryId: accessoryId
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
