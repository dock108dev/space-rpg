#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case "${1:-}" in
  S02) exec python3 "$ROOT/scripts/validate_s02.py" ;;
  S03) exec python3 "$ROOT/scripts/validate_s03.py" ;;
  S04) exec python3 "$ROOT/scripts/validate_s04.py" ;;
  *) echo 'Usage: scripts/validate.sh S02|S03|S04' >&2; exit 2 ;;
esac
