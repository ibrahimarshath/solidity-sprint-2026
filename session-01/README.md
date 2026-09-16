# Session 01 — Message Storage

Name: M R Mohammed Ibrahim Arshath 
Enrolment ID: AU24UG - 016
Date submitted: 16-09-2026
Testnet wallet address: 0xE0d559b2eaa094e392B2d4287F7Cc765C60BbD53

## 1. What this contract does

This contract acts as a simple on-chain notice board. Anyone can update a stored 
message, and the contract automatically records the address of whoever made the 
last change. It exposes two read functions so any caller can check the current 
message and see who last edited it.

## 2. Design decisions

I used a `string` state variable for the message since the content is 
human-readable text of variable length. The `lastEditor` is stored as an 
`address` type because `msg.sender` is always an address — no conversion needed. 
I marked both state variables `private` and exposed them only through dedicated 
getter functions rather than using `public` variables with auto-generated getters, 
so the interface is explicit and intentional.

I considered initialising the message in a constructor but decided against it — 
an empty initial state is fine since the contract's purpose is to be updated, 
not to hold a default value.

## 3. Deployment

- **Network:** Remix VM (Cancun)
- **Contract address:** 0x...
- **Transaction hash:** 0x...
- **Block explorer link:** N/A (local Remix VM)

## 4. How to test it

Run these steps in Remix after deploying:

1. `getMessage()` → returns `""` (empty string on fresh deploy)
2. `getLastEditor()` → returns `0x0000000000000000000000000000000000000000`
3. `updateMessage("Hello Atria")` from **Account 1** → transaction succeeds
4. `getMessage()` → returns `"Hello Atria"`
5. `getLastEditor()` → returns **Account 1's address**
6. Switch to **Account 2**, call `updateMessage("Updated by Account 2")` → succeeds
7. `getLastEditor()` → returns **Account 2's address** (confirming it updated)

**Failure case:**
- `updateMessage("")` → transaction goes through but stores an empty string;
  there is no revert here since the contract does not validate input — 
  this is a known limitation noted below.

## 5. What I found difficult

Understanding that `msg.sender` automatically captures the caller's address 
without needing any parameter was not immediately obvious. I also initially 
tried making both variables `public` and got confused by the auto-generated 
getter names — switching to `private` with explicit functions made it clearer.

## 6. Acknowledgements

- Remix IDE default template used as starting structure
- NatSpec comment format referenced from the Solidity official documentation
- AI assistance used for writing the contract logic