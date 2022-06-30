// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {GoldChain} from "../traits/GoldChain.sol";
import {GoldKey} from "../traits/GoldKey.sol";
import {LifePreserver} from "../traits/LifePreserver.sol";
import {PinkLei} from "../traits/PinkLei.sol";
import {PurpleScarf} from "../traits/PurpleScarf.sol";
import {Snake} from "../traits/Snake.sol";
import {UpgradedGoldChain} from "../traits/UpgradedGoldChain.sol";
import {UpgradedLei} from "../traits/UpgradedLei.sol";
import {UpgradedScarf} from "../traits/UpgradedScarf.sol";

contract DeployTraits is Test {
    GoldChain goldChain;
    GoldKey goldKey;
    LifePreserver lifePreserver;
    PinkLei pinkLei;
    PurpleScarf purpleScarf;
    Snake snake;
    UpgradedGoldChain upgradedGoldChain;
    UpgradedLei upgradedLei;
    UpgradedScarf upgradedScarf;

    address backedCommunityNFTAddress =
        0x4AbB923Ba68DCE7f256B541Fa6961e6CCfd7EFd1;

    BackedCommunityTokenV1 backedCommunityToken =
        BackedCommunityTokenV1(backedCommunityNFTAddress);

    function run() public {
        vm.startBroadcast();

        // XP based accessories

        pinkLei = new PinkLei();
        IBackedCommunityTokenV1.Accessory
            memory accessory = IBackedCommunityTokenV1.Accessory({
                artContract: address(pinkLei),
                qualifyingXPScore: 1,
                xpCategory: "ACTIVITY"
            });
        (bool success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        goldChain = new GoldChain();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(goldChain),
            qualifyingXPScore: 1,
            xpCategory: "CONTRIBUTOR"
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        purpleScarf = new PurpleScarf();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(purpleScarf),
            qualifyingXPScore: 1,
            xpCategory: "COMMUNITY"
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        // // upgraded XP based accessories

        upgradedLei = new UpgradedLei();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(upgradedLei),
            qualifyingXPScore: 4,
            xpCategory: "ACTIVITY"
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        upgradedGoldChain = new UpgradedGoldChain();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(upgradedGoldChain),
            qualifyingXPScore: 4,
            xpCategory: "CONTRIBUTOR"
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        upgradedScarf = new UpgradedScarf();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(upgradedScarf),
            qualifyingXPScore: 4,
            xpCategory: "COMMUNITY"
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        // admin based accessories

        goldKey = new GoldKey();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(goldKey),
            qualifyingXPScore: 0,
            xpCategory: ""
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        lifePreserver = new LifePreserver();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(lifePreserver),
            qualifyingXPScore: 0,
            xpCategory: ""
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        snake = new Snake();
        accessory = IBackedCommunityTokenV1.Accessory({
            artContract: address(snake),
            qualifyingXPScore: 0,
            xpCategory: ""
        });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addAccessory.selector,
                accessory
            )
        );

        vm.stopBroadcast();
    }
}
