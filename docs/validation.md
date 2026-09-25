# Validation

Run commands from the repository root with Python 3.14.5 and the supported Godot editor available. Tests use disposable synthetic sessions. Do not point test overrides at personal character directories.

| Command | Scope |
| --- | --- |
| `bash scripts/validate.sh M4` | Export current game/scripts/tests without local evidence/caches, then run Python orchestration tests and focused source checks. This is the ordinary CI entry. |
| `bash scripts/validate.sh M3` | Engine version, fresh import, current startup, one save-store factory, schema boundaries, save round-trip, explicit prototype routing and namespace isolation. |
| `python3 -m unittest discover -s scripts/tests` | Capture routing, isolation, historical-baseline errors and CI installer trust checks; no native windows or network requests. |
| `python3 -m compileall -q scripts` | Python syntax. |
| `bash scripts/validate.sh B8` | Broader current chapter journeys, branches, recovery, Save and quit, separate-process Continue and arithmetic checks. Use when affected gameplay requires it. |
| `bash scripts/validate.sh M1` / `M2` | Focused save-error and local security cases. |

The selector names are existing script interfaces. A normal documentation change does not require every test selector. Interpret an import/compile failure separately from a failed assertion; logs and result JSON are retained under `evidence/`.

## Interface checks

`python3 scripts/capture_ui05.py 1152x882` captures representative current screens and checks layout/focus/recovery. It also accepts 1280×980. `capture_ui04.py after 1152x882` selects an older capture harness. Both share `interface_capture.py` and versioned `tests/fixtures/interface-cases.json`; they use a copied project and disposable state.

`capture_ui04.py before 1152x882` is historical replay only. It requires `evidence/UI-04/before-source/game/scripts/player_experience.gd` and fails explicitly without it. Current captures do not require that archive. Required fixture inputs are synthetic and their provenance is recorded in `tests/fixtures/README.md`.

## Packaged checks

`python3 scripts/validate_b9.py /absolute/path/to/retained-build` runs the actual exported executable selected by that build's candidate metadata. `validate_ui05.py` uses the same explicit build-directory argument for packaged interface, resource and hardening checks. These require an existing compatible export and are separate from source validation. The ordinary chapter movie runner is `capture_b9.py /absolute/path/to/retained-build`; it additionally requires `ffmpeg` and `ffprobe` on PATH.

Source tests do not prove an exported application starts correctly, passes Gatekeeper or is accepted by players. A check result applies to its tested files or package. Keep the command, runtime, source/bundle hashes and actual failures with retained evidence; do not transfer success from an older export to changed source.

## Hosted checks

[CI](ci.md) runs one focused macOS source job and preserves diagnostic logs. Native screenshots, packaged execution, signing and full historical suites are not part of ordinary pull-request CI. Historical test counts and candidate-specific results remain in the designated records, not in this command reference.
