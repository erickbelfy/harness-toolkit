#!/usr/bin/env bash
# tests/golden.sh — (re)generate golden fixtures from the current canonical
# source. Each target is built into tests/golden/<target>/ so test/run.sh can
# diff a fresh full build against them. Review the git diff before committing.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

targets="${1:-agentsmd claude cursor gastown}"
for t in $targets; do
  [ -f "generators/$t.sh" ] || continue
  dir="tests/golden/$t"
  rm -rf "$dir"; mkdir -p "$dir"
  bin/harness build --target "$t" --dir "$dir" --quiet
  echo "refreshed tests/golden/$t"
done
