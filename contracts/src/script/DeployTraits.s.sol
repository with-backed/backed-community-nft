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
            memory pinkLeiAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Pink Lei",
                xpBased: true,
                artContract: address(pinkLei),
                qualifyingXPScore: 1,
                xpCategory: 0
            });
        (bool success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                pinkLeiAccessory
            )
        );

        goldChain = new GoldChain();
        IBackedCommunityTokenV1.Accessory
            memory goldChainAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Gold Chain",
                xpBased: true,
                artContract: address(goldChain),
                qualifyingXPScore: 1,
                xpCategory: 1
            });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                goldChainAccessory
            )
        );

        purpleScarf = new PurpleScarf();
        IBackedCommunityTokenV1.Accessory
            memory purpleScarfAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Purple Scarf",
                xpBased: true,
                artContract: address(purpleScarf),
                qualifyingXPScore: 1,
                xpCategory: 2
            });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                purpleScarfAccessory
            )
        );

        // // upgraded XP based accessories

        upgradedLei = new UpgradedLei();
        IBackedCommunityTokenV1.Accessory
            memory upgradedPinkLeiAccessory = IBackedCommunityTokenV1
                .Accessory({
                    name: "Upgraded Pink Lei",
                    xpBased: true,
                    artContract: address(upgradedLei),
                    qualifyingXPScore: 4,
                    xpCategory: 0
                });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                upgradedPinkLeiAccessory
            )
        );

        upgradedGoldChain = new UpgradedGoldChain();
        IBackedCommunityTokenV1.Accessory
            memory upgradedGoldChainAccessory = IBackedCommunityTokenV1
                .Accessory({
                    name: "Upgraded Gold Chain",
                    xpBased: true,
                    artContract: address(upgradedGoldChain),
                    qualifyingXPScore: 4,
                    xpCategory: 1
                });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                upgradedGoldChainAccessory
            )
        );

        upgradedScarf = new UpgradedScarf();
        IBackedCommunityTokenV1.Accessory
            memory upgradedPurpleScarfAccessory = IBackedCommunityTokenV1
                .Accessory({
                    name: "Upgraded Purple Scarf",
                    xpBased: true,
                    artContract: address(upgradedScarf),
                    qualifyingXPScore: 4,
                    xpCategory: 2
                });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                upgradedPurpleScarfAccessory
            )
        );

        // admin based accessories

        goldKey = new GoldKey();
        IBackedCommunityTokenV1.Accessory
            memory goldKeyAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Gold Key",
                xpBased: false,
                artContract: address(goldKey),
                qualifyingXPScore: 0,
                xpCategory: 0
            });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                goldKeyAccessory
            )
        );

        lifePreserver = new LifePreserver();
        IBackedCommunityTokenV1.Accessory
            memory lifePreserverAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Life Preserver",
                xpBased: false,
                artContract: address(lifePreserver),
                qualifyingXPScore: 0,
                xpCategory: 0
            });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                lifePreserverAccessory
            )
        );

        snake = new Snake();
        IBackedCommunityTokenV1.Accessory
            memory snakeAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Snake",
                xpBased: false,
                artContract: address(snake),
                qualifyingXPScore: 0,
                xpCategory: 0
            });
        (success, ) = backedCommunityNFTAddress.call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                snakeAccessory
            )
        );

        vm.stopBroadcast();
    }
}
