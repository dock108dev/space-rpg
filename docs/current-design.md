# Current design — active interpretation

Updated September 23, 2026. Confirmed command-adventure priorities and opening-chapter beta scope. Source: [owner answers](owner-answers.md). Confirmed means owner-selected intent, not proven implementation.

| Area | Current choice | State |
|---|---|---|
| Audience/platform | Personal single-player on owner’s Mac | Confirmed |
| Owner effort/budget | 5–10 hours/week; spending considered as needed | Confirmed |
| Agency | Multiple approaches emerge from decisions; no explicit path lock | Confirmed |
| Control | Player directs one protagonist through natural-language commands, precise movement and contextual choices; direct controls remain available; companions act autonomously | A1 confirmed September 23 |
| Character | Name/appearance creation; shared background | Confirmed; background open |
| Routine activity | Describe a goal, give exact steps, interact with a named object, select a choice or watch an assigned task; inspect actual results and intervene | A1 confirmed; B2.5 implemented; owner review pending |
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
| Locations | Several connected explorable locations; smaller detailed spaces linked by travel remain the implementation direction | Breadth confirmed September 21; six-place count is a B1 production default |
| Tone | Dark humor + satire, a little adventure | Confirmed |
| Freedom | Independent life and safer continued participation without actual death | Tentative detailed model |
| Organization role | Secure job financing own life/adventures, possibly playtesting | Selected appeal; duties open |
| Replay | Separate playable identities, possibly several saved | Direction selected; persistence/limits open |
| Safe-play appeal | Rewards, competition, non-death consequences; difficulty is not primary motivation | Confirmed emphasis |

## A1 / A1a priorities

**A1 is the modern text-adventure command experience. A1a is story and gameplay.** Deliver free-form requests, exact commands such as “move 5 up and 8 right,” contextual options, questions/follow-ups and readable narration as the central player interface. Commands operate the visible world. Story situations, character responses, discovery, different approaches and saved consequences must be delivered with the interface.

[B2.5](slices/B2.5-command-adventure.md) implements this interface before B3 expansion. The [bounded interpreter/model assessment](B2.5-language-assessment.md) selects offline deterministic parsing; no semantic model was run. Personal versus pet cache retrieval has distinct physical behavior and a saved narrative consequence. These are authored implementation defaults, not additional canon.

## Interpretation boundaries

Choosing an initial power does not establish a permanent class. Temporary shelter is not automatically property or private. The real player’s audience UI is not automatically information the protagonist possesses. Selecting C does not settle animation, camera controls, or tooling. The pet reference is the following-companion idea, not permission to import unrelated franchise systems. No species, creature design, cash amount, ability cost, or new lore has been approved merely because a test needs placeholders.

## Confirmed beta scope — September 21

The [Desktop beta path](/Users/michaelfuscoletti/Desktop/space_opera_rpg_next_steps.md) defines the complete opening chapter through a first substantial expedition beyond shelter. Required: several connected locations and optional tasks; acquiring/improving equipment and powers; a first owned private home; a recruitable autonomous companion alongside the pet. Audience reactions remain, but tangible audience rewards are excluded from beta.

Home furnishing and upgrades are required. Pet injuries require care and recovery; no permanent pet death. The recruited companion cannot die permanently during beta. These are scope decisions, not implementation or owner-play acceptance.

## Implementation packet — September 23

[B1](chapter-implementation-packet.md) maps confirmed scope to a counted chapter, state/save rules and ordered delivery. Its labels, counts and resource values are provisional production defaults, not additional owner answers. [B2](slices/B2-playable-foundation.md) is technically complete with owner review pending. Its candidate-bound runtime, validation and moving review are recorded in [B2 evidence](../evidence/B2/README.md). B2.5 follows it; no owner verdict is inferred.
