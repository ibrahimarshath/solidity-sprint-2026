# Session 06 — Create Your Own NFT Collection

Name: M R Mohammed Ibrahim Arshath 
Enrolment ID: AU24UG - 016
Date submitted: 16-09-2026
Testnet wallet address: 0xE0d559b2eaa094e392B2d4287F7Cc765C60BbD53

## 1. What this contract does

This contract creates an ERC721 NFT collection called RY Collection with the
symbol RYC. The contract owner can mint NFTs to their own wallet by supplying
a metadata URI that points to a JSON file stored on IPFS. Each NFT gets a
unique sequential token ID starting from 1. Anyone can check who owns a token
using ownerOf and retrieve its metadata URI using tokenURI. The collection was
deployed to Sepolia and three NFTs were minted with distinct metadata.

## 2. Design decisions

I inherited from OpenZeppelin's ERC721URIStorage instead of plain ERC721 because
the session taught that URIStorage is the extension that lets each token store
its own metadata URI separately. Without it there is no per-token URI storage
built in.

I used _safeMint instead of _mint because the session specifically showed the
difference between the two — _safeMint checks that if the recipient is a
contract address it can actually handle ERC721 tokens correctly. Since we are
minting to msg.sender which is always an EOA in this case it would not matter
in practice, but _safeMint is the right habit.

I increment tokenId before calling _safeMint so the first token gets ID 1
instead of 0. This matches the pattern shown in the session code on slide 10.

I inherited Ownable and added onlyOwner to the mint function so only the
deployer can create new NFTs. The task says mint all three NFTs to your own
wallet — restricting minting to the owner enforces this.

The metadata for each token follows the JSON structure shown in the session —
name, description, image pointing to an IPFS CID, and attributes. Each of the
three tokens has completely distinct metadata uploaded separately to IPFS.

## 3. Deployment

Network: Metamask

## 4. How to test it

1. Deploy `RYNFT` → deploying account becomes the owner
2. `name()` → returns `"RY Collection"`
3. `symbol()` → returns `"RYC"`
4. `totalMinted()` → returns `0`
5. Call `mint("ipfs://<metadata-cid-1>")` from owner → succeeds, returns token ID `1`
6. `ownerOf(1)` → returns the owner's address — ownership verifiable
7. `tokenURI(1)` → returns `"ipfs://<metadata-cid-1>"` — URI resolves correctly
8. Call `mint("ipfs://<metadata-cid-2>")` from owner → returns token ID `2`
9. Call `mint("ipfs://<metadata-cid-3>")` from owner → returns token ID `3`
10. `totalMinted()` → returns `3`
11. `tokenURI(1)`, `tokenURI(2)`, `tokenURI(3)` → each returns a distinct URI
12. Call `mint(...)` from a non-owner account → reverts with `OwnableUnauthorizedAccount`
13. Open each metadata URI in a browser → JSON resolves with name, description, image and attributes
14. `ownerOf(1)`, `ownerOf(2)`, `ownerOf(3)` → all return the same owner address

## 5. What I found difficult

Understanding that the NFT itself is not the image was the key thing that took
time to click. The contract only stores a token ID, an owner address and a URI
— the actual image lives on IPFS and the metadata JSON is what connects the
two. Once I understood the flow of image → image CID → metadata JSON →
metadata CID → tokenURI it made sense.

Getting the IPFS upload right also took a few attempts — I had to make sure the
image CID in the metadata JSON exactly matched the CID that Pinata gave me
after uploading the image, otherwise the metadata would point to nothing.

## 6. Acknowledgements

- Session 06 class material used as reference for ERC721URIStorage, _safeMint,
  tokenURI, IPFS metadata structure and the token ID counter pattern
- OpenZeppelin ERC721URIStorage and Ownable used for NFT standard and access
  control
- Pinata used for IPFS uploads of images and metadata JSON files
- Claude AI used to help write the README and verify all success criteria from
  the lab slide were covered