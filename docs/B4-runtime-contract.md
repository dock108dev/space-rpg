# B4 state, economy and gameplay contract

Production defaults established before coding; not approved balance or new canon. A1 is command play; A1a is story and gameplay.

## Implemented economy target

| Source / cost | Quantity | Timing / eligibility | Exactly-once rule |
|---|---:|---|---|
| Hub preparation bench: claim preparation kit | +20 material and three base items | Collected opening package; physically beside bench, explicit claim | kit_claimed flag; no automatic reward |
| Exchange sealed supply bundle at bench | +4 material, consumes one bundle | B3 supplies completed; personal or pet route | bundle_exchanged flag; retain supply_method and task completion forever |
| Restore access / survey | 0 | Existing optional tasks | Shortcut and information only |
| Improve any owned equipment | -4 | Beside bench, base tier, enough material | Tier 0 → 1 once per family |
| Improve chosen power | -4 | Beside bench, kit claimed, chosen power tested on range | power_level 0 → 1 once |
| Equip, unequip, inspect, compare, range practice | 0 | Owned gear / safe state; range actions at approach | No items or farmable material |
| Shelter rest | 0 | Safe, beside orientation desk | Health restored to 6; no consumables granted |

Required-route path: 20 - 4 gear - 4 chosen power = 12 remaining, with zero optional tasks. All three gear upgrades plus power cost 16, leaving 4. Optional bundle raises available lifetime material to 24; access and survey never mint money. B1's 20+12 proposal becomes 20+4 because only supplies offer an exchangeable physical item. No invisible grants or future rewards enter current balance.

Later B5–B7 planning only: home improvement 4 + three furnishings at 2 + care 1 = 11. The representative one-gear/one-power route retains 12; buying every B4 upgrade leaves only 4 and is a deliberate spending choice, not a promise of later affordability. B5 must reconcile its own actual funding. Free shelter recovery exists now; pet care remains B6.

## Equipment and observable roles

All three base items come from the bench's salvaged preparation kit. One equipment slot; equipping replaces the previous item without destroying it. Inventory remains owned when unequipped. No compounding or stacking across families. Effects derive afresh from tier and equipped ID.

| Family / actual item | Base effect | Improved tier, cost 4 | Tradeoff |
|---|---|---|---|
| Focus lens | +1 bolt/blast impact | +2 impact | No guard or mobility bonus |
| Guard weave | +1 protection against range pulse | +2 protection | No impact or mobility bonus |
| Stride rig | +1 dash cell | +2 dash cells | No impact or protection bonus |

Power improvements cost 4 after one actual chosen-power range test: blast impact 3 → 5; shield protection 2 → 4; dash distance 2 → 3. The selected initial power remains a choice, not a class. A lens adds to blast (maximum 7); weave adds to shield (maximum 6); rig adds to dash (maximum 5). Bolt baseline is 2, with maximum 4 through lens. The range's replaceable target withstands 5 impact, its harmless pulse measures 4 pressure, and a marked straight lane supports a physical dash. Repeatable practice consumes no material, grants no resources and never resets the opening encounter. It supplies a persistent earned calibration flag once. Range results are transient measurements; no danger or B7 completion is claimed.

The illustrated range is the B4 observable-use setting. Gear/power effects apply there; the completed opening cannot be replayed for rewards. B7 must integrate the same derived values into its later encounters. Rest addresses actual remaining opening health without charging materials.

## State and transactions

A single progression dictionary on the shared controller owns material, kit_claimed, bundle_exchanged, equipment levels (-1 unowned, 0 base, 1 improved), equipped ID, power_level and calibrated. Save requires progression_version 1 alongside world/adventure/chapter version 1. Material must equal 20*kit_claimed + 4*bundle_exchanged - 4*(sum of improved gear tiers + power_level); no second inventory bundle counter. Task status and redemption jointly derive held bundles. Validation rejects contradictory ownership, tiers, redemption and balance.

Separate namespace `dev-state/B4-practice-v1`, override `B4_SAVE_DIR`. Earlier saves are rejected; no scanning or migration. Synthetic fixtures only. Immutable storage remains inherited. Spending and benefit persist in one snapshot; failures restore the full prior progression and preserve error feedback. Practice calibration/placement commits before success animation; no pending practice replays on load. History never executes. Travel, Continue and ordinary defeat use the same state authority; stale contexts and request IDs remain guarded by the accepted command controller.

Commands and contextual buttons use the same dispatcher. Questions/comparisons never spend. Ambiguous improvement/equipment requests clarify; explicit valid requests execute. The bench examination and choices disclose costs and effects. Stop clears future work; committed transactions remain. Pause/text focus/direct reclaim preserve inherited behavior.
