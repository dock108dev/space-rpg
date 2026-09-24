#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [[ ! -x "$GODOT_BIN" ]]; then
  echo 'B2 needs the installed Godot 4.6.2 app in /Applications.' >&2
  exit 1
fi
if [[ "$("$GODOT_BIN" --version)" != '4.6.2.stable.official.71f334935' ]]; then
  echo 'B2 was verified with Godot 4.6.2.stable.official.71f334935. Choose that binary using GODOT_BIN.' >&2
  exit 1
fi
export B2_SAVE_DIR="${B2_SAVE_DIR:-$ROOT/dev-state/B2-practice-v1}"
exec "$GODOT_BIN" --audio-driver Dummy --path "$ROOT/game" --resolution 1280x720 res://scenes/chapter_opening.tscn "$@"
