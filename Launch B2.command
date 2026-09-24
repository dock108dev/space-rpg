#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
exec ./scripts/launch_b2.sh "$@"
