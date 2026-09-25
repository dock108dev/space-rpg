# B9 packaging and qualification contract

B9-20260924-01 is TECHNICALLY COMPLETE for local personal use. B10 is NOT STARTED. A1 command-adventure play and A1a story/gameplay remain primary. B2.5 owner acceptance and B3–B8 pending owner verdicts remain separate.

## Exact platform and startup

| Item | Delivered choice |
|---|---|
| App | Space Opera RPG Personal Beta.app |
| Bundle / version | org.personal.spaceoperarpg.beta / 0.9.0, build 9 |
| Target | arm64; only owner Mac15,6 / Apple M3 Pro / macOS 27.0 (26A428) qualified; declared minimum 27.0 |
| Engine and template | 4.6.2.stable.official.71f334935; installed official release template executable separately verified to match |
| Renderer / audio | Compatibility OpenGL; ETC2/ASTC import enabled for export; silent Dummy audio |
| Startup | res://scenes/b9_start.tscn immediately dispatches ordinary launch to res://scenes/player_experience.tscn |
| Window | 1280×980 logical canvas; 1152×882 minimum content, native zoom checked |
| Data | ~/Library/Application Support/Space Opera RPG Personal Beta/chapter-v1 |
| Signing | Ad-hoc, strict signature verification passes; no Developer ID signature/notarization. Gatekeeper rejects. Local Finder launch passes separately |

## Packaging

`scripts/package_b9.py` verifies the installed engine version, preserves source status/manifest, copies runtime to a new retained attempt, applies packaging/project-b9.godot and export_presets.cfg, imports and exports. The installed matching template contains universal binaries; the export is thinned to arm64 with the installed CommandLineTools lipo, notices are included, then the final bundle is ad-hoc signed before hashes/archive. The engine and installed templates are never modified. The source project and Launch B8.command keep their historical editor-launch configuration.

All Godot resources are exported. Runtime PNG/SVG imports, scenes, scripts and dynamic shader usage were checked in the package; no redistributed system fonts. The app contains its executable and PCK. Linked dependencies are Apple system frameworks/libraries. A moved launch and resource audit succeeded with source/editor/interpreter/network access denied. No source-only resource or development launcher is needed.

A directory identity means the SHA-256 of the sorted per-file SHA-256 manifest, with file modes recorded separately. Executable, PCK, template, engine, preset, source/art manifest and exact distributable ZIP hashes are explicit in evidence/B9/candidate.json. ZIP creation uses sorted entries, fixed timestamp and Unix modes; a second archive was byte-identical, and extraction preserved the signed bundle. New runtime/export/bundle/signing changes require a new retained candidate and relevant qualification. Final documentation is bound separately from the frozen export input manifest.

## Save/session contract

B9 keeps the B8 snapshot schema and early-expedition integral-number validation repair. Compatibility was demonstrated with a retained B8 synthetic snapshot in a disposable profile; no migration is necessary or automatic import/discovery implemented. B8 and earlier development namespaces stay separate. B9 ordinary launch ignores B8_SAVE_DIR; B9_SAVE_DIR is an explicit engineering override used only for isolated qualification. It is absent for owner use.

Generated session IDs are independent of names. Every session retains immutable snapshots and latest-valid recovery. current-session.txt points to Continue; presentation.cfg is separate. New wholly unsaved characters do not replace the previous saved selection. Queues stay inactive after Continue. Resources, party conditions, furnishing positions/storage, privacy and chapter outcomes remain exact.

If a snapshot fails, the gameplay transaction remains unsuccessful. If the snapshot succeeds and the current-session pointer fails, the durable gameplay outcome remains saved, Save and quit refuses, and retry/Earlier characters recovery remains available. Packaged failure tests verify both cases. Moving/replacing the app leaves this external data untouched.

## Diagnostic boundary

Release templates ignore the editor's --script option. Ordinary startup never runs diagnostics. A retained packaging adapter changes only test harness lifecycle (SceneTree to an always-processing Node), leaving chapter code/actions intact. Diagnostics require both an explicit `-- --b9-check=<name>` argument and an absolute disposable B9_SAVE_DIR. Named modes are branches, restart, sessions, tour, tour-restart, platform and presentation. No Python or editor is needed by ordinary launch or these bundled runners. Host scripts orchestrate logs/archive/movie conversion only.

`scripts/validate.sh B9` runs exact-package branches, save/quit, new-process checkpoints, failures and independent original-input arithmetic. `scripts/capture_b9.py` records the fresh ordinary generated-session journey and a new-process restart. Source/inherited regressions are retained separately through scripts/validate_b9_inherited.py. Native engineer review, synthetic checkpoints, scripted demonstration and owner acceptance are distinct evidence classes.

## Acceptance and distribution boundary

No purchase, commit, push, upload, public publication, external message, global security change or owner-save migration. A local Apple Development identity exists, but no valid Developer ID Application identity was found; the delivered package deliberately uses ad-hoc signing. No notarization credentials were used and no notarization was attempted. Gatekeeper rejection remains an explicit distribution limitation, not a local-gameplay failure. Do not strip quarantine or disable Gatekeeper to claim acceptance.

The B10 handoff is prepared only. Known limits: bounded English commands, silence, four-view cutout motion/simple pet articulation, remaining doorway occlusion, a paused downed-pose inconsistency, compact labels that do not scale with Text +, partial system-font coverage and unqualified screen-reader behavior. Other OS versions/architectures are unqualified.
