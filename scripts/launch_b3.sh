#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
export B3_SAVE_DIR="${B3_SAVE_DIR:-$ROOT/dev-state/B3-practice-v1}"
exec "$GODOT_BIN" --audio-driver Dummy --path "$ROOT/game" --resolution 1152x882 res://scenes/connected_world.tscn "$@"
