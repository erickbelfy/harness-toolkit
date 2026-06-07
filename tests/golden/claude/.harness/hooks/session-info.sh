#!/usr/bin/env bash
# session-info.sh — print a brief repo summary at session start.
set -euo pipefail
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
echo "repo: $(basename "$root")"
git -C "$root" log -1 --oneline 2>/dev/null || true
