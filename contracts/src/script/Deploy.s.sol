// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";
import {TransparentUpgradeableProxy} from "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {BackedCommunityTokenV1} from "../BackedCommunityTokenV1.sol";
import {BackedCommunityTokenDescriptorV1} from "../BackedCommunityTokenDescriptorV1.sol";

contract Deploy is Test {
    BackedCommunityTokenV1 backedCommunityToken;
    BackedCommunityTokenDescriptorV1 descriptor;
    TransparentUpgradeableProxy proxy;

    address admin = 0xE89CB2053A04Daf86ABaa1f4bC6D50744e57d39E;

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

        // verify BackedCommunityTokenV1 owner and TransparentUpgradeableProxy admin were set correctly

        bytes memory ownerData = abi.encodeWithSignature("owner()");

        // need to prank since deployer of proxy cannot ever call underlying logic contract!
        vm.startPrank(address(0));
        (bool success, bytes memory returnBytes) = address(proxy).call(
            ownerData
        );
        address owner = abi.decode(returnBytes, (address));
        vm.stopPrank();

        vm.startPrank(admin);
        address proxyAdmin = proxy.admin();
        vm.stopPrank();

        require(owner == admin, "owner was not set correctly");
        require(proxyAdmin == admin, "proxy admin was not set correctly");
    }
}
