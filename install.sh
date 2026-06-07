#!/usr/bin/env bash
# install.sh — symlink the harness CLI onto your PATH.
# Usage: ./install.sh [bin_dir]   (default: ~/.local/bin)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${1:-$HOME/.local/bin}"

mkdir -p "$BIN_DIR"
chmod +x "$ROOT/bin/harness"
ln -sf "$ROOT/bin/harness" "$BIN_DIR/harness"
echo "linked $BIN_DIR/harness -> $ROOT/bin/harness"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "note: $BIN_DIR is not on your PATH — add it, e.g.:"
     echo "      export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

echo "done. Try: harness doctor"
