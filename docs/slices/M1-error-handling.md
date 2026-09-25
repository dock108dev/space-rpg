# M1 — Error handling maintenance

**TECHNICALLY COMPLETE — source only.** User-authorized source maintenance after frozen B9-20260924-01. B10 remains NOT STARTED. Preserve the installed app, B9 evidence/staging, prior builds and existing work.

Inspected runtime scripts, launch/validation/capture/packaging tools and retained asset-tool catches. Implemented storage/recovery/startup fixes and observable non-fatal failures; validated through the project-local isolated runner and affected B8 checks. No packaging, signing, owner-state access, commit or publication.

Baseline: source HEAD 304b11ef6a8a67f32b0814ac44342b29fffbd815 plus substantial existing uncommitted B4–B9 work. Frozen B9 export source manifest c0d82df257228b263598a0d5364805e5fb446a482efe3d162b83802bcac9095e; archive 266121a075bd5aa876df84151c36c1832c0366d5aa0ded75e6b898ea15c6a744. Changed checkout is a separate source revision and does not requalify that app.

## Delivery

[Implemented behavior and operations](../error-handling.md) covers the commit boundary, conservative writer recovery, checked directory inspection, invalid Continue selectors, explicit Earlier character selection, per-attempt pointer temporary files, observable preferences and boot failures. Retained snapshot fallback, transactional rollback, optional preferences, timeout-to-failure handling and traceback/re-raise asset-tool boundaries remain deliberate.

Validation on final runtime:
- `bash scripts/validate.sh M1`: import, 19 focused checks and two expected startup failures PASS. [Results](../../evidence/M1/run-20260924T224705084341Z/results.json).
- `bash scripts/validate.sh B8`: 394 gameplay/branch checks, 24 setup/save/input checks, separate-process save/Continue stages, namespace isolation and 432 independently reconciled snapshots PASS. [Results](../../evidence/B8/run-20260924T224703Z/results.json).
- Python syntax for the three changed/new Python scripts and shell syntax for `scripts/validate.sh` PASS.
- Installed executable/PCK, retained B9 archive and all 461 frozen staged-runtime entries match recorded hashes. [Preservation](../../evidence/M1/preservation-check.json).

Earlier M1 failed attempts remain retained. They caught the macOS missing-path error ambiguity, invalid-PID probe behavior, noisy parsing of an expected malformed marker, and a fresh-character Continue fallback regression introduced in this pass; all were corrected before the final checks. Prior B9 evidence is not relabeled as M1 evidence.

No engineering slice remains active. Native GUI review, real disk-full/close-time faults, concurrent stale-state merging, bounded process-query execution and new packaging remain separate limits/follow-ups as detailed in the operations guide. No signed build, release, owner-state access or owner acceptance. B10 remains NOT STARTED.
