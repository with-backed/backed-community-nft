// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";
import {TransparentUpgradeableProxy} from "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {IBackedCommunityTokenV1} from "../interfaces/IBackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";
import {DefaultTrait} from "../traits/DefaultTrait.sol";

// run with: forge script src/script/Deploy.s.sol:Deploy --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY -vvvv
// broadcast with: forge script src/script/Deploy.s.sol:Deploy --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --broadcast

contract Deploy is Test {
    BackedCommunityTokenV1 backedCommunityToken;
    BackedCommunityTokenDescriptorV1 descriptor;
    TransparentUpgradeableProxy proxy;

    DefaultTrait defaultTrait;

    // TODO(adamgobes): change this to something else, maybe multisig? need to figure out strategy
    address proxyContractAdmin = 0x6b2770A75A928989C1D7356366d4665a6487e1b4;
    address communityTokenContractOwner =
        0xE89CB2053A04Daf86ABaa1f4bC6D50744e57d39E;

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

        // add default accessory
        defaultTrait = new DefaultTrait();
        IBackedCommunityTokenV1.Accessory
            memory defaultAccessory = IBackedCommunityTokenV1.Accessory({
                name: "Default Trait",
                xpBased: false,
                artContract: address(defaultTrait),
                qualifyingXPScore: 0,
                xpCategory: 0
            });

        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(
                backedCommunityToken.addSpecialAccessory.selector,
                defaultAccessory
            )
        );

        // add categories
        (success, ) = address(proxy).call(
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

        require(
            owner == communityTokenContractOwner,
            "owner was not set correctly"
        );
        require(
            proxyAdmin == proxyContractAdmin,
            "proxy admin was not set correctly"
        );
    }
}
