# M4 — Repository cleanup

Status: TECHNICALLY COMPLETE.

Build on M3 SSOT decisions. Remove ignored-evidence dependencies from current focused tests and interface captures; share duplicate capture orchestration and remove unreachable UI-05 before branch. Make README concise and developer guidance current. Untrack only redundant entry/tracker snapshots while retaining local bytes. Retain cohesive controller hierarchy and required historical review paths. No packaging/signing, owner-data access or commit/push.

Delivered portable synthetic fixture inputs for M3 and UI capture checks, a shared multiline capture helper with thin supported CLI wrappers, removal of unreachable UI-05 before handling, explicit missing-baseline failure, and M3 output-directory creation on a fresh export. README now links to development and documentation indexes. Existing M3 gameplay structure decisions are retained.

Validation: `bash scripts/validate.sh M4` exports current game/scripts/tests without evidence/caches, runs four Python orchestration tests and M3's 33 runtime assertions plus three launcher cases, import, default startup and state isolation. PASS in `evidence/M4/run-20260925T002024267646Z`. Python/shell syntax, documentation links and staged/unstaged whitespace checks pass. First clean-export failure exposed missing parent output-directory creation; repaired and rerun successfully.

Four redundant entry/tracker snapshots were untracked, remain byte-identical locally and now match ignore rules. Two required fixture JSONs plus provenance README are staged for tracking. No ignored tracked artifacts remain. Runtime assets, masters, formal review records and unrelated staged/unfinished work were preserved. No commit/push or history rewrite; current working source was exported for validation, not represented as a committed clean checkout.

No engineering slice remains active. Frozen B9/UI-05 bundle and archive hashes remain intact; no packaging/signing or owner-data access. No broad gameplay matrix or native walkthrough was run for tooling-only changes. A future commit of the accumulated source changes is a separate authorized action.
