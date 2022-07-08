// SPDX-License-Identifier: MIT
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

    address multiSigAddress = 0x9289C561E312d485f41519c2d78D013cdad85C11;

    address backedCommunityNFTAddress =
        0x7887BAd2A088027dAbCe45c81229092a4112f622;

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

        address(backedCommunityNFTAddress).call(
            abi.encodeWithSignature(
                "transferOwnership(address)",
                multiSigAddress
            )
        );

        vm.stopBroadcast();

        (, bytes memory ownerBytes) = address(backedCommunityNFTAddress).call(
            abi.encodeWithSignature("owner()")
        );

        address owner = abi.decode(ownerBytes, (address));

        require(owner == multiSigAddress, "owner was not set correctly");
    }
}
