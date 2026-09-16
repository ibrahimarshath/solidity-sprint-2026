# Session 02 — Build a Student Record Contract

Name: M R Mohammed Ibrahim Arshath 
Enrolment ID: AU24UG - 016
Date submitted: 16-09-2026
Testnet wallet address: 0xE0d559b2eaa094e392B2d4287F7Cc765C60BbD53

## 1. What this contract does

This contract works like a student registry — anyone can register their wallet
address as a student by providing their name and enrolment ID. Once registered,
a student can update their own status (Active, Inactive, or Graduated). Anyone
can look up a student by their wallet address and get their full details back.
The contract also makes sure the same address cannot register twice.

## 2. Design decisions

I used a `struct` to group the three pieces of student data together — name,
enrolment ID and status — because they always belong to the same person and it
keeps things clean. I used an `enum` for status instead of a plain number
because it makes the code readable and limits the values to only what makes
sense.

For storage I used two mappings — one that connects an address to its student
record, and a second `isRegistered` boolean mapping to track who has signed up.
I kept both mappings `private` and exposed the data only through `getStudent`,
so the interface is intentional.

For the duplicate check I used a custom error (`AlreadyRegistered`) instead of
a `require` string because it is cheaper on gas and tells the caller exactly
which address tried to register twice.

For the update function I used a `storage` pointer instead of a `memory` copy
because I learned in session that a memory copy gets thrown away after the
function — the change would never actually save to the chain.

I considered making the mapping `public` so Solidity would auto-generate a
getter, but the auto-generated getter does not return the `registered` boolean
and does not handle unregistered addresses explicitly, so I wrote my own
`getStudent` function instead.

## 3. Deployment

- **Network:** Remix VM (Osaka)
- **Contract address:** 0x358...D5eE3
-

## 4. How to test it

1. `getStudent(<Account 1 address>)` → returns `("", 0, 0, false)` — unregistered address handled explicitly
2. `register("Asha", 101)` from Account 1 → succeeds
3. `getStudent(<Account 1 address>)` → returns `("Asha", 101, 0, true)` — status 0 means Active
4. `register("Asha", 101)` from Account 1 again → reverts with `AlreadyRegistered`
5. Switch to Account 2, `register("Rahul", 102)` → succeeds
6. `updateStatus(2)` from Account 2 → succeeds — 2 means Graduated
7. `getStudent(<Account 2 address>)` → returns `("Rahul", 102, 2, true)` — confirms storage pointer worked
8. Switch to Account 3 (never registered), `updateStatus(1)` → reverts with `"Not registered"`

## 5. What I found difficult

The `storage` vs `memory` distinction was confusing at first. I initially used
`memory` in the update function and could not understand why the status was not
changing — it compiled fine but the change was just being thrown away. Once I
switched to `storage` it clicked.

I also had to think about how to handle unregistered addresses in `getStudent`.
Mappings in Solidity return a default zero value for keys that do not exist, so
without the `isRegistered` check there would be no way to tell a real record
with empty fields from an address that never registered.

## 6. Acknowledgements

- Session 02 class contracts used as reference for struct, enum, mapping,
  storage vs memory, and error handling patterns
- No external libraries used
- Claude AI used to help write the README and check that all success criteria
  from the lab slide were covered