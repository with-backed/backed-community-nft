// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "../../lib/forge-std/src/Test.sol";
import "../test/TestBackedBunnyPFP.sol";

contract DeployTestBunnyPFP is Test {
    TestBackedBunnyPFP testBackedBunnyPFP;

    function run() public {
        vm.startBroadcast();

        testBackedBunnyPFP = new TestBackedBunnyPFP(
            0x3da2d3aC4950f862F50f2AB19aFa7F7E39E8fFD5,
            0x4361d0F75A0186C05f971c566dC6bEa5957483fD
        );

        testBackedBunnyPFP.mint();
        testBackedBunnyPFP.linkPFPToCommunityNFT(0);

        vm.stopBroadcast();
    }
}
