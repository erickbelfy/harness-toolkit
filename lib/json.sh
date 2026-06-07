# shellcheck shell=bash
# json.sh — JSON construction helpers + shared .mcp.json emitter.
# Depends on emit.sh (json_str/json_escape) and harness-scope helpers
# (list_artifacts, target_selected, artifact_id, fm_*). Sourced by bin/harness.

[ -n "${_HARNESS_JSON_SH:-}" ] && return 0
_HARNESS_JSON_SH=1

# json_arr_from_lines — stdin: one item per line -> ["a","b"] (string array).
json_arr_from_lines() {
  local first=1 line out="["
  while IFS= read -r line; do
    [ "$first" = 1 ] && first=0 || out="$out, "
    out="$out$(json_str "$line")"
  done
  printf '%s]' "$out"
}

# json_obj_from_tsv — stdin: "key<TAB>value" lines -> {"key":"value",...}.
json_obj_from_tsv() {
  local first=1 k v out="{"
  while IFS=$'\t' read -r k v; do
    [ -z "$k" ] && continue
    [ "$first" = 1 ] && first=0 || out="$out, "
    out="$out$(json_str "$k"): $(json_str "$v")"
  done
  printf '%s}' "$out"
}

# mcp_server_value <file> — JSON object describing one MCP server.
mcp_server_value() {
  local f="$1" tr; tr="$(fm_get "$f" transport)"; tr="${tr:-stdio}"
  if [ "$tr" = http ]; then
    local url hdrs; url="$(fm_get "$f" url)"
    hdrs="$(fm_get_map "$f" headers)"
    printf '{"type": "http", "url": %s' "$(json_str "$url")"
    [ -n "$hdrs" ] && printf ', "headers": %s' "$(printf '%s\n' "$hdrs" | json_obj_from_tsv)"
    printf '}'
  else
    local cmd args env; cmd="$(fm_get "$f" command)"
    args="$(fm_get_list "$f" args)"; env="$(fm_get_map "$f" env)"
    printf '{"command": %s' "$(json_str "$cmd")"
    [ -n "$args" ] && printf ', "args": %s' "$(printf '%s\n' "$args" | json_arr_from_lines)"
    [ -n "$env" ]  && printf ', "env": %s'  "$(printf '%s\n' "$env" | json_obj_from_tsv)"
    printf '}'
  fi
}

# mcp_servers_object <target> — { "name": {..}, ... } for mcp bound to <target>.
# Prints nothing if no servers match.
mcp_servers_object() {
  local target="$1" f first=1 name
  local body=""
  while IFS= read -r f; do
    target_selected "$f" mcp "$target" || continue
    name="$(artifact_id "$f" mcp)"
    [ "$first" = 1 ] && first=0 || body="$body,"
    body="$body
  $(json_str "$name"): $(mcp_server_value "$f")"
  done < <(list_artifacts mcp)
  [ "$first" = 1 ] && return 1   # none
  printf '{%s\n}' "$body"
}

# write_mcp_json <out_dir> <target> — write or safely merge .mcp.json.
# The file is treated as harness-owned: a clean full generate is written when
# the file is absent or already equals our output (keeps builds idempotent).
# When a *divergent* file is present we either jq-merge (preserving user keys)
# or, without jq, write a fragment and warn rather than clobber.
write_mcp_json() {
  local out_dir="$1" target="$2" servers path frag full
  servers="$(mcp_servers_object "$target")" || { debug "no mcp servers for $target"; return 0; }
  path="$out_dir/.mcp.json"
  full="$(printf '{\n  "mcpServers": %s\n}\n' "$(printf '%s' "$servers" | _indent 2)")"

  # Absent, or already exactly our output -> write/refresh (emit reports unchanged).
  if [ ! -f "$path" ] || printf '%s\n' "$full" | cmp -s - "$path"; then
    emit_write "$path" < <(printf '%s\n' "$full")
    return 0
  fi

  # Divergent existing file: never clobber.
  if has_cmd jq; then
    local merged
    if merged="$(jq --argjson new "$servers" \
        '.mcpServers = ((.mcpServers // {}) + $new)' "$path" 2>/dev/null)"; then
      emit_write "$path" < <(printf '%s\n' "$merged")
    else
      warn "jq merge failed for $path; left unchanged"
    fi
  else
    frag="$out_dir/.mcp.harness.json"
    emit_write "$frag" < <(printf '%s\n' "$full")
    warn "$path exists with non-harness content and jq is unavailable; wrote $frag — merge mcpServers manually"
  fi
}

# _indent <n> — indent every line after the first by n spaces (for nesting).
_indent() {
  awk -v n="$1" 'BEGIN{pad=sprintf("%*s",n,"")} NR==1{print;next}{print pad $0}'
}
