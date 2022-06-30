// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";

import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";

import {GoldKey} from "../traits/GoldKey.sol";
import {PinkLei} from "../traits/PinkLei.sol";

contract BackedCommunityTokenV1Test is Test {
    event CategoryScoreChanged(
        address indexed addr,
        string indexed categoryId,
        string indexed ipfsLink,
        uint256 newScore
    );

    event AccessoryLockChanged(
        address indexed addr,
        address indexed accessory,
        string indexed ipfsLink,
        bool unlocked,
        string ipfsEntryHash
    );

    event AccessorySwapped(
        address indexed addr,
        address indexed oldAccessory,
        address indexed newAccessory
    );

    BackedCommunityTokenV1 communityToken;
    BackedCommunityTokenDescriptorV1 descriptor;

    string categoryOneId = "ACTIVITY";
    string categoryTwoId = "CONTRIBUTOR";
    string categoryThreeId = "COMMUNITY";

    address admin = address(1);
    address userOne = address(2);
    address userTwo = address(3);

    address adminBasedAccessoryId;
    address xpBasedAccessoryId;

    function setUp() public {
        vm.startPrank(admin);
        communityToken = new BackedCommunityTokenV1();
        vm.stopPrank();

        descriptor = new BackedCommunityTokenDescriptorV1();
        descriptor.setBackedCommunityNFTAddress(address(communityToken));

        vm.startPrank(admin);
        communityToken.initialize(address(descriptor));

        adminBasedAccessoryId = address(new GoldKey());
        xpBasedAccessoryId = address(new PinkLei());

        communityToken.addAccessory(adminBasedAccessoryId);
        communityToken.addAccessory(xpBasedAccessoryId);

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

    function testAddAccessoryFailsIfNotAdmin() public {
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.addAccessory(address(0));
    }

    function testIncrementCategoryScores() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryOneId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeTwo = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryOneId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeThree = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userTwo,
                    categoryId: categoryOneId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeFour = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryTwoId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                4
            );
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;
        changes[3] = changeFour;

        vm.expectEmit(true, true, true, false);
        emit CategoryScoreChanged(userOne, categoryOneId, "", 1);
        emit CategoryScoreChanged(userOne, categoryOneId, "", 2);
        emit CategoryScoreChanged(userTwo, categoryOneId, "", 1);
        emit CategoryScoreChanged(userOne, categoryTwoId, "", 1);
        communityToken.unlockAccessoryOrIncrementCategory(changes);

        assertEq(
            communityToken.addressToCategoryScore(userOne, categoryOneId),
            2
        );
        assertEq(
            communityToken.addressToCategoryScore(userOne, categoryTwoId),
            1
        );
        assertEq(
            communityToken.addressToCategoryScore(userTwo, categoryOneId),
            1
        );
        assertEq(
            communityToken.addressToCategoryScore(userTwo, categoryTwoId),
            0
        );

        vm.stopPrank();
    }

    function testIncrementCategoryScoresFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                0
            );
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.unlockAccessoryOrIncrementCategory(changes);
    }

    function testUnlockAccessoriesAdminBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory accessoryChangeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    accessoryId: adminBasedAccessoryId,
                    categoryId: "",
                    ipfsLink: "",
                    isCategoryChange: false
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory accessoryChangeTwo = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userTwo,
                    accessoryId: adminBasedAccessoryId,
                    categoryId: "",
                    ipfsLink: "",
                    isCategoryChange: false
                });

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                2
            );
        changes[0] = accessoryChangeOne;
        changes[1] = accessoryChangeTwo;

        vm.expectEmit(true, true, true, false);
        emit AccessoryLockChanged(userOne, adminBasedAccessoryId, "", true, "");
        emit AccessoryLockChanged(userTwo, adminBasedAccessoryId, "", true, "");
        communityToken.unlockAccessoryOrIncrementCategory(changes);

        assertTrue(
            communityToken.addressToAccessoryUnlocked(
                userOne,
                adminBasedAccessoryId
            )
        );
        assertTrue(
            communityToken.addressToAccessoryUnlocked(
                userTwo,
                adminBasedAccessoryId
            )
        );

        vm.stopPrank();
    }

    function testUnlockAccessoriesFailsWhenXPBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    accessoryId: xpBasedAccessoryId,
                    categoryId: "",
                    ipfsLink: "",
                    isCategoryChange: false
                });

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory accessoryChanges = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                1
            );
        accessoryChanges[0] = changeOne;

        vm.expectRevert(
            "BackedCommunityTokenV1: Accessory must be admin based"
        );
        communityToken.unlockAccessoryOrIncrementCategory(accessoryChanges);
        vm.stopPrank();
    }

    function testUnlockAccessoriesFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                0
            );
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.unlockAccessoryOrIncrementCategory(changes);
    }

    function testSetEnabledAccessoryAdminBased() public {
        vm.startPrank(userOne);
        vm.expectRevert(
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        communityToken.setEnabledAccessory(adminBasedAccessoryId);
        vm.stopPrank();

        vm.startPrank(admin);
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    accessoryId: adminBasedAccessoryId,
                    categoryId: "",
                    ipfsLink: "",
                    isCategoryChange: false
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                1
            );
        changes[0] = changeOne;
        communityToken.unlockAccessoryOrIncrementCategory(changes);
        vm.stopPrank();

        vm.startPrank(userOne);
        communityToken.setEnabledAccessory(adminBasedAccessoryId);
        vm.stopPrank();

        assertEq(
            communityToken.addressToAccessoryEnabled(userOne),
            adminBasedAccessoryId
        );
    }

    function testSetEnabledAccessoryXPBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory categoryChangeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryOneId,
                    accessoryId: xpBasedAccessoryId,
                    ipfsLink: "",
                    isCategoryChange: true
                });

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory categoryChanges = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                1
            );
        categoryChanges[0] = categoryChangeOne;

        communityToken.unlockAccessoryOrIncrementCategory(categoryChanges);
        vm.stopPrank();

        vm.startPrank(userOne);
        communityToken.setEnabledAccessory(xpBasedAccessoryId);
        assertEq(
            communityToken.addressToAccessoryEnabled(userOne),
            xpBasedAccessoryId
        );
        vm.stopPrank();
    }

    function testSetEnabledAccessoryXPBasedWhenUserDoesNotQualify() public {
        vm.startPrank(userOne);
        vm.expectRevert(
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        communityToken.setEnabledAccessory(xpBasedAccessoryId);
        vm.stopPrank();
    }

    function testTokenURI() public {
        communityToken.mint(userOne);

        vm.startPrank(admin);
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryOneId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeTwo = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryOneId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeThree = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userTwo,
                    categoryId: categoryOneId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeFour = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    user: userOne,
                    categoryId: categoryTwoId,
                    accessoryId: address(0),
                    ipfsLink: "",
                    isCategoryChange: true
                });

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                4
            );
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;
        changes[3] = changeFour;

        communityToken.unlockAccessoryOrIncrementCategory(changes);

        vm.stopPrank();

        communityToken.tokenURI(0);

        vm.startPrank(userOne);
        communityToken.setEnabledAccessory(address(xpBasedAccessoryId));
        vm.stopPrank();

        communityToken.tokenURI(0);
    }
}
