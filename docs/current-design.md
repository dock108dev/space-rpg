# Current design — active interpretation

Design direction for the command adventure and planned opening chapter. These are design choices; the [README](../README.md) describes the runnable prototype and unfinished features.

| Area | Current choice | State |
|---|---|---|
| Audience/platform | Single-player on macOS | Selected platform |
| Agency | Multiple approaches emerge from decisions; no explicit path lock | Confirmed |
| Control | Player directs one protagonist through natural-language commands, precise movement and contextual choices; direct controls remain available; companions act autonomously | Selected interface |
| Character | Name/appearance creation; shared background | Confirmed; background open |
| Routine activity | Describe a goal, give exact steps, interact with a named object, select a choice or watch an assigned task; inspect actual results and intervene | A1 confirmed; B2.5 owner accepted; B3 implemented with owner review pending |
| Danger | Turn-based; action points spent on movement/powers/interactions | Turns confirmed; AP provisional |
| Attention | Watch/intervene or check in while engaged; pause when away | Pause provisional; no offline progression planned |
| Opening | Shopping area during takeover; navigate toward safety | Confirmed |
| Orientation | Welcome-package pickup plus temporary shelter; alien-creature assessment | Confirmed; geography/order open |
| Timing | Narrative pressure only in first encounter | Confirmed |
| Powers | Demonstrate small selection; choose force blast, shield, or dash | Confirmed; costs/ranges open |
| Enemy intent | Read visible behavior; no explicit intent labels | Confirmed |
| Rewards | Select security, equipment, or opportunity | Confirmed; exact payload open |
| Broadcast | Outside audience only; early reactions, later consequences | Confirmed |
| Progress | Access and security matter most | Confirmed |
| Failure | Missed rewards and recoverable damage; no permanent recruit death in beta | Beta boundary confirmed; later campaign loss rules separate |
| Ordinary death | Load latest manual/autosave | Confirmed; save timing open |
| Difficulty | Reload mode versus campaign-ending permanent-death mode | Confirmed direction; latter deferred |
| Pet | Alien animal met early; follows; learns useful behaviors; role grows through choices/training | Confirmed; species/first behavior open |
| Pet loss | Recoverable injury requiring care; no permanent death | Confirmed for beta September 21; retained prototype still excludes damage |
| Visuals | Illustrated 2D concept C; angled viewpoint as reference | Selected concept, not in-engine acceptance |
| Locations | Several connected explorable locations; smaller detailed spaces linked by travel remain the implementation direction | Breadth confirmed September 21; six-place count is a planning default |
| Tone | Dark humor + satire, a little adventure | Confirmed |
| Freedom | Independent life and safer continued participation without actual death | Tentative detailed model |
| Organization role | Secure job financing own life/adventures, possibly playtesting | Selected appeal; duties open |
| Replay | Separate playable identities, possibly several saved | Direction selected; persistence/limits open |
| Safe-play appeal | Rewards, competition, non-death consequences; difficulty is not primary motivation | Confirmed emphasis |

## Command play and story

Commands, story and gameplay are the primary experience. Deliver free-form requests, exact commands such as “move 5 up and 8 right,” contextual options, questions/follow-ups and readable narration as the central player interface. Commands operate the visible world. Story situations, character responses, discovery, different approaches and saved consequences must be delivered with the interface.

The [command-adventure opening](B2.5-runtime-contract.md) implements this interface. The [bounded interpreter/model assessment](B2.5-language-assessment.md) selects offline deterministic parsing; no semantic model was run. Personal versus pet cache retrieval has distinct physical behavior and a saved narrative consequence. These are authored implementation defaults, not additional canon.

## Interpretation boundaries

Choosing an initial power does not establish a permanent class. Temporary shelter is not automatically property or private. The real player’s audience UI is not automatically information the protagonist possesses. Selecting C does not settle animation, camera controls, or tooling. The pet reference is the following-companion idea, not permission to import unrelated franchise systems. No species, creature design, cash amount, ability cost, or new lore has been approved merely because a test needs placeholders.

## Confirmed beta scope — September 21

The planned opening chapter extends through a first substantial expedition beyond shelter. Required: several connected locations and optional tasks; acquiring/improving equipment and powers; a first owned private home; a recruitable autonomous companion alongside the pet. Audience reactions remain, but tangible audience rewards are excluded from beta.

Home furnishing and upgrades are required. Pet injuries require care and recovery; no permanent pet death. The recruited companion cannot die permanently during beta. These are scope decisions, not implementation or owner-play acceptance.

