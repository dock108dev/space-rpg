# Play B2 — opening and shelter

Double-click **Launch B2.command** in the project folder. It uses the installed Godot 4.6.2 and separate B2 practice saves. This candidate is intentionally silent; a standalone Mac app is a later B9 deliverable.

1. Try all three power demonstrations, then choose one. Walk to the amber package with WASD/arrows or **Walk to package**; **E** enters the threatened collection area. There is no countdown.
2. In the assessment, movement costs AP. Select Bolt or your power, then click the creature or appropriate floor target. **Enter** ends your turn; **right-click** cancels targeting. Survive, then return beside the package and press **E** to collect it and teach fetch.
3. **Walk to doorway**, then **E**, enters the furnished temporary shelter. **Walk to reward desk** takes you to one exclusive reward: two kits, a visible field lamp, or a route to the existing cache. These are ordinary orientation rewards.
4. Approach the traveler beside the shelter lockers. Choose **Join me** or **Travel alone**. The pet and joined traveler follow autonomously; only your protagonist is directly controlled. At this shelter place, **Wait here** leaves a joined traveler available for **Rejoin me**. Declining also leaves recruitment available.
5. Return through the doorway to the cleared concourse. Select **Pet: fetch cache** and watch its outbound/return trip; it delivers one kit. Return through the same doorway to shelter.
6. Press **Escape**, then **Save and quit**. Relaunch and select **Continue latest** to restore that state.

Movement keys, right-click or **Stop walking** cancel an assigned safe walk. An already-committed step finishes; no dangerous action is automated. Focus loss pauses all actors and actions; Escape resumes explicitly.

Save at a stable moment: finish attacks, enemy resolution and fetch, and finish or stop assigned walking. A stable paused state can Save and quit without advancing play. A failed write keeps the game open. **Retry save** retries once access is restored; **Recover interrupted save access** preserves a stale writer lock and enables a retry. It refuses to take a live process's lock. **Continue latest** can skip invalid or interrupted snapshots and reports that recovery. **New practice** preserves previous files; Continue selects the newest valid snapshot, not a slot picker.

Default save folder: `dev-state/B2-practice-v1`. This is independent of S03/S04/S05. Automated evidence uses disposable synthetic folders, never these owner practice saves.

The shelter is temporary, unowned and nonprivate. Outside-audience text is only for the real player; characters have no feed access and gain no audience rewards. The endpoint is this two-place opening. Hub travel/tasks, upgrades, owned home/furnishings, pet care, companion combat and the expedition are later slices. Character creation is not implemented yet.

B2 is technically verified and engineer-reviewed with visual limitations. Owner acceptance and full beta readiness remain pending. See [delivery and evidence](../evidence/B2/README.md).

UI-02 controls: Save, Continue and Pause stay in the header. Tab selects a button; Space activates it. Movement keys return control to the scene. Pause contains Save and quit, save recovery, and **Controls and save details**; open that section for New practice. Reward and traveler choices appear beside their relevant interaction. Gameplay and the B2 save namespace are unchanged.
