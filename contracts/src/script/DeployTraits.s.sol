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
        goldChain = new GoldChain();
        purpleScarf = new PurpleScarf();

        // // upgraded XP based accessories

        upgradedLei = new UpgradedLei();
        upgradedGoldChain = new UpgradedGoldChain();
        upgradedScarf = new UpgradedScarf();

        // admin based accessories

        goldKey = new GoldKey();
        lifePreserver = new LifePreserver();
        snake = new Snake();

        vm.stopBroadcast();
    }
}
