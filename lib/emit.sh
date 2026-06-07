# shellcheck shell=bash
# emit.sh — safe output: atomic, idempotent file writes + JSON primitives.
#
# Public API:
#   emit_write <path>      reads stdin, writes <path> only if content changed.
#                          Honors HARNESS_DRY_RUN. Prints "created/updated/
#                          unchanged <path>" and bumps EMIT_CREATED/_UPDATED.
#   emit_copy_tree <src> <dst>   idempotent recursive copy of a directory tree.
#   json_escape            stdin -> stdout: escape a string for a JSON value
#                          (no surrounding quotes added).
#   json_str <s>           print a fully-quoted JSON string for argument <s>.

[ -n "${_HARNESS_EMIT_SH:-}" ] && return 0
_HARNESS_EMIT_SH=1

# Counters surfaced in the build summary.
EMIT_CREATED=0
EMIT_UPDATED=0
EMIT_UNCHANGED=0

# emit_write <path>  (content on stdin)
emit_write() {
  local path="$1" tmp status
  local dir; dir="$(dirname "$path")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/harness.XXXXXX")" || die "mktemp failed"
  cat >"$tmp"

  if [ -f "$path" ] && cmp -s "$tmp" "$path"; then
    status=unchanged; EMIT_UNCHANGED=$((EMIT_UNCHANGED+1))
    rm -f "$tmp"
  elif [ -f "$path" ]; then
    status=updated; EMIT_UPDATED=$((EMIT_UPDATED+1))
  else
    status=created; EMIT_CREATED=$((EMIT_CREATED+1))
  fi

  if [ "$HARNESS_DRY_RUN" = 1 ]; then
    [ "$status" = unchanged ] || info "would $status $path"
    rm -f "$tmp"
    return 0
  fi

  if [ "$status" = unchanged ]; then
    debug "unchanged $path"
    return 0
  fi

  mkdir -p "$dir" || { rm -f "$tmp"; die "cannot create $dir"; }
  mv "$tmp" "$path" || { rm -f "$tmp"; die "cannot write $path"; }
  info "$status $path"
}

# emit_once <path>  (content on stdin) — write <path> only if it does NOT already
# exist; never overwrites. For user-owned files the toolkit seeds once and then
# leaves alone (e.g. an override stub). Honors HARNESS_DRY_RUN.
emit_once() {
  local path="$1"
  if [ -f "$path" ]; then
    debug "kept $path (exists)"
    return 0
  fi
  if [ "$HARNESS_DRY_RUN" = 1 ]; then
    info "would create $path"
    cat >/dev/null
    return 0
  fi
  mkdir -p "$(dirname "$path")" || die "cannot create $(dirname "$path")"
  cat >"$path" || die "cannot write $path"
  EMIT_CREATED=$((EMIT_CREATED+1))
  info "created $path"
}

# emit_copy_tree <src_dir> <dst_dir> — copy files idempotently, preserving layout.
emit_copy_tree() {
  local src="$1" dst="$2" rel
  [ -d "$src" ] || return 0
  # Walk regular files under src; emit_write each to keep idempotency reporting.
  while IFS= read -r f; do
    rel="${f#"$src"/}"
    emit_write "$dst/$rel" <"$f"
  done < <(find "$src" -type f | LC_ALL=C sort)
}

# json_escape — escape stdin as a JSON string body (no surrounding quotes).
json_escape() {
  awk '
    BEGIN{
      for(i=0;i<32;i++) ctrl[sprintf("%c",i)]=sprintf("\\u%04x",i)
      ctrl[sprintf("%c",8)]="\\b"; ctrl[sprintf("%c",9)]="\\t"
      ctrl[sprintf("%c",10)]="\\n"; ctrl[sprintf("%c",12)]="\\f"
      ctrl[sprintf("%c",13)]="\\r"
    }
    {
      if (NR>1) printf "\\n"
      line=$0
      gsub(/\\/, "\\\\", line)
      gsub(/"/, "\\\"", line)
      out=""
      n=length(line)
      for(i=1;i<=n;i++){ c=substr(line,i,1); out=out (c in ctrl ? ctrl[c] : c) }
      printf "%s", out
    }
  '
}

# json_str <s> — print "<escaped s>" as a complete JSON string token.
json_str() {
  printf '"%s"' "$(printf '%s' "$1" | json_escape)"
}
