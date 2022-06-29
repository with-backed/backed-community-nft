// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";

import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";
import {DefaultTrait} from "../traits/DefaultTrait.sol";

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
    BackedCommunityTokenDescriptorV1 descriptor;

    address admin = address(1);
    address userOne = address(2);
    address userTwo = address(3);

    uint256 categoryOneId = 0;
    uint256 categoryTwoId = 1;
    uint256 categoryThreeId = 2;

    uint256 adminBasedAccessoryId = 1;
    uint256 xpBasedAccessoryId = 2;

    function setUp() public {
        vm.startPrank(admin);
        communityToken = new BackedCommunityTokenV1();
        vm.stopPrank();

        descriptor = new BackedCommunityTokenDescriptorV1();

        vm.startPrank(admin);
        communityToken.initialize(address(descriptor));

        communityToken.addCategory("ACTIVITY");
        communityToken.addCategory("CONTRIBUTOR");
        communityToken.addCategory("COMMUNITY");
        communityToken.addSpecialAccessory(
            IBackedCommunityTokenV1.Accessory({
                name: "accessory_one",
                xpBased: false,
                artContract: address(10),
                qualifyingXPScore: 0,
                xpCategory: 0
            })
        );
        communityToken.addSpecialAccessory(
            IBackedCommunityTokenV1.Accessory({
                name: "accessory_two",
                xpBased: true,
                artContract: address(10),
                qualifyingXPScore: 2,
                xpCategory: categoryTwoId
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
        assertEq(communityToken.totalCategoryCount(), 3);
        assertEq(communityToken.categoryIdToDisplayName(0), "ACTIVITY");
        assertEq(communityToken.categoryIdToDisplayName(1), "CONTRIBUTOR");
        assertEq(communityToken.categoryIdToDisplayName(2), "COMMUNITY");
    }

    function testAddCategoryFailsIfNotAdmin() public {
        vm.expectRevert("Ownable: caller is not the owner");
        communityToken.addCategory("CATEGORY");
    }

    // @notice accessories added in set up
    function testAddSpecialCategory() public {
        (string memory nameOne, , , , ) = communityToken.accessoryIdToAccessory(
            1
        );
        (string memory nameTwo, , , , ) = communityToken.accessoryIdToAccessory(
            2
        );

        assertEq(communityToken.totalSpecialyAccessoryCount(), 3);
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

        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userOne,
                    changeableId: categoryOneId,
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeTwo = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userOne,
                    changeableId: categoryOneId,
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeThree = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userTwo,
                    changeableId: categoryOneId,
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory changeFour = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userOne,
                    changeableId: categoryTwoId,
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
        emit CategoryScoreChanged(userOne, 0, "", 1);
        emit CategoryScoreChanged(userOne, 0, "", 2);
        emit CategoryScoreChanged(userTwo, 0, "", 1);
        emit CategoryScoreChanged(userOne, 1, "", 1);
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
                    addr: userOne,
                    changeableId: adminBasedAccessoryId,
                    ipfsLink: "",
                    isCategoryChange: false
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory accessoryChangeTwo = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userTwo,
                    changeableId: adminBasedAccessoryId,
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
        emit AccessoryUnlocked(userOne, adminBasedAccessoryId, "");
        emit AccessoryUnlocked(userTwo, adminBasedAccessoryId, "");
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
                    addr: userOne,
                    changeableId: xpBasedAccessoryId,
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
                    addr: userOne,
                    changeableId: adminBasedAccessoryId,
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
                    addr: userOne,
                    changeableId: categoryTwoId,
                    ipfsLink: "",
                    isCategoryChange: true
                });
        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory categoryChangeTwo = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userOne,
                    changeableId: categoryTwoId,
                    ipfsLink: "",
                    isCategoryChange: true
                });

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory categoryChanges = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                2
            );
        categoryChanges[0] = categoryChangeOne;
        categoryChanges[1] = categoryChangeTwo;

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
        vm.startPrank(admin);

        IBackedCommunityTokenV1.CategoryOrAccessoryChange
            memory categoryChangeOne = IBackedCommunityTokenV1
                .CategoryOrAccessoryChange({
                    addr: userOne,
                    changeableId: categoryTwoId,
                    ipfsLink: "",
                    isCategoryChange: true
                }); // user does not qualify since their score will only be 1

        IBackedCommunityTokenV1.CategoryOrAccessoryChange[]
            memory categoryChanges = new IBackedCommunityTokenV1.CategoryOrAccessoryChange[](
                1
            );
        categoryChanges[0] = categoryChangeOne;

        communityToken.unlockAccessoryOrIncrementCategory(categoryChanges);
        vm.stopPrank();

        vm.startPrank(userOne);
        vm.expectRevert(
            "BackedCommunityTokenV1: user not eligible for accessory"
        );
        communityToken.setEnabledAccessory(xpBasedAccessoryId);
        vm.stopPrank();
    }

    function testTokenURI() public {
        communityToken.mint(userOne);
        communityToken.tokenURI(0);
    }
}
