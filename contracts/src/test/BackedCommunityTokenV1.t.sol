// SPDX-License-Identifier: MIT
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
        uint256 newScore,
        uint256 oldScore,
        bytes32 ipfsEntryHash
    );

    event AccessoryLockChanged(
        address indexed addr,
        uint256 indexed accessoryId,
        string ipfsLink,
        bool unlocked,
        bytes32 ipfsEntryHash
    );

    event AccessorySwapped(
        address indexed addr,
        uint256 indexed oldAccessory,
        uint256 indexed newAccessory
    );

    BackedCommunityTokenV1 communityToken;
    BackedCommunityTokenDescriptorV1 descriptor;

    string categoryOneId = "ACTIVITY";
    string categoryTwoId = "CONTRIBUTOR";
    string categoryThreeId = "COMMUNITY";

    address admin = address(1);
    address userOne = address(2);
    address userTwo = address(3);

    uint256 adminBasedAccessoryId;
    uint256 xpBasedAccessoryId;

    function setUp() public {
        vm.startPrank(admin);
        communityToken = new BackedCommunityTokenV1();
        vm.stopPrank();

        descriptor = new BackedCommunityTokenDescriptorV1();
        descriptor.setBackedCommunityNFTAddress(address(communityToken));

        vm.startPrank(admin);
        communityToken.initialize(address(descriptor));

        adminBasedAccessoryId = communityToken.addAccessory(
            IBackedCommunityTokenV1.Accessory({
                artContract: address(new GoldKey()),
                xpCategory: "",
                qualifyingXPScore: 0
            })
        );

        xpBasedAccessoryId = communityToken.addAccessory(
            IBackedCommunityTokenV1.Accessory({
                artContract: address(new PinkLei()),
                xpCategory: "ACTIVITY",
                qualifyingXPScore: 1
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

    function testAddAccessoryFailsIfNotAdmin() public {
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.addAccessory(
            IBackedCommunityTokenV1.Accessory({
                artContract: address(0),
                xpCategory: "",
                qualifyingXPScore: 0
            })
        );
    }

    function testIncrementCategoryScores() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryChange
            memory changeOne = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });
        IBackedCommunityTokenV1.CategoryChange
            memory changeTwo = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });
        IBackedCommunityTokenV1.CategoryChange
            memory changeThree = IBackedCommunityTokenV1.CategoryChange({
                user: userTwo,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });
        IBackedCommunityTokenV1.CategoryChange
            memory changeFour = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryTwoId,
                ipfsLink: "",
                value: 1
            });

        IBackedCommunityTokenV1.CategoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryChange[](4);
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;
        changes[3] = changeFour;

        vm.expectEmit(true, true, true, false);
        emit CategoryScoreChanged(userOne, categoryOneId, "", 1, 0, "");
        emit CategoryScoreChanged(userOne, categoryOneId, "", 2, 1, "");
        emit CategoryScoreChanged(userTwo, categoryOneId, "", 1, 0, "");
        emit CategoryScoreChanged(userOne, categoryTwoId, "", 1, 0, "");
        communityToken.changeCategoryScores(changes);

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
        IBackedCommunityTokenV1.CategoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryChange[](0);
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.changeCategoryScores(changes);
    }

    function testUnlockAccessoriesAdminBased() public {
        vm.startPrank(admin);

        IBackedCommunityTokenV1.AccessoryChange
            memory accessoryChangeOne = IBackedCommunityTokenV1
                .AccessoryChange({
                    user: userOne,
                    accessoryId: adminBasedAccessoryId,
                    ipfsLink: "",
                    unlock: true
                });
        IBackedCommunityTokenV1.AccessoryChange
            memory accessoryChangeTwo = IBackedCommunityTokenV1
                .AccessoryChange({
                    user: userTwo,
                    accessoryId: adminBasedAccessoryId,
                    ipfsLink: "",
                    unlock: true
                });

        IBackedCommunityTokenV1.AccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryChange[](2);
        changes[0] = accessoryChangeOne;
        changes[1] = accessoryChangeTwo;

        vm.expectEmit(true, true, true, false);
        emit AccessoryLockChanged(userOne, adminBasedAccessoryId, "", true, "");
        emit AccessoryLockChanged(userTwo, adminBasedAccessoryId, "", true, "");
        communityToken.changeAccessoryLocks(changes);

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

        IBackedCommunityTokenV1.AccessoryChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryChange({
                user: userOne,
                accessoryId: xpBasedAccessoryId,
                ipfsLink: "",
                unlock: true
            });

        IBackedCommunityTokenV1.AccessoryChange[]
            memory accessoryChanges = new IBackedCommunityTokenV1.AccessoryChange[](
                1
            );
        accessoryChanges[0] = changeOne;

        vm.expectRevert(
            "BackedCommunityTokenV1: Accessory must be admin based"
        );
        communityToken.changeAccessoryLocks(accessoryChanges);
        vm.stopPrank();
    }

    function testUnlockAccessoriesFailsIfNotAdmin() public {
        IBackedCommunityTokenV1.AccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryChange[](0);
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.changeAccessoryLocks(changes);
    }

    function testSetEnabledAccessoryAdminBased() public {
        vm.startPrank(userOne);
        vm.expectRevert(
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        communityToken.setEnabledAccessory(adminBasedAccessoryId);
        vm.stopPrank();

        vm.startPrank(admin);
        IBackedCommunityTokenV1.AccessoryChange
            memory changeOne = IBackedCommunityTokenV1.AccessoryChange({
                user: userOne,
                accessoryId: adminBasedAccessoryId,
                ipfsLink: "",
                unlock: true
            });
        IBackedCommunityTokenV1.AccessoryChange[]
            memory changes = new IBackedCommunityTokenV1.AccessoryChange[](1);
        changes[0] = changeOne;
        communityToken.changeAccessoryLocks(changes);
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

        IBackedCommunityTokenV1.CategoryChange
            memory categoryChangeOne = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });

        IBackedCommunityTokenV1.CategoryChange[]
            memory categoryChanges = new IBackedCommunityTokenV1.CategoryChange[](
                1
            );
        categoryChanges[0] = categoryChangeOne;

        communityToken.changeCategoryScores(categoryChanges);
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
        IBackedCommunityTokenV1.CategoryChange
            memory changeOne = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });
        IBackedCommunityTokenV1.CategoryChange
            memory changeTwo = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });
        IBackedCommunityTokenV1.CategoryChange
            memory changeThree = IBackedCommunityTokenV1.CategoryChange({
                user: userTwo,
                categoryId: categoryOneId,
                ipfsLink: "",
                value: 1
            });
        IBackedCommunityTokenV1.CategoryChange
            memory changeFour = IBackedCommunityTokenV1.CategoryChange({
                user: userOne,
                categoryId: categoryTwoId,
                ipfsLink: "",
                value: 1
            });

        IBackedCommunityTokenV1.CategoryChange[]
            memory changes = new IBackedCommunityTokenV1.CategoryChange[](4);
        changes[0] = changeOne;
        changes[1] = changeTwo;
        changes[2] = changeThree;
        changes[3] = changeFour;

        communityToken.changeCategoryScores(changes);

        vm.stopPrank();

        communityToken.tokenURI(0);

        vm.startPrank(userOne);
        communityToken.setEnabledAccessory(xpBasedAccessoryId);
        vm.stopPrank();

        console.log(communityToken.tokenURI(0));
    }
}
