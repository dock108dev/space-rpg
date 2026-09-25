# Equipment and preparation — B4 player guide

Double-click **Launch B4.command**. Godot 4.6.2 must be installed. Play at 1152 × 882. B4 uses separate practice saves; Continue does not open B3 or owner saves. The interpreter is offline and supports the commands below plus bounded paraphrases.

Complete the ordinary opening: try all three powers, choose one, clear the assessment, collect the package, enter shelter and choose an orientation reward. The traveler can join, decline or wait. A1 command play and A1a story/gameplay remain the main experience; clicking choices performs the same actions as typing.

## Prepare

From shelter, use these commands one at a time, or combine actions with `then`:

1. `go to hub then go to bench then inspect bench`
2. `claim preparation kit` — three base items and 20 material, once.
3. `compare these` — compare impact, protection and movement; this spends nothing.
4. `inspect Focus lens` and `what would upgrading this change?`
5. `equip the Focus lens` — free, replaces the item in your one equipment slot.
6. `go to approach then go to range then test power` — earn calibration by using your chosen power.
7. `go to hub then go to bench then improve Focus lens`
8. `improve my blast` (or `improve my shield` / `improve my dash`, matching your choice).
9. Return to the range and `test power` again to observe the improvement.

The gear and power improvements each cost 4: 20 → 16 → 12. No optional task is needed. Buying all three gear improvements and your power costs 16, leaving 4. Those are current tuning values, not an owner-approved balance target.

| Equipment | Base → improved effect | Choice |
|---|---|---|
| Focus lens | Adds 1 → 2 bolt/blast impact | More impact, no protection or distance bonus |
| Guard weave | Absorbs 1 → 2 pressure; adds to shield | More protection, no impact or distance bonus |
| Stride rig | Adds 1 → 2 dash cells | More distance, no impact or protection bonus |

All three base items are in the kit; each improved tier costs 4. `unequip that` removes the equipped item without losing it. `equip Guard weave` or `equip Stride rig` swaps your loadout. Repeated commands never add another copy of the bonus.

Chosen-power improvements: blast impact 3 → 5, shield protection 2 → 4, dash distance 2 → 3. Equipment adds its corresponding bonus. This does not choose a permanent class.

The approach range is the playable B4 preparation challenge: a 5-integrity target, a harmless 4-pressure pulse and a four-cell marker on a physical dash lane. `test bolt`, `test guard` and `test power` show current effects. `go to range` places you on the stripe before another test. Practice earns no material, causes no injuries and does not reset the completed opening. Later expedition combat is B7.

## Resources and optional work

`what equipment do I have?`, `how much material do I have?`, `what can I afford?`, and `where can I get more?` inspect current state without spending. `improve equipment` asks you to name an item; the clarification choices inspect it first, so you can read its effect before buying.

B3's three tasks remain:

- Hub supplies: `go to supplies then collect supplies`, or `ask pet to fetch supplies`. Both grant one bundle. Personal carrying keeps its label; the pet chews it.
- At the bench: `exchange the supply bundle` explicitly consumes that bundle for 4 material, once. Retrieval history remains, including the label consequence.
- `go to access then restore access panel` opens the shortcut. No material reward.
- `go to approach then go to marker then survey the approach` records trail information. No material reward.

`skip supplies`, `skip access`, `skip survey`, and their `resume` equivalents remain available. Optional work never gates the main preparation allowance.

At shelter, `go to desk then rest` restores protagonist health for free. It grants no kits and does not make the shelter owned or private. Pet injury/care and home furnishings remain later work. Spending all current materials must not be interpreted as funding those future mechanics.

## Control and restart

Stop cancels unfinished work; completed purchases remain. Escape pauses; Stop also works while paused. Leave the text field with Tab or click the world before using WASD/arrows and E. Questions do not move or spend. Click Preparation at the hub for bench choices, Compare gear for item choices, and To approach to leave the bench menu.

`save and quit`, then relaunch and choose Continue. Inventory, equipped item, tiers, chosen-power improvement, materials, party, task history and saved position return together. Old commands do not run again. A failed save leaves the session open and rolls back a failed purchase; Pause provides Retry and recovery controls.

Supported grammar is bounded English and sequential `then` clauses. Arbitrary goals, conditional plans and unnamed consequential purchases require clearer commands. Name the item after changing rooms. The game is silent, animations remain rigid, and smaller windows/enlarged text are unqualified. B4 is a playable installed-engine source candidate, not the full beta or a standalone Mac release.
