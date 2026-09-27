// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ERC721URIStorage gives us standard NFT ownership and the ability
// to store a separate metadata URI for each individual token
// Ownable gives us the onlyOwner modifier so only we can mint
contract RYNFT is ERC721URIStorage, Ownable {

    // keeps track of how many NFTs have been minted so far
    // also used as the ID for the next token — starts at 0, first mint gets ID 1
    uint256 public tokenId;

    // constructor runs once at deploy
    // ERC721("name", "symbol") sets the collection's identity
    // Ownable(msg.sender) makes the deployer the owner automatically
    constructor() ERC721("RY Collection", "RYC") Ownable(msg.sender) {}

    // only the owner can mint new NFTs
    // the caller passes in a URI pointing to the token's metadata on IPFS
    // each new token gets the next sequential ID
    function mint(string memory _uri) external onlyOwner returns (uint256) {

        // increment first so the first token gets ID 1 not 0
        tokenId++;

        // _safeMint checks that if the recipient is a contract
        // it can actually handle ERC721 tokens — safer than plain _mint
        _safeMint(msg.sender, tokenId);

        // connects this token ID to its metadata URI on IPFS
        _setTokenURI(tokenId, _uri);

        return tokenId;
    }

    // lets anyone check how many NFTs have been minted so far
    function totalMinted() external view returns (uint256) {
        return tokenId;
    }
}