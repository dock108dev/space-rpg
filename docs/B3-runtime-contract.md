# B3 contract — implementation defaults

A1 command play and A1a story/gameplay extend the accepted controller. No new owner canon.

Before implementation: B3 requires world_version 1, task statuses and supply_method. Chapter/adventure fields remain validated. B3 uses dev-state/B3-practice-v1 (B3_SAVE_DIR override); rejects earlier records, with no scanning or migration. Immutable storage and failed-write recovery remain shared. Commands are never restored. Party waiting remains at shelter.

| Task | Location / target | Motivation and actions | Eligibility / refusal | Immediate consequence / saved fields |
|---|---|---|---|---|
| Supplies | Hub / salvage pallet | Retrieve by walking personally, or send trained pet on physical trip; pet frees protagonist from travel but damages label | Package lesson; available, active during trip, completed, skipped; skipped can resume | One sealed supply bundle, once; supplies status, supply_method personal/pet; intact vs chewed label feedback |
| Access | Hub / access panel | Walk beside panel and restore manual release | Available or skipped; resume supported | Opens central shortcut; access completed changes walkable cells and art; main perimeter stays open |
| Survey | Approach / survey marker | Walk beside marker and record visible trail | Available or skipped; resume supported | survey completed reveals drainage-path description; no B7 advantage claimed |

All statuses default available. Skipping is reversible until completed. Active is transient during physical pet work, canceled to available by Stop, and cannot be saved. No blocked status is stored: eligibility errors describe the current barrier. Supply bundle is a task-owned ordinary item, not spendable currency or a healing kit; later use belongs to B4. Tasks commit with rollback on write failure. B5 home and B7 objective remain unavailable.

Travel uses adjacent doors and valid floor landings. Later clauses in supported then-separated requests are interpreted only when reached; room transitions clear pronouns, prior targets and button epochs. Exact step sequences use inherited step authority. Unknown continuations stop with feedback.

## Implemented ownership

`connected_world.gd` extends the accepted `command_adventure.gd`; its sole shared change is a virtual interpreter hook that returns the unchanged B2.5 proposal by default. B3 does not duplicate combat, movement, input, immutable storage or follower simulation. `world_locations.gd` provides the four-place graph and geometry; the controller's `floor_free` is shared by player pathing and both followers. `world_art.gd` extends the existing vector/raster art assembly with editable SVG scenery and retained cutout actors.

`world_save.gd` validates actual B3 locations, task values, reward-method agreement and all actor placements. It then validates inherited chapter/adventure invariants on a temporary coordinate projection for new rooms; this projection is never stored. World version 1 requires exactly three task statuses and a supply method. The one bundle is derived solely from completed supplies, preventing a second inventory counter. B3 records retain chapter_version 1 and adventure_version 1 but cannot load through older validators in their unrelated namespaces.

Pet work tracks outbound/returning only in memory. Stable saves, travel and Continue reject an active trip; Stop cancels without a payout. A blocked route or bounded timeout also cancels without a payout. Completion writes once; failure restores availability. Task actions and travel similarly roll back on failed writes. Waiting/declined actors retain shelter placement and remain invisible elsewhere; joining/rejoining is an actual shelter interaction.

Supported cross-room plans use `then` (also the inherited recognized action conjunctions). The bounded parser expands clauses at execution time. Every named action then binds to the current room; transitions invalidate prior references and choice epochs. A later unsupported/ambiguous clause stops after already committed actions, reports the error and refreshes choices. Negated plans are refused before any action. This is a bounded offline interpreter, not general natural-language understanding.
