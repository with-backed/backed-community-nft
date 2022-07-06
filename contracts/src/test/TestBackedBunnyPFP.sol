// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ICrossDomainMessenger} from "../../lib/optimism/packages/contracts/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract TestBackedBunnyPFP is ERC721 {
    using Strings for uint256;

    uint256 private _nonce = 0;

    uint32 public gasLimitForL2Tx = 3000000;
    address public L2CommunityNFTAddr;
    address public crossDomainMessengerAddr;

    constructor(address communityNFTAddr, address cdmAddr)
        ERC721("TestERC721", "TEST")
    {
        L2CommunityNFTAddr = communityNFTAddr;
        crossDomainMessengerAddr = cdmAddr;
    }

    function mint() external returns (uint256 id) {
        id = mintTo(msg.sender);
    }

    function mintTo(address to) public returns (uint256 id) {
        _mint(to, id = _nonce++);
    }

    function linkPFPToCommunityNFT(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        bytes memory message = abi.encodeWithSignature(
            "setBunnyPFPSVGFromL1(address,string,uint256)",
            msg.sender,
            getSVG(),
            tokenId
        );
        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            L2CommunityNFTAddr,
            message,
            gasLimitForL2Tx // within the free gas limit amount
        );
    }

    function setGasLimitForL2Tx(uint32 limit) public {
        gasLimitForL2Tx = limit;
    }

    function setL2CommunityNFTAddr(address addr) public {
        L2CommunityNFTAddr = addr;
    }

    function setCrossDomainMessengerAddress(address addr) public {
        crossDomainMessengerAddr = addr;
    }

    function getSVG() public pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    string.concat(
                        '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 39 39" style="width: 390px; height: 390px;" xml:space="preserve" shape-rendering="crispEdges">',
                        '<style type="text/css">',
                        "</style>",
                        '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                        '<rect x="11" y="14" width="17" height="17" fill="#BDA075"/>',
                        '<rect x="12" y="15" width="16" height="16" fill="#C6A16A"/>',
                        '<rect x="12" y="15" width="15" height="15" fill="#CCB38C"/>',
                        '<rect x="11" y="14" width="1" height="1" fill="#A3865B"/>',
                        '<rect x="26" y="29" width="1" height="1" fill="#A3865B"/>',
                        '<rect x="27" y="14" width="1" height="1" fill="#A3865B"/>'
                    ),
                    string.concat(
                        '<rect x="26" y="15" width="1" height="1" fill="#A3865B"/>',
                        '<rect x="11" y="30" width="1" height="1" fill="#A3865B"/>',
                        '<rect x="12" y="29" width="1" height="1" fill="#A3865B"/>',
                        '<rect x="12" y="15" width="1" height="1" fill="#A3865B"/>',
                        '<rect x="27" y="30" width="1" height="1" fill="#A3865B"/>',
                        "</svg>",
                        '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                        '<rect x="6" y="8" width="1" height="4" fill="#41355B"/>',
                        '<rect x="16" y="8" width="1" height="2" fill="#41355B"/>',
                        '<rect x="13" y="13" width="1" height="2" fill="#41355B"/>',
                        '<rect x="14" y="15" width="1" height="2" fill="#41355B"/>',
                        '<rect x="17" y="10" width="1" height="7" fill="#41355B"/>'
                    ),
                    string.concat(
                        '<rect x="13" y="16" width="1" height="13" fill="#41355B"/>',
                        '<rect x="25" y="16" width="1" height="13" fill="#41355B"/>',
                        '<rect x="7" y="7" width="1" height="1" fill="#41355B"/>',
                        '<rect x="14" y="6" width="1" height="1" fill="#41355B"/>',
                        '<rect x="15" y="7" width="1" height="1" fill="#41355B"/>',
                        '<rect x="14" y="9" width="1" height="1" fill="#41355B"/>',
                        '<rect x="12" y="12" width="1" height="1" fill="#41355B"/>',
                        '<rect x="8" y="6" width="3" height="1" fill="#41355B"/>',
                        '<rect x="7" y="12" width="3" height="1" fill="#41355B"/>',
                        '<rect x="12" y="10" width="2" height="1" fill="#41355B"/>',
                        '<rect x="10" y="11" width="3" height="1" fill="#41355B"/>'
                    ),
                    string.concat(
                        '<rect x="18" y="16" width="3" height="1" fill="#41355B"/>',
                        '<rect width="1" height="4" transform="matrix(-1 0 0 1 33 8)" fill="#41355B"/>',
                        '<rect width="1" height="2" transform="matrix(-1 0 0 1 23 8)" fill="#41355B"/>',
                        '<rect width="1" height="2" transform="matrix(-1 0 0 1 26 13)" fill="#41355B"/>',
                        '<rect width="1" height="2" transform="matrix(-1 0 0 1 25 15)" fill="#41355B"/>',
                        '<rect width="1" height="7" transform="matrix(-1 0 0 1 22 10)" fill="#41355B"/>',
                        '<rect width="1" height="1" transform="matrix(-1 0 0 1 32 7)" fill="#41355B"/>',
                        '<rect width="1" height="1" transform="matrix(-1 0 0 1 25 6)" fill="#41355B"/>',
                        '<rect width="1" height="1" transform="matrix(-1 0 0 1 24 7)" fill="#41355B"/>',
                        '<rect width="1" height="1" transform="matrix(-1 0 0 1 25 9)" fill="#41355B"/>',
                        '<rect width="1" height="1" transform="matrix(-1 0 0 1 27 12)" fill="#41355B"/>'
                    ),
                    string.concat(
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 31 6)" fill="#41355B"/>',
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 32 12)" fill="#41355B"/>',
                        '<rect width="2" height="1" transform="matrix(-1 0 0 1 27 10)" fill="#41355B"/>',
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 29 11)" fill="#41355B"/>',
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 28 5)" fill="#41355B"/>',
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 28 6)" fill="#5E5573"/>',
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 25 10)" fill="#5E5573"/>',
                        '<rect width="4" height="2" transform="matrix(-1 0 0 1 26 11)" fill="#5E5573"/>',
                        '<rect width="3" height="2" transform="matrix(-1 0 0 1 25 13)" fill="#5E5573"/>',
                        '<rect width="2" height="2" transform="matrix(-1 0 0 1 24 15)" fill="#5E5573"/>',
                        '<rect width="3" height="1" transform="matrix(-1 0 0 1 32 11)" fill="#5E5573"/>'
                    ),
                    string.concat(
                        '<rect width="7" height="1" transform="matrix(-1 0 0 1 31 7)" fill="#5E5573"/>',
                        '<rect width="9" height="1" transform="matrix(-1 0 0 1 32 8)" fill="#5E5573"/>',
                        '<rect width="1" height="1" transform="matrix(-1 0 0 1 24 9)" fill="#5E5573"/>',
                        '<rect width="7" height="1" transform="matrix(-1 0 0 1 32 9)" fill="#5E5573"/>',
                        '<rect width="5" height="1" transform="matrix(-1 0 0 1 32 10)" fill="#5E5573"/>',
                        '<rect x="14" y="28" width="11" height="1" fill="#41355B"/>',
                        '<rect x="11" y="5" width="3" height="1" fill="#41355B"/>',
                        '<rect x="11" y="6" width="3" height="1" fill="#5E5573"/>',
                        '<rect x="14" y="10" width="3" height="1" fill="#5E5573"/>',
                        '<rect x="14" y="17" width="11" height="11" fill="#5E5573"/>',
                        '<rect x="13" y="11" width="4" height="2" fill="#5E5573"/>'
                    ),
                    string.concat(
                        '<rect x="14" y="13" width="3" height="2" fill="#5E5573"/>',
                        '<rect x="15" y="15" width="2" height="2" fill="#5E5573"/>',
                        '<rect x="7" y="11" width="3" height="1" fill="#5E5573"/>',
                        '<rect x="8" y="7" width="7" height="1" fill="#5E5573"/>',
                        '<rect x="7" y="8" width="9" height="1" fill="#5E5573"/>',
                        '<rect x="15" y="9" width="1" height="1" fill="#5E5573"/>',
                        '<rect x="7" y="9" width="7" height="1" fill="#5E5573"/>',
                        '<rect x="7" y="10" width="5" height="1" fill="#5E5573"/>',
                        "</svg>",
                        '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                        '<rect x="13" y="18" width="6" height="6" fill="#FF003D"/>'
                    ),
                    string.concat(
                        '<rect x="20" y="18" width="6" height="6" fill="#FF003D"/>',
                        '<rect x="14" y="19" width="2" height="4" fill="white"/>',
                        '<rect x="21" y="19" width="2" height="4" fill="white"/>',
                        '<rect x="16" y="19" width="2" height="4" fill="black"/>',
                        '<rect x="23" y="19" width="2" height="4" fill="black"/>',
                        '<rect x="19" y="20" width="1" height="1" fill="#FF003D"/>',
                        '<rect x="10" y="20" width="3" height="1" fill="#FF003D"/>',
                        '<rect width="1" height="2" transform="matrix(1 0 0 -1 10 23)" fill="#FF003D"/>',
                        "</svg>",
                        '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">',
                        '<rect x="18" y="24" width="3" height="1" fill="#41355B"/>'
                    ),
                    string.concat(
                        '<rect x="19" y="25" width="1" height="1" fill="#41355B"/>',
                        '<rect x="18" y="26" width="1" height="1" fill="#41355B"/>',
                        '<rect x="20" y="26" width="1" height="1" fill="#41355B"/>',
                        '<rect x="21" y="26" width="1" height="1" fill="#41355B"/>',
                        '<rect x="22" y="26" width="1" height="1" fill="#41355B"/>',
                        '<rect x="17" y="26" width="1" height="1" fill="#41355B"/>',
                        '<rect x="16" y="26" width="1" height="1" fill="#41355B"/>',
                        '<rect x="15" y="25" width="1" height="1" fill="#41355B"/>',
                        '<rect x="23" y="25" width="1" height="1" fill="#41355B"/>',
                        "</svg>",
                        '<svg width="39" height="39" viewBox="0 0 39 39" fill="none" xmlns="http://www.w3.org/2000/svg">'
                    )
                ),
                string.concat(
                    string.concat(
                        '<rect x="7" y="28" width="1" height="1" fill="#241F89"/>',
                        '<rect x="8" y="29" width="1" height="1" fill="#241F89"/>',
                        '<rect x="13" y="29" width="1" height="1" fill="#241F89"/>',
                        '<rect x="14" y="29" width="2" height="1" fill="#423BDC"/>',
                        '<rect x="16" y="29" width="1" height="1" fill="#241F89"/>',
                        '<rect x="17" y="29" width="4" height="1" fill="#423BDC"/>',
                        '<rect x="21" y="29" width="1" height="1" fill="#241F89"/>',
                        '<rect x="22" y="29" width="2" height="1" fill="#423BDC"/>',
                        '<rect x="24" y="29" width="1" height="1" fill="#241F89"/>',
                        '<rect x="8" y="30" width="1" height="1" fill="#241F89"/>',
                        '<rect x="12" y="30" width="1" height="1" fill="#241F89"/>'
                    ),
                    string.concat(
                        '<rect x="13" y="30" width="2" height="1" fill="#423BDC"/>',
                        '<rect x="15" y="30" width="1" height="1" fill="#241F89"/>',
                        '<rect x="16" y="30" width="4" height="1" fill="#423BDC"/>'
                        '<rect x="20" y="30" width="1" height="1" fill="#241F89"/>',
                        '<rect x="21" y="30" width="3" height="1" fill="#423BDC"/>',
                        '<rect x="24" y="30" width="1" height="1" fill="#241F89"/>',
                        '<rect x="7" y="30" width="1" height="1" fill="#423BDC"/>',
                        '<rect x="8" y="31" width="1" height="1" fill="#423BDC"/>',
                        '<rect x="9" y="31" width="3" height="1" fill="#241F89"/>',
                        '<rect x="12" y="31" width="3" height="1" fill="#423BDC"/>',
                        '<rect x="15" y="31" width="1" height="1" fill="#241F89"/>'
                    ),
                    string.concat(
                        '<rect x="16" y="31" width="4" height="1" fill="#423BDC"/>',
                        '<rect x="20" y="31" width="1" height="1" fill="#241F89"/>',
                        '<rect x="21" y="31" width="2" height="1" fill="#423BDC"/>'
                        '<rect x="23" y="31" width="1" height="1" fill="#241F89"/>',
                        '<rect x="8" y="32" width="7" height="1" fill="#423BDC"/>',
                        '<rect x="15" y="32" width="1" height="1" fill="#241F89"/>',
                        '<rect x="16" y="32" width="4" height="1" fill="#423BDC"/>',
                        '<rect x="20" y="32" width="1" height="1" fill="#241F89"/>',
                        '<rect x="7" y="32" width="1" height="1" fill="#423BDC"/>',
                        '<rect x="8" y="33" width="7" height="1" fill="#423BDC"/>',
                        '<rect x="16" y="33" width="5" height="1" fill="#423BDC"/>'
                    ),
                    string.concat(
                        '<rect x="21" y="33" width="1" height="1" fill="#241F89"/>',
                        '<rect x="10" y="34" width="3" height="1" fill="#423BDC"/>',
                        '<rect x="17" y="34" width="4" height="1" fill="#423BDC"/>',
                        '<rect x="21" y="34" width="1" height="1" fill="#241F89"/>',
                        '<rect x="17" y="35" width="4" height="1" fill="#423BDC"/>',
                        '<rect x="21" y="35" width="1" height="1" fill="#241F89"/>',
                        '<rect x="16" y="36" width="1" height="1" fill="#423BDC"/>',
                        '<rect x="18" y="36" width="1" height="1" fill="#423BDC"/>',
                        '<rect x="20" y="36" width="1" height="1" fill="#241F89"/>',
                        "</svg>",
                        "</svg>"
                    )
                )
            );
    }
}