## Implementation status

The command-adventure opening is implemented. Connected-world and optional-task work is technically complete with B3 owner review pending. B4 equipment, chosen-power improvements, explicit material accounting and repeatable range practice are technically complete with owner acceptance pending. B5 delivers the owned private home, furnishing/rearrangement and actual material storage with owner acceptance pending. B6 companion behavior, training and care are technically complete with owner acceptance pending. B7 delivers the complete relay expedition and persistent return report; owner acceptance remains pending. The [chapter implementation packet](chapter-implementation-packet.md) holds planning details; its names, counts and resource values are provisional.

B4 production defaults are in the [economy/state contract](B4-runtime-contract.md): one slot, three equipment families, one improvement per item and selected power, explicit 20-material kit and 4-material bundle conversion. Access and survey produce no currency. Effects are observable at the approach range; full expedition integration is delivered by B7. Numeric tuning is engineering judgment, not accepted balance.

## B5 implemented production choices — September 24

A1 commands and A1a story/gameplay now include a distinct arcade dwelling. Filing the completed collection receipt at the hub board after package/orientation/kit awards ownership and 10 settling material once. Three decorative furnishings cost 2 each; a functional 20-material locker costs 4. Four named one-cell sockets keep travel and party lanes open. Free home rest and ordinary hub travel make a usable return point. The entire home and interior threshold suppress outside presentation; hub pavement and shelter remain public. Characters receive no audience information. [Contract](B5-runtime-contract.md) owns schema, sources/costs and boundaries. These are implementation defaults, not newly approved canon or balance. B6 now supplies explicit paid and assisted care; no permanent pet/recruit death is permitted.

## B6 implementation choices — September 24

A1 command play and A1a story/gameplay extend into a bounded containment breach at the existing approach, separate from the harmless north range and the full B7 expedition. One autonomous traveler shot per player-ended turn, earned cover fetch, actual recoverable pet injury/recruit downing, party-preserving retreat and explicit care are implemented production defaults. No permanent party death. Paid care uses two carried material per patient; free assistance requires two attended six-second rounds. Rest does not heal companions, and storage must be explicitly withdrawn. Conditions, training and accounting share the new B6 snapshot. See [B6 runtime contract](B6-runtime-contract.md); these are engineering choices, not accepted balance or new owner canon.

## B7 implementation choices — September 24

Six connected places now support a complete chapter. Beyond the approach barrier, the relay yard contains a 12-health warden and a distinct induction-crossing decision. Shared equipment/power effects, real B6 support/training/conditions, recorded survey drainage access and a no-survey maintenance detour operate in the same command/direct-control world. Recover the physical routing core and explicitly file its hub report for eight carried material once. No audience reward, duplicated task currency or unseen refill. Whole-party retreat preserves partial danger/objective progress and conditions; explicit paid/free care remains available. The chapter result freezes actual route/task/retrieval/party consequences. Existing world activity remains usable afterward.

[The B7 contract](B7-runtime-contract.md) defines production content, exact economy and expedition_version 1 in its separate namespace. Names, counts and tuning are engineering defaults, not new owner canon or accepted balance. Technical completion and engineering visual evidence do not confer owner acceptance. B8 subsequently delivers the character and player experience below. B9 standalone Mac packaging is technically complete; B10 owner beta review remains unstarted.

## B8 implementation choices — September 24

Name and three visible jacket palettes now precede fresh play, using the actual illustrated protagonist. Default Alex and the shared shopping/takeover opening are bounded production choices, not a detailed biography or newly approved canon. Identity and facing persist in separate B8 character sessions. Continue/Earlier characters preserve actual state; earlier namespaces are not migrated. Current objective/outcomes, contextual help, scrollable choices/history and larger main text support the command loop.

Explicit safe walking on a cleared yard removes AP costs only on unenergized ordinary floor; it never resolves a turn or silently enters danger. Combat/care/reward tuning is unchanged, including improved weave and the exactly-once eight-material report. Gait, grounding, seated downing and rescue feedback improve the retained illustrated presentation; remaining cutout/occlusion and accessibility limits are recorded. [B8 contract](B8-runtime-contract.md), [review](B8-review-and-balance.md) and [exact evidence](../evidence/B8/README.md) govern implementation. B8 is technically complete; owner acceptance remains pending. B9 packaging is technically complete; B10 owner review is unstarted and full-beta owner acceptance is not established.
