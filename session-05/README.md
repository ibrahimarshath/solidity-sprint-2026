# Session 05 — Build & Deploy Your Own Token

Name: M R Mohammed Ibrahim Arshath 
Enrolment ID: AU24UG - 016
Date submitted: 16-09-2026
Testnet wallet address: 0xE0d559b2eaa094e392B2d4287F7Cc765C60BbD53


## 1. What this contract does

This contract is an ERC20 token named IA28. It follows the ERC20 standard
by inheriting OpenZeppelin's ERC20 implementation, which gives it all the
standard functions like transfer, approve, transferFrom, balanceOf and
totalSupply out of the box. The deployer receives the entire initial supply
at deployment. Only the owner can mint new tokens, but any token holder can
burn their own tokens. The contract was deployed to the Sepolia testnet and
the token was transferred to a classmate's wallet.

## 2. Design decisions

I used OpenZeppelin's ERC20 instead of building a token from scratch because
the session taught that reusing established implementations reduces risk and
avoids reinventing something that has already been reviewed and tested by the
community. The full standard interface — transfer, approve, allowance,
transferFrom, Transfer and Approval events — all come for free from the
import.

For minting I stored the deployer's address in a private `owner` variable and
added a `require(msg.sender == owner)` check, exactly as shown in the session
code. I considered using OpenZeppelin's Ownable from session 03 but the session
05 material shows the manual owner check pattern, so I stuck with that.

For burning I used OpenZeppelin's internal `_burn` function which automatically
reduces the caller's balance and decreases totalSupply. Any holder can burn
their own tokens — this is intentional since the task says "allow token holders
to burn their tokens", not just the owner.

For the initial supply and mint amounts I multiply by `10 ** decimals()` so
the caller can pass in whole numbers like `1000000` instead of having to type
out 24 digits of wei.

## 3. Deployment

- **Network:** Sepolia Testnet
- **Contract address:** 0x...
- **Deployment transaction hash:** 0x...
- **Block explorer link:** https://sepolia.etherscan.io/address/0x...
- **Transfer transaction hash:** 0x...

## 4. How to test it

**In Remix VM:**

1. Deploy with `initialSupply` = `1000000` → succeeds
2. `totalSupply()` → returns `1000000000000000000000000`
3. `balanceOf(<Account 1>)` → returns same as totalSupply — all tokens with deployer
4. `name()` → returns `"IA28"`
5. `symbol()` → returns `"IA28"`
6. `decimals()` → returns `18`
7. Switch to Account 2, call `mint(<Account 2>, 1000)` → reverts with `"Only owner can mint"` — non-owner mint blocked
8. Switch back to Account 1, call `mint(<Account 2>, 5000)` → succeeds, Account 2 balance increases
9. `totalSupply()` → increased by 5000 tokens
10. Call `transfer(<Account 2>, 1000000000000000000000)` from Account 1 → succeeds, check logs for Transfer event
11. Switch to Account 2, call `burn(1000)` → succeeds, balance and totalSupply decrease
12. Call `approve(<Account 3>, 500000000000000000000)` from Account 2 → succeeds
13. Switch to Account 3, call `transferFrom(<Account 2>, <Account 3>, 500000000000000000000)` → succeeds

**On Sepolia:**

14. Deploy with MetaMask on Sepolia, confirm on Etherscan
15. Import token into MetaMask using contract address → IA28 appears in assets
16. Transfer `100` IA28 to classmate's wallet → transaction confirms on Etherscan

## 5. What I found difficult

Understanding the decimals was confusing at first. ERC20 tokens have 18 decimal
places by default so `1` token is actually `1000000000000000000` in the contract.
I kept getting confused passing raw amounts until I multiplied by `10 ** decimals()`
in the constructor and mint function so I could pass whole numbers instead.

Deploying to Sepolia was also new — switching MetaMask to the right network and
getting test ETH from the faucet took a few tries before the deployment went
through.

## 6. Acknowledgements

- Session 05 class contracts (MiniToken.sol and MyToken.sol) used as reference
  for token structure, ERC20 inheritance, minting and owner check patterns
- OpenZeppelin ERC20 used for the full standard token implementation
- Claude AI used to help write the README and verify all success criteria from
  the lab slide were covered