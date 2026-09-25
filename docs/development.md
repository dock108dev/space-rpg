# Development

## Requirements and launch

The game uses Godot 4.6.2 Standard (`4.6.2.stable.official.71f334935`), GDScript and the Compatibility renderer. Install the official macOS editor as `/Applications/Godot.app`. Python 3.14.5 runs the standard-library validation tools; no pip dependencies are required.

From the repository root:

```sh
bash scripts/launch_b8.sh
```

For a different engine location:

```sh
GODOT_BIN="/path/to/Godot.app/Contents/MacOS/Godot" bash scripts/launch_b8.sh
```

The launcher selects `game/scenes/player_experience.tscn`, Dummy audio and a 1152×882 window. Opening `game/project.godot` and running it selects the same scene. The logical canvas is 1280×980. The supported engine version is checked by source validation.

## Configuration and saves

| Name | Meaning |
| --- | --- |
| `GODOT_BIN` | Engine executable for the source launcher and focused source validation; defaults to the Applications path above. |
| `B8_SAVE_DIR` | Source character-session root; defaults to `dev-state/B8-practice-v1` relative to the repository. |
| `B9_SAVE_DIR` | Exported-player override; otherwise the app's user-data directory plus `chapter-v1`. |
| `b9_personal` | Export feature selecting packaged storage behavior. |
| `B2_TEST_NO_QUIT` | Synthetic-test switch preventing selected Save and quit checks from ending their harness. |

These names are supported code/configuration identifiers. The source and exported-player roots are separate contexts, not fallback aliases. Use a fresh absolute temporary directory for test overrides. No `.env` loader, credentials, service process or database is required.

The player creates separate character-session folders. `current-session.txt` selects the most recent character, while `presentation.cfg` stores the text-size preference. Snapshots are immutable, sequence-numbered JSON. Continue loads the latest valid snapshot in the selected session. See [architecture](ssot.md) and [recovery](error-handling.md). No save migration or cross-app import runs automatically.

## Source layout

- `game/scripts/`: controller inheritance, pure rules, validators, persistence and rendering helpers.
- `game/scenes/` and `game/art/`: runnable scenes and runtime assets.
- `source-assets/` and `assets/`: authored inputs and editable art; do not treat these as disposable output.
- `scripts/`: launch, validation, capture and export tools; `scripts/tests/` tests Python orchestration.
- `tests/fixtures/`: versioned synthetic inputs; validation writes copies, never these originals.
- `packaging/`: authored export configuration and license files.

Generated evidence/captures, development state, caches and root `build/` / `dist/` output are ignored. A source export used by validation excludes evidence and engine caches so local output cannot conceal missing inputs.

## Tests and exports

Run `bash scripts/validate.sh M4` for the focused source-export check. See [validation](validation.md) for available checks and [CI](ci.md) for the hosted configuration.

`python3 scripts/package_ui05.py` creates a separate local macOS app using the parameterized exporter in `package_b9.py`. It requires the matching official macOS export template in Godot's export-template directory and Apple command-line tools; it exports, thins to arm64 and ad-hoc signs the bundle. It is not part of normal source validation. The configured package minimum is macOS 27.0, and Gatekeeper assessment for existing ad-hoc builds is rejected. No notarization or public installer publication is configured. Changing those distribution requirements needs separate build/signing work.

Historical scene launchers remain explicit tools for retained prototypes. Current controller ancestors also supply active gameplay, so they cannot be deleted merely because their files have older names.
