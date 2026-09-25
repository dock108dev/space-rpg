# B5 ownership, economy and state contract

Production choices established before implementation; not owner-approved canon or balance. A1 commands and A1a story/gameplay govern the same illustrated world.

## Authored award and funding

After collecting the opening package, choosing orientation and claiming the preparation kit, visit the hub work board and `file settlement claim`. The package is proof of completed orientation collection duty; filing its receipt closes that main-route assignment. The allocation terminal awards sole use/control of a vacant arcade dwelling and **10 material once** as a settling allowance. No optional task, range calibration or gear spending is required. Before filing, the home is locked. Ownership grants entry, rearrangement and private interior; shelter remains shared, unowned and nonprivate. Guest and joint ownership rules remain deferred; the existing party follows its ordinary branch without acquiring property.

| Source or purchase | Quantity | Eligibility and timing |
|---|---:|---|
| B4 kit | +20 | Existing explicit one-time bench claim, three base items |
| B3 bundle exchange | +4 | Existing explicit one-time redemption; history retained |
| Access / survey | 0 | Existing benefits unchanged |
| B4 gear / chosen power improvements | -4 each | Existing requirements; maximum total 16 |
| Settlement claim | +10 | Package + orientation + kit, beside hub board, ownership false |
| Reading chair | -2 | Buy at home; quiet sitting place, decorative |
| Task lamp | -2 | Buy at home; decorative warm light, no stat bonus |
| Keepsake shelf | -2 | Buy at home; decorative place for a life beyond assignments |
| Storage improvement | -4 | Owned home, beside locker; enables material deposit/withdraw |

Maximum B4 spending: 20 - 16 + 10 - 6 - 4 = 4. Representative: 20 - 8 + 10 - 10 = 12. No prior spending: 20 + 10 - 10 = 20. Optional bundle adds 4 only when exchanged. Later care is not implemented or charged; even maximum B4 spending retains 4 after all B5 purchases. No farming, refill or future funds. Free shelter protagonist recovery remains.

## Placement, travel and storage

Each furnishing has a one-cell footprint. Four named sockets: window (3,1), alcove (7,1), reading nook (3,4), far wall (8,4). All other squares are invalid placement positions; doorway at (0,5), locker at (10,1), and walking lanes stay reserved. Occupied sockets and actor-occupied footprints reject placement without charge or loss. Buy once; place/move freely; `store [name]` unplaces it into owned furniture inventory without refund or duplication. Explicit names and named sockets; “over there” clarifies. Contextual buttons select an item and offer named sockets. Walk to the locker to improve/deposit/withdraw. Storage holds up to 20 material, with positive integer transfers. Only carried material can be spent. Stored material stays owned and withdrawable after travel/restart.

Home connects to hub east-lower threshold (11,5); home exit (0,5). Go home from other connected places walks via hub through ordinary queued clauses; no teleportation. Return point: private locker access and free home rest; shelter rest remains free. Collision-aware party follows existing behavior. Saved party placements must be valid outside furniture footprints.

## Schema and transactions

B5 requires `home_version: 1` plus the existing chapter/adventure/world/progression versions. One controller owns `home = {owned: bool, furniture: {chair: -1|0..4, lamp: -1|0..4, shelf: -1|0..4}, storage: bool, stored: int}`. -1 unowned, 0 owned/unplaced, 1..4 named socket index. Material stays in progression; no second wallet. Lifetime equation: carried + stored = 20*kit + 4*bundle + 10*owned - 4*(gear improvements + power level) - 2*(owned furnishings) - 4*storage. Home ownership requires kit and orientation; room access requires ownership. No storage contents without improvement. Atomic snapshot includes all fields; failed action restores wallet/home state before any success presentation. Earlier schemas rejected without migration. Default `dev-state/B5-practice-v1`, override `B5_SAVE_DIR`; tests only use disposable synthetic states. Pending commands never restore; history is inert.

## Privacy boundary

Entire home interior including its interior doorway/landing is private. Hub-side pavement remains public. Hide and clear the outside audience label synchronously on entry/load, before render; restore after successful exit. No new outside commentary events are emitted inside. Existing command history contains player actions and world narration, not an audience feed; retain it inert. Audience presentation is never interpreter input, character dialogue or a source of stats/material. No audience rewards.
