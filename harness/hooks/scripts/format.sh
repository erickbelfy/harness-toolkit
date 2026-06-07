#!/usr/bin/env bash
# format.sh — best-effort formatter invoked by the format-on-write hook.
# Detects a common formatter for the project and runs it; no-op if none found.
set -euo pipefail

if [ -f package.json ] && grep -q '"prettier"' package.json 2>/dev/null; then
  npx --no-install prettier --write . >/dev/null 2>&1 || true
elif command -v gofmt >/dev/null 2>&1 && ls ./*.go >/dev/null 2>&1; then
  gofmt -w . || true
elif command -v ruff >/dev/null 2>&1; then
  ruff format . >/dev/null 2>&1 || true
fi
