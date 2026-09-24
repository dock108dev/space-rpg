# B3 — Connected world and optional tasks

Status: **PREPARED — NOT STARTED.** B2.5 candidate B25-20260923-01 is [owner accepted](../playtests/B2.5-owner-acceptance.md). This is the next complete lead-engineering work order. Preparation does not implement B3 or supply its acceptance.

Implement B3 in `/Users/michaelfuscoletti/Desktop/space-opera-rpg` through a complete, playable delivery. The Desktop tracker is `/Users/michaelfuscoletti/Desktop/space_opera_rpg_next_steps.md`.

1. Priorities and starting point

A1 is modern text-adventure command play. A1a is story and gameplay. Every new place and task must work through natural commands, contextual choices and grounded narration while actual characters move and act in the illustrated world. Direct controls remain available.

Read AGENTS.md, README.md, the tracker, current-design.md, world-rules.md, open-decisions.md, chapter-implementation-packet.md, next-task.md, this work order, and the B2.5 player guide, runtime contract, language assessment, delivery evidence and acceptance record.

Reinspect HEAD, uncommitted work and actual runtime before editing. Preserve incoming work and accepted B2.5 identity, archives, launchers and evidence. The owner accepted B2.5; no repeat acceptance question or broad scope interview is needed. S05 remains a separate historical review.

Mark B3 IN PROGRESS when implementation starts. Keep one slice active. Resolve routine content and engineering choices within the scope below, documenting production defaults without promoting them into owner-approved canon.

2. Complete player outcome

From the ordinary opening, reach shelter, enter a distinct district hub, discover optional work, travel to an expedition approach, carry out or decline optional activities, return with persistent consequences, save and quit, then Continue the exact state in a new process.

Retain the concourse and shelter. Add two distinct illustrated places: district hub and expedition approach. Connect concourse ↔ shelter ↔ hub ↔ approach through reachable entrances, valid landing positions and ordinary interactions. The approach is preparation/exploration space in B3; expedition combat, objective and final resolution remain B7.

Each new place needs readable geometry, useful objects, scene description, examinations and at least one meaningful interaction. The hub must communicate why the player would explore and what each opportunity offers. Keep shelter shared/unowned/nonprivate and the owned-home destination unavailable until B5.

Pet and any recruited companion must travel correctly. Joined, declined and waiting branches remain coherent. Returning to old places must preserve cleared danger, rewards, retrieval method and narrative consequences.

3. Three real optional activities

Extend the shared chapter state with persistent task outcomes and implement bounded versions of the planned recover-supplies, restore-access and survey-approach activities.

Before building them, record each task's location, motivation, target, available actions, eligibility, completion or refusal condition, immediate consequence, and saved fields. Use available/active/completed/skipped/blocked states where they have actual meaning. Explain whether a declined task can be resumed.

These must be playable interactions with observable results. Possible bounded outcomes include collecting a one-time ordinary supply, opening a local access route, and recording a discovered approach with new descriptive information. Choose effects supported by this slice; identify later upgrade or expedition effects as unavailable until their owning stage. Do not manufacture future completion or duplicate rewards.

Give at least one task two mechanically different supported approaches with an understandable tradeoff and saved narrative feedback. Use actual player/companion capabilities. Skipping optional work must leave the main travel route viable.

Write concise scene, object and character responses with the established dark humor and stakes. Choices and descriptions must change with task and world state. Keep the earlier personal-versus-pet retrieval consequence intact. Counts, names and balance remain production defaults.

4. Extend command play across the world

Extend the existing target registry, dispatcher, contextual choices and narration. New actions must use the same gameplay authority as direct controls.

Support destination travel, exact movement, examination, relevant conversations, task actions, progress questions, corrections and Stop for the new content. Commands such as “go to the hub,” “inspect the access panel,” and “what work is unfinished?” should resolve against actual knowledge and state. Exact movement must retain its requested sequence and rule costs.

Handle room transitions explicitly: invalidate stale target references and refresh available actions. For a supported multi-step request, resolve later-room targets only after arrival against the new context. If a requested continuation is unsupported or ambiguous, stop with a useful explanation and choices. Never silently retarget an old command to a different object.

Preserve text focus, question-only behavior, pause, direct reclaim, duplicate/stale request rejection and truthful partial results. Narration cannot invent success, hidden information, inventory or character access to audience feeds.

The accepted backend is the bounded offline interpreter. Extend it for useful B3 requests and measure representative paraphrases and follow-ups. A semantic model is optional; this slice does not require a model migration. Record remaining unsupported language honestly.

5. State, saves and boundaries

Extend the existing chapter/location/task/party authority and versioned validation. Avoid separate per-location simulations or conflicting UI/save state.

Specify the B3 schema and compatibility policy before changing persistence. Use a separate B3 development namespace and disposable synthetic test roots. Preserve existing owner, B2 and B2.5 saves; do not scan or migrate them as part of validation. Build synthetic compatibility fixtures if needed.

Persist location, actor placement, task decisions, one-time outcomes and narrative consequences coherently. Re-entry and reload must not reset tasks, repeat gains or lose waiting party members. Unfinished commands remain inactive after restore. Save failure must leave prior valid snapshots intact and prevent a false successful quit.

Equipment/power upgrades and spending remain B4; owned home/furnishing/privacy B5; companion combat and recoverable injury/care B6; expedition danger/objective/return B7; character setup/full polish B8; standalone Mac qualification B9; complete-beta acceptance B10. No permanent pet/recruit death or tangible audience rewards.

6. Verification

Add the actual B3 runner to the project-local validation entry point. Retain distinct language, game-execution, persistence and visual results.

Demonstrate a fresh command/choice-driven opening through hub and approach, optional task outcomes, return, real Save and quit, and separate-process exact Continue. Check all new doors both ways, party branches, both approaches to the selected task, declined/skipped/resumed work where supported, and one-time outcomes across repeated visits and reloads.

Cover blocked destinations, invalid transitions, exact movement, ambiguity, cross-room context, correction/Stop/pause/reclaim, typing focus, stale/duplicate requests, current-state narration, invalid/partial saves and write-failure recovery. Check both parser interpretation and execution; canned text cases alone cannot establish gameplay.

Run relevant B2.5 and inherited regressions, avoiding redundant repeats once the necessary checks pass. Preserve failed attempts and repair the bounded cause before rerunning affected checks.

Perform native Mac input review and a normal-speed moving demonstration with isolated synthetic saves. Show distinct places, readable command/story UI, actual travel, task consequences, party behavior and restart. Identify the supported window size and remaining layout limitations.

Bind final results to exact source, assets and launcher. Preserve original B2.5 evidence. New B3 checks and engineering review do not automatically establish owner acceptance.

7. Team and delivery

The lead owns state/schema integration and the ordinary playable route. If using teammates, assign bounded ownership for world/state, command/story/interface and independent verification; agree shared contracts before overlapping edits. Deliver one integrated product.

Provide a named B3 launcher and candidate, concise player guide, exact identity/archive, retained checks, normal-speed demonstration, known limitations and the next handoff. Update the tracker, README, slice board, design, state contract and validation docs consistently. Keep A1/A1a prominent.

Finish B3 before returning the handoff. Stop at its delivery; B4 progression/preparation is the following scope. No automatic B4 work, commit, push, publication, purchase or external message. Report engineering status and any actual owner verdict separately; do not mark the full beta ready.
