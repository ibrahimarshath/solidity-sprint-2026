# Session 04 — Build a Secure Ether Vault

Name: M R Mohammed Ibrahim Arshath 
Enrolment ID: AU24UG - 016
Date submitted: 16-09-2026
Testnet wallet address: 0xE0d559b2eaa094e392B2d4287F7Cc765C60BbD53

## 1. What this contract does

This contract is a personal ether vault — anyone can deposit ether into it and
only they can withdraw their own share. Every address has its own balance tracked
separately. The contract rejects zero-value deposits, emits an event for every
deposit and withdrawal, and applies the Checks-Effects-Interactions pattern to
make the withdrawal function secure against reentrancy attacks.

## 2. Design decisions

For the withdrawal function I followed the CEI pattern exactly as taught in the
session — check the balance first, zero it out second, then send the ether last.
The reason is that if we send ether before clearing the balance, a malicious
contract could call withdraw again inside its receive() function and drain the
vault. Clearing the balance first means any re-entrant call would see zero and
get rejected immediately.

On top of CEI I also inherited OpenZeppelin's ReentrancyGuard and added
nonReentrant to the withdraw function. This gives a second layer of protection
— even if the CEI order was somehow bypassed, the guard blocks any function
from being entered again while it is still executing.

For sending ether I used .call instead of transfer or send because the session
taught that .call is the preferred modern approach. I always check the return
value with require(success) so the contract stops if the transfer fails instead
of silently continuing.

I added a receive() function so the contract can also accept plain ether
transfers with no function call. When triggered it records the amount against
the sender's balance and emits a Deposited event, so it behaves the same as
calling deposit() directly.

The balances mapping is private — callers read their own balance through
getBalance() and the total contract balance through getContractBalance().

## 3. Deployment

- **Network:** Remix VM (Osaka)
- **Contract address:** 0x...
- **Transaction hash:** 0x...
- **Block explorer link:** N/A (local Remix VM)

## 4. How to test it

1. `getContractBalance()` → returns `0` — vault starts empty
2. `getBalance()` from Account 1 → returns `0`
3. `deposit()` with Value `0` ETH → reverts with `"Zero amount"` — zero deposits rejected
4. `deposit()` with Value `1` ETH from Account 1 → succeeds, check logs for `Deposited` event
5. `getBalance()` from Account 1 → returns `1000000000000000000`
6. `getContractBalance()` → returns `1000000000000000000`
7. Switch to Account 2, `deposit()` with Value `2` ETH → succeeds
8. `getContractBalance()` → returns `3000000000000000000` — both deposits tracked
9. Switch to Account 1, `withdraw()` → succeeds, check logs for `Withdrawn` event
10. `getBalance()` from Account 1 → returns `0` — balance cleared
11. `withdraw()` from Account 1 again → reverts with `"Nothing to withdraw"` — CEI pattern working
12. `getContractBalance()` → returns `2000000000000000000` — only Account 2's balance remains
13. Switch to Account 2, `withdraw()` → succeeds
14. `getContractBalance()` → returns `0` — vault fully drained correctly

## 5. What I found difficult

The CEI pattern took a moment to fully understand. My first instinct was to send
the ether and then clear the balance — which is exactly the vulnerable pattern
the session warned against. Once I saw the reentrancy attack demonstrated in the
live demo it clicked why the order matters so much.

I also was not sure at first whether to use transfer, send or call for sending
ether. The session comparison table made it clear that .call with a checked
result is the right modern approach.

## 6. Acknowledgements

- Session 04 class contracts (Vault.sol and Attacker.sol) used as reference for
  payable functions, receive(), CEI pattern and reentrancy guard
- OpenZeppelin ReentrancyGuard used for the nonReentrant modifier
- Claude AI used to help write the README and verify all success criteria from
  the lab slide were covered