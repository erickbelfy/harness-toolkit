# shellcheck shell=bash
# common.sh — shared logging, error handling, and path helpers.
# Sourced by bin/harness and every generator. No side effects on source.

# Guard against double-sourcing.
[ -n "${_HARNESS_COMMON_SH:-}" ] && return 0
_HARNESS_COMMON_SH=1

# --- Verbosity -------------------------------------------------------------
# HARNESS_VERBOSE / HARNESS_QUIET are set from CLI flags.
: "${HARNESS_VERBOSE:=0}"
: "${HARNESS_QUIET:=0}"
: "${HARNESS_DRY_RUN:=0}"

# Colors only when stderr is a TTY and NO_COLOR is unset.
if [ -t 2 ] && [ -z "${NO_COLOR:-}" ]; then
  _C_RED=$'\033[31m'; _C_YEL=$'\033[33m'; _C_BLU=$'\033[34m'
  _C_DIM=$'\033[2m'; _C_RST=$'\033[0m'
else
  _C_RED=''; _C_YEL=''; _C_BLU=''; _C_DIM=''; _C_RST=''
fi

log()  { [ "$HARNESS_QUIET" = 1 ] && return 0; printf '%s%s%s\n' "$_C_BLU" "$*" "$_C_RST" >&2; }
info() { [ "$HARNESS_QUIET" = 1 ] && return 0; printf '%s\n' "$*" >&2; }
warn() { printf '%swarning:%s %s\n' "$_C_YEL" "$_C_RST" "$*" >&2; }
err()  { printf '%serror:%s %s\n' "$_C_RED" "$_C_RST" "$*" >&2; }
debug() { [ "$HARNESS_VERBOSE" = 1 ] || return 0; printf '%s· %s%s\n' "$_C_DIM" "$*" "$_C_RST" >&2; }

# die <message> [exit_code]
die() { err "$1"; exit "${2:-1}"; }

# require_cmd <cmd> — fail if a hard dependency is missing.
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }

# has_cmd <cmd> — true/false for optional dependency probing.
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# HARNESS_ROOT — absolute path to the toolkit install (where bin/harness lives).
# Resolved by bin/harness before sourcing; fall back to this file's grandparent.
if [ -z "${HARNESS_ROOT:-}" ]; then
  _self="${BASH_SOURCE[0]}"
  HARNESS_ROOT="$(cd "$(dirname "$_self")/.." && pwd)"
fi
export HARNESS_ROOT
