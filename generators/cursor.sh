# shellcheck shell=bash
# cursor.sh — generate Cursor configuration.
#   rules    -> .cursor/rules/<id>.mdc (one file each; globs UNQUOTED comma-list)
#   commands -> .cursor/rules/<slug>.mdc as a Manual (@-invoked) rule shim
#   AGENTS.md -> owned by the agentsmd target (Cursor reads it natively)
#   agents/skills/hooks/mcp -> no Cursor equivalent; skipped with a SKIP log
# Requires harness-scope helpers.

gen_cursor() {
  local out; out="$OUT_DIR/$(manifest_target_out "$MANIFEST" cursor)"
  _cursor_rules "$out"
  _cursor_commands "$out"
  _cursor_skips
}

# .cursor/rules/<id>.mdc — one rule per file. Cursor mode is implied by fields:
#   alwaysApply:true -> Always | globs set -> Auto-Attach | else description -> Agent-requested
_cursor_rules() {
  local out="$1" f id desc globs always tmp
  while IFS= read -r f; do
    target_selected "$f" rules cursor || continue
    id="$(artifact_id "$f" rules)"
    desc="$(fm_get "$f" description)"
    globs="$(fm_get "$f" globs)"
    always="$(fm_get "$f" alwaysApply)"; always="${always:-false}"
    tmp="$(mktemp)"
    {
      printf -- '---\n'
      [ -n "$desc" ] && printf 'description: %s\n' "$desc"
      # IMPORTANT: globs must be an UNQUOTED comma-separated list for Cursor.
      [ -n "$globs" ] && printf 'globs: %s\n' "$globs"
      printf 'alwaysApply: %s\n' "$always"
      printf -- '---\n\n'
      fm_body "$f" | _trim_edges
    } >"$tmp"
    emit_write "$out/.cursor/rules/$id.mdc" <"$tmp"; rm -f "$tmp"
  done < <(list_artifacts rules)
}

# Commands have no native Cursor equivalent; emit a Manual rule (no globs, not
# always-applied) so it can be invoked with @<name>.
_cursor_commands() {
  local out="$1" f id desc tmp
  while IFS= read -r f; do
    target_selected "$f" commands cursor || continue
    id="$(artifact_id "$f" commands)"; desc="$(fm_get "$f" description)"
    tmp="$(mktemp)"
    {
      printf -- '---\n'
      [ -n "$desc" ] && printf 'description: %s\n' "$desc"
      printf 'alwaysApply: false\n'
      printf -- '---\n\n'
      printf '# /%s\n\n' "$id"
      fm_body "$f" | _trim_edges
    } >"$tmp"
    emit_write "$out/.cursor/rules/$id.mdc" <"$tmp"; rm -f "$tmp"
  done < <(list_artifacts commands)
}

# Log clearly when artifacts are explicitly bound to cursor but unsupported.
_cursor_skips() {
  local cat f n
  for cat in agents skills hooks mcp; do
    n=0
    while IFS= read -r f; do
      if target_selected "$f" "$cat" cursor; then n=$((n+1)); fi
    done < <(list_artifacts "$cat")
    [ "$n" -gt 0 ] && warn "SKIP target=cursor type=$cat ($n artifact(s); Cursor has no equivalent)"
  done
  return 0
}

_trim_edges() {
  awk '{l[NR]=$0}END{a=1;while(a<=NR&&l[a]=="")a++;b=NR;while(b>=1&&l[b]=="")b--;for(i=a;i<=b;i++)print l[i]}'
}
