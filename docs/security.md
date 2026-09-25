# Security boundaries

The game is an offline single-player Godot desktop application running with the launching user's filesystem permissions. It is not an operating-system sandbox. There is no account/login, HTTP endpoint, analytics, payment flow or remote gameplay provider.

| Input | Enforcement |
| --- | --- |
| Typed command | Maximum 1,000 characters before parsing and at most 128 expanded actions. Game rules validate targets, costs and current state. No shell or eval execution. |
| Character name | Control/directional characters are removed; names are trimmed to 32 Unicode code points. Blank names become Alex. |
| Narrative/history | Plain text; the player transcript disables BBCode interpretation. |
| Snapshot | Maximum 32 KiB read; filename/sequence and schema validation before state application. Invalid entries are skipped with a notice. |
| Session selector | Maximum 256 bytes; only supported session names without path traversal are accepted. |
| Presentation preference | Maximum 4 KiB read; malformed/unreadable data falls back to default text size with a warning. |
| Local storage paths | Linked final roots/sessions, snapshots, selectors, preferences and writer recovery paths are refused. |

Save roots and their parent directories are trusted local configuration. The checks do not defeat a hostile process running as the same user, hard-link manipulation or replacement of trusted ancestors. They are not race-proof authorization. Do not use an untrusted shared directory as the save root.

Writer recovery uses a fixed `/bin/ps -axo pid=` inventory and fails closed if process status cannot be established. Source tooling invokes subprocess argument arrays or quoted shell arguments; gameplay text never selects an executable. `GODOT_BIN` is a trusted developer override.

Exported diagnostics use a named allowlist and require an explicit absolute `B9_SAVE_DIR`. This is an operator safeguard, not authentication or proof that a directory is disposable. Ordinary gameplay cannot select diagnostics. Use fresh synthetic directories for checks.

Names, history and chapter progress remain in local JSON; there is no cloud synchronization or application credential store. Dependency downloads are development/CI operations, separate from gameplay. CI uses read-only repository permissions and checksum-verifies the official engine archive before extraction; see [CI](ci.md).

The bounded local checks are not a Git-history secret audit, operating-system sandbox assessment or comprehensive dependency vulnerability certification.
