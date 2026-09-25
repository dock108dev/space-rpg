# UI-05 — Whole-interface enlargement and updated Mac app

Status: TECHNICALLY COMPLETE. Authorized by “implement other suggestions in full.”

Implement 125% text throughout setup, HUD, controls, choices, Help, Pause and actor labels; preserve 100% mode and preference compatibility. Reflow fixed layouts at 1152×882 and 1280×980, retain keyboard operation and visible recovery. Package all current M1/M2/UI-04/UI-05 source in a separately identified Mac app with a separate save namespace. Preserve frozen B9 app/evidence and owner saves. Validate the exact exported candidate on synthetic saves, record source/artifact identity and native views. No publication or owner acceptance inferred.

Validation entry: `python3 scripts/capture_ui05.py 1152x882` and `python3 scripts/package_ui05.py`, followed by the documented exact-build packaged validation.

Delivered coordinated baseline/125% text, setup switch, persistent preference, Help/setup reflow, audience/response spacing, and foreground Pause recovery. Side-by-side Updated Beta 0.9.1 (10) includes all M1/M2/UI-04/UI-05 code. [Exact evidence](../../evidence/UI-05/README.md) and [player guide](../UI-05-player-guide.md).

Final export: `build-20260924T235524Z`, candidate `UI-05-20260924-01`. 306 native interface checks across both sizes; 394 gameplay and 24 ergonomics assertions; 432 independent arithmetic snapshots; packaged M1/M2 failures and platform/resource inventory; actual Save and quit and separate-process Continue; normal boot and normal-speed chapter/restart demonstration all pass. Installed bundle matches every exported file and passes strict signature verification. Gatekeeper remains rejected; no notarization/public distribution claim. Frozen B9 full bundle, archive, 461 staged runtime entries and pointer remain unchanged. No owner-save access or migration.

No engineering slice is active. Owner acceptance remains pending and B10 remains unstarted. Earlier UI-04 global-enlargement/package suggestions are now implemented by this slice, not remaining work.
