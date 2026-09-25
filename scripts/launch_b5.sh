#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
export B5_SAVE_DIR="${B5_SAVE_DIR:-$ROOT/dev-state/B5-practice-v1}"
exec "$GODOT_BIN" --audio-driver Dummy --path "$ROOT/game" --resolution 1152x882 res://scenes/owned_home.tscn "$@"
