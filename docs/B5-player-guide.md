# A place of your own — B5 player guide

Double-click **Launch B5.command**. Requires installed Godot 4.6.2 Standard. Supported native window: 1152 × 882. This installed-engine source candidate has separate `dev-state/B5-practice-v1` saves; Continue does not read earlier namespaces. No online interpreter or language model runs.

A1 is modern text-adventure command play; A1a is story and gameplay. Use typed intentions, contextual choices or direct movement. Commands below use actual implemented names.

## Earn your home

Complete the opening assessment, collect the package, enter shelter and choose an orientation reward. Invite, decline or leave the traveler waiting as you prefer. Then:

1. `go to hub then go to bench then claim preparation kit`
2. `How do I get a home?`
3. `go to board then file settlement claim`
4. `go home`

Filing the completed collection receipt at the hub board awards the dwelling and **10 material once**. This closes your collection duty; no optional task is required. The home is distinct from the shared shelter. You own its furnishings and control its interior. The interior and inside doorway are private; the hub pavement is public. Outside commentary disappears inside and returns outside. Characters never know it.

`go home` walks through the existing connections, via shelter/hub when necessary. It never teleports. `return to the hub` walks out. Return later to rest freely or use your locker. Free shelter recovery remains available too.

## Furnish and rearrange

`What can I furnish?` and `How much does that cost?` explain prices without spending. Three decorative furnishings cost **2 material each**:

- `buy reading chair then place reading chair by the window`
- `buy task lamp then place task lamp by the alcove`
- `buy keepsake shelf then place keepsake shelf by the far wall`

`move reading chair by the reading nook` rearranges it for free. `store task lamp` packs it away while retaining ownership; `place task lamp by the window` places it again if that socket is empty. No duplicate items, refunds or repeat charges.

The four supported positions are **window, alcove, reading nook, far wall**. Each holds one furnishing. Doors, locker, walking lanes and occupied footprints cannot be used. Move yourself and let the party follow if someone occupies a socket. “Move the chair over there” asks for a named position; the contextual buttons offer each one. Selecting Arrange reveals the same placement actions as typing. The visible prop moves when placement succeeds.

## Improve and use storage

`go to locker then improve the storage` costs **4 material once** and opens a 20-material locker. Then try:

- `deposit 3 material`
- `withdraw 1 material`
- `What changed?`

Stand beside the locker; transfers accept whole quantities from 1 to 20. Stored material remains yours, but purchases use carried material. Withdraw it before spending. Depositing never mints material. `rest` at home restores protagonist health to 6 for free.

The kit grants 20; all three B4 gear improvements plus chosen-power improvement cost 16. Even if you bought all of them, you have 4 + 10 settlement allowance = 14, enough for 6 in furniture and 4 for storage, leaving **4 total material**. One gear plus power leaves **12** after the full home purchases. The optional sealed bundle adds 4 only when explicitly exchanged once. Access and survey pay no material. Pet care belongs to B6, not this delivery.

## Control, saves and language limits

`Stop` cancels pending work, retaining completed actions. Escape pauses; Stop works while paused. Text input protects WASD/E from moving the character. Click the world or Tab out of text before direct controls. Questions do not buy or move things. Explicit valid actions execute; unsupported or ambiguous requests clarify. A failed action stops the rest of a `then` plan and reports what completed.

`save and quit`, relaunch, then Continue. Your room, party positions, furnishings, stored/carried balance, tasks and preparation return together; old commands remain inactive. Failed transactions roll back; failed Save and quit keeps the session open. Pause exposes retry/recovery. No owner-save migration is implemented.

Language is bounded English with named targets and sequential `then` clauses. Arbitrary furniture positions, freeform spatial pointing, rent, guest permissions and joint ownership are not implemented. The game remains silent, with rigid cutout motion, a hovering pet and mixed raster/vector art. Smaller windows, enlarged text and standalone packaging are not qualified. Engineering completion is separate from owner acceptance; the full beta is not ready.
