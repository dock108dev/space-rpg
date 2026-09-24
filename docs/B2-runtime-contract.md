# B2 runtime and state contract

B2 extends the existing tactical controller: the three powers, action-point rules, enemy behavior, human rig, effects and immutable snapshot storage remain shared. It does not duplicate the combat simulation per room. Historical S03/S04 scene/save contracts remain intact.

## Owners

- `chapter_opening.gd`: ordinary player journey, UI, interactions, scene changes and coherent state commits.
- `chapter_locations.gd`: B2 location identities, blocked geometry and doorway/spawn defaults.
- `chapter_save.gd`: independent chapter-v1 validation plus inherited immutable/atomic snapshot storage; interrupted-writer recovery is B2 only.
- `chapter_follower.gd`: shared collision-aware spatial following and pet fetch traversal. Recruit and pet use separate follow cells; neither blocks player movement or receives direct player control.
- `chapter_art.gd` and `recruit_visual.gd`: layered room presentation, furnishings and directional recruit motion.
- `run_b2.gd`, `restart_b2.gd`, `visible_b2.gd`: actual-scene acceptance checks, independent process resume and normal-speed synthetic moving tour.

Location IDs `concourse` and `shelter` implement B1's shopping concourse and temporary shelter. Labels, positions, resource amounts and geometry are reversible production defaults. The shelter conveys no ownership or privacy.

## Saved meaning

Chapter schema version 1 retains the existing combat fields and adds location, opening journey, package/learning, cache, exclusive reward, recovery-kit quantity, recruit membership and both follower positions. The validator checks each location's floor, encounter/journey consistency, reward exclusivity and resource bounds. The historical one-map validator is not loosened.

The opening moves from arrival to assessment, then package collection/learning, shelter and reward. A cleared encounter stays cleared after travel or resume. Recruit status is available, declined, joined or waiting; a nonjoined recruit remains in shelter and can join later. The pet follows throughout and retrieves the cache physically after learning. Only one cache payout and one orientation choice can be committed.

Save boundaries exclude committed player actions, enemy resolution, unfinished assigned walking, fetch and transitions. A paused stable state can be saved without advancing simulation. Failure leaves the session open with visible recovery/retry controls. Snapshots are immutable; New practice leaves earlier snapshots intact. Continue loads the latest valid B2 snapshot and reports skipped invalid/partial files.

The ordinary launcher defaults to `dev-state/B2-practice-v1`. `B2_SAVE_DIR` supplies a distinct test directory; automated runners copy the runtime and use disposable synthetic state. No B2 load scans or migrates S03/S04/S05 saves. An interrupted writer lock can be preserved under a new name and retried; a live PID lock cannot be reclaimed. A markerless newly-created lock has a ten-second settling period to avoid racing a live writer.

## Scope boundary

B2 supplies two places and safe autonomous party traversal. B2.5 now delivers the A1 modern text-adventure command experience together with A1a story/gameplay over these two places; see [the contract](slices/B2.5-command-adventure.md). Hub routes and optional task persistence then follow in B3. Equipment/power improvements are B4, owned home/furnishing/privacy B5, companion combat and recoverable pet/recruit harm/care B6, expedition/return B7, character creation and full balance B8, standalone Mac qualification B9, and owner beta acceptance B10. Outside-audience reactions have no simulation or reward authority.
