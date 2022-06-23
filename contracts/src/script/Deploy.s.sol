// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";
import {TransparentUpgradeableProxy} from "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";

// run with: forge script src/script/Deploy.s.sol:Deploy --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY -vvvv
// broadcast with: forge script src/script/Deploy.s.sol:Deploy --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --broadcast

contract Deploy is Test {
    BackedCommunityTokenV1 backedCommunityToken;
    BackedCommunityTokenDescriptorV1 descriptor;
    TransparentUpgradeableProxy proxy;

    // TODO(adamgobes): change this to something else, maybe multisig? need to figure out strategy
    address admin = 0xE89CB2053A04Daf86ABaa1f4bC6D50744e57d39E;

    // TODO(adamgobes): configure the initial set of categories and accessories

    function run() public {
        // all calls that we want to go on chain go in between startBroadcast and stopBroadcast
        vm.startBroadcast();

        descriptor = new BackedCommunityTokenDescriptorV1();
        backedCommunityToken = new BackedCommunityTokenV1();

        bytes memory initializerData = abi.encodeWithSignature(
            "initialize(address)",
            address(descriptor)
        );

        proxy = new TransparentUpgradeableProxy(
            address(backedCommunityToken),
            admin,
            initializerData
        );

        vm.stopBroadcast();

        // == verify BackedCommunityTokenV1 owner and TransparentUpgradeableProxy admin were set correctly ==

        // need to prank since deployer of proxy cannot ever call underlying logic contract!
        vm.startPrank(address(0));
        (bool success, bytes memory ownerBytes) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );
        require(success);
        address owner = abi.decode(ownerBytes, (address));
        vm.stopPrank();

        vm.startPrank(admin);
        address proxyAdmin = proxy.admin();
        vm.stopPrank();

        require(owner == admin, "owner was not set correctly");
        require(proxyAdmin == admin, "proxy admin was not set correctly");
    }
}
