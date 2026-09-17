# Session 03 — Make Your Contract Observable & Controlled

Name: M R Mohammed Ibrahim Arshath 
Enrolment ID: AU24UG - 016
Date submitted: 16-09-2026
Testnet wallet address: 0xE0d559b2eaa094e392B2d4287F7Cc765C60BbD53

## 1. What this contract does

This contract extends the Student Registry from Session 02 with three new
capabilities. The owner is now the only one who can register students — anyone
else gets rejected. Every time something changes on chain, an event is emitted
so the outside world can see what happened. The contract also declares an
interface that exposes the read function, so any other contract can interact
with it without knowing the internal code.

## 2. Design decisions

For access control I used OpenZeppelin's Ownable instead of writing my own
owner variable and modifier from scratch. The session taught us to reuse
established implementations rather than rebuilding things that already exist
and have been reviewed. Inheriting Ownable gave me `onlyOwner`, `owner()`,
`transferOwnership` and `renounceOwnership` for free.

For the modifier I wrote a custom `onlyRegistered` modifier instead of putting
the `require` directly inside `updateStatus`. The session showed that modifiers
exist to avoid repeating the same check across multiple functions — writing it
once and applying it cleanly is better practice.

For events I added `indexed` on the wallet address in both events so logs can
be filtered by address later. I also included `oldStatus` in the `StatusUpdated`
event so the log tells the full story of what changed, not just what it became.

For the interface I only exposed `getStudent` because that is the only read
function an external contract would need. I used `uint8` as the return type for
status in the interface instead of the `Status` enum so the interface stays
simple and does not force callers to know about our enum definition.

I changed `register` to take a `wallet` parameter instead of using `msg.sender`
because the owner is now registering students on their behalf — the student is
no longer registering themselves.

## 3. Deployment

- **Network:** Remix VM (Osaka)
- **Contract address:** 0x...
- **Transaction hash:** 0x...
- **Block explorer link:** N/A (local Remix VM)

## 4. How to test it

1. Call `owner()` → returns Account 1's address (the deployer)
2. Call `getStudent(<Account 2 address>)` → returns `("", 0, 0, false)` — unregistered handled explicitly
3. Call `register("Asha", 101, <Account 2 address>)` from Account 1 → succeeds, check logs for `Registered` event
4. Call `getStudent(<Account 2 address>)` → returns `("Asha", 101, 0, true)`
5. Call `register("Asha", 101, <Account 2 address>)` again from Account 1 → reverts with `AlreadyRegistered`
6. Switch to Account 2, call `register("Rahul", 102, <Account 3 address>)` → reverts with `OwnableUnauthorizedAccount` — unauthorised registration reverts
7. Switch to Account 2, call `updateStatus(2)` → succeeds, check logs for `StatusUpdated` with oldStatus `0` and newStatus `2`
8. Call `getStudent(<Account 2 address>)` → returns `("Asha", 101, 2, true)` — confirms storage pointer worked
9. Switch to Account 3 (never registered), call `updateStatus(1)` → reverts with `"Not registered"`

## 5. What I found difficult

Understanding the difference between `onlyOwner` from OpenZeppelin and writing
my own modifier was confusing at first. I kept thinking I needed to write the
owner check myself until I realised inheriting Ownable gives it to you
automatically.

The `override` keyword on `getStudent` also tripped me up — I did not understand
why it was needed until I realised the interface is a promise and `override` is
how you tell the compiler you are keeping that promise.

## 6. Acknowledgements

- Session 03 class contracts used as reference for events, modifiers,
  constructor, inheritance, interface and OpenZeppelin Ownable patterns
- OpenZeppelin Ownable used for ownership and access control
- Claude AI used to help structure the contract, write the README and verify
  all success criteria from the lab slide were covered