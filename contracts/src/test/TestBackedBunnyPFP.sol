// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract TestBackedBunnyPFP is ERC721 {
    using Strings for uint256;

    uint256 private _nonce = 0;

    constructor() ERC721("TestERC721", "TEST") {}

    function mint() external returns (uint256 id) {
        id = mintTo(msg.sender);
    }

    function mintTo(address to) public returns (uint256 id) {
        _mint(to, id = _nonce++);
    }
}
