// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";
import {TransparentUpgradeableProxy} from "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";
import {GoldChain} from "../traits/GoldChain.sol";
import {GoldKey} from "../traits/GoldKey.sol";
import {LifePreserver} from "../traits/LifePreserver.sol";
import {PinkLei} from "../traits/PinkLei.sol";
import {PurpleScarf} from "../traits/PurpleScarf.sol";
import {Snake} from "../traits/Snake.sol";
import {UpgradedGoldChain} from "../traits/UpgradedGoldChain.sol";
import {UpgradedLei} from "../traits/UpgradedLei.sol";
import {UpgradedScarf} from "../traits/UpgradedScarf.sol";

// run with: forge script src/script/Deploy.s.sol:Deploy --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY -vvvv
// broadcast with: forge script src/script/Deploy.s.sol:Deploy --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --broadcast

contract Deploy is Test {
    BackedCommunityTokenV1 backedCommunityToken;
    BackedCommunityTokenDescriptorV1 descriptor;
    TransparentUpgradeableProxy proxy;

    // TODO(adamgobes): change this to something else, maybe multisig? need to figure out strategy
    address deployer = 0xE89CB2053A04Daf86ABaa1f4bC6D50744e57d39E;
    address proxyContractAdmin = 0x6b2770A75A928989C1D7356366d4665a6487e1b4;
    address multiSigAddress = 0x9289C561E312d485f41519c2d78D013cdad85C11;

    function run() public {
        // all calls that we want to go on chain go in between startBroadcast and stopBroadcast
        vm.startBroadcast();

        descriptor = new BackedCommunityTokenDescriptorV1();
        backedCommunityToken = new BackedCommunityTokenV1();

        proxy = new TransparentUpgradeableProxy(
            address(backedCommunityToken),
            proxyContractAdmin,
            abi.encodeWithSignature("initialize(address)", address(descriptor))
        );

        // add categories
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("addCategory(string)", "Activity")
        );
        (success, ) = address(proxy).call(
            abi.encodeWithSignature("addCategory(string)", "Contributor")
        );
        (success, ) = address(proxy).call(
            abi.encodeWithSignature("addCategory(string)", "Community")
        );

        vm.stopBroadcast();

        // == verify BackedCommunityTokenV1 owner and TransparentUpgradeableProxy admin were set correctly ==

        (, bytes memory ownerBytes) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );

        address owner = abi.decode(ownerBytes, (address));

        // need to prank since only admin of proxy can call admin related methods
        vm.startPrank(proxyContractAdmin);
        address proxyAdmin = proxy.admin();
        vm.stopPrank();

        require(owner == deployer, "owner was not set correctly");
        require(
            proxyAdmin == proxyContractAdmin,
            "proxy admin was not set correctly"
        );
    }
}
