#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "$0")" && pwd)"
CANDIDATE="$ROOT/builds/S04-20260909-01"
export S04_SAVE_DIR="${S04_SAVE_DIR:-$ROOT/dev-state/S05-20260909-01}"
exec "$CANDIDATE/scripts/launch_integrated.sh" "$@"
