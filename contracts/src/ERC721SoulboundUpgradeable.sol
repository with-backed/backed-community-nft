// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {Initializable} from "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {ERC721Upgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/// @title An ERC721 extension for soulbound non-fungible tokens
/// @dev This extension limits the balance of each account to a maximum of 1,
/// and prevents transfers of the NFT (except for the contract owner)
contract ERC721SoulboundUpgradeable is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable
{
    // --------------- //
    // [ constructor ] //
    // --------------- //

    /// @dev Initializes the base ERC721 contract
    /// @param name_ The name of the ERC721 token
    /// @param symbol_ The symbol of the ERC721 token
    function __ERC721Soulbound_init(string memory name_, string memory symbol_)
        internal
        onlyInitializing
    {
        __ERC721_init(name_, symbol_);
        __Ownable_init();
    }

    // ------------- //
    // [ soulbound ] //
    // ------------- //

    /// @dev Soulbound tokens must be limited to 1 per address
    /// @param to_ The address that will own the new token
    /// @param tokenId_ The ID of the token to be created
    function _mint(address to_, uint256 tokenId_) internal override {
        require(balanceOf(to_) < 1, "ERC721Soulbound: cannot own more than 1");
        super._mint(to_, tokenId_);
    }

    /// @dev Soulbound tokens are only transferrable by the contract owner.
    /// @param from_ The address that owns the token being transferred
    /// @param to_ The address that the token is being transferred to
    /// @param tokenId_ The ID of the token being transferred
    function _transfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override {
        require(
            msg.sender == owner(),
            "ERC721Soulbound: only contract owner can transfer"
        );
        require(balanceOf(to_) < 1, "ERC721Soulbound: cannot own more than 1");
        super._transfer(from_, to_, tokenId_);
    }
}
