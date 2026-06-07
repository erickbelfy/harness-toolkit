# shellcheck shell=bash
# manifest.sh — minimal TOML reader for harness.toml.
#
# Supports only the subset the manifest uses:
#   [section]                       (incl. dotted: [targets.claude])
#   key = "string" | key = true | key = 123
#   key = ["a", "b"]               (inline array of strings)
# No nested tables, no multiline arrays.
#
# Public API (all take the manifest path as $1):
#   manifest_get      <file> <section> <key>     -> scalar (quotes stripped)
#   manifest_list     <file> <section> <key>     -> array items, one per line
#   manifest_sections <file> <prefix>            -> section names under prefix
#                                                   e.g. prefix "targets." -> claude,cursor,...
#   manifest_target_enabled <file> <target>      -> exit 0 if enabled=true
#   manifest_target_out     <file> <target>      -> out dir (default ".")
#   manifest_mapping        <file> <category>    -> target names for a category

[ -n "${_HARNESS_MANIFEST_SH:-}" ] && return 0
_HARNESS_MANIFEST_SH=1

manifest_get() {
  awk -v want="$2" -v key="$3" '
    function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    function unq(s){ s=trim(s)
      if(s ~ /^".*"$/ || s ~ /^'\''.*'\''$/) s=substr(s,2,length(s)-2); return s }
    /^[ \t]*#/ { next }
    /^[ \t]*\[/ {                                  # section header
      h=$0; sub(/^[ \t]*\[/,"",h); sub(/\].*/,"",h); cur=trim(h); next
    }
    {
      if (cur!=want) next
      p=index($0,"="); if(p==0) next
      k=trim(substr($0,1,p-1)); if(k!=key) next
      v=trim(substr($0,p+1))
      sub(/[ \t]+#.*$/,"",v)                       # strip trailing comment
      print unq(v); exit
    }
  ' "$1"
}

manifest_list() {
  awk -v want="$2" -v key="$3" '
    function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    function unq(s){ s=trim(s)
      if(s ~ /^".*"$/ || s ~ /^'\''.*'\''$/) s=substr(s,2,length(s)-2); return s }
    /^[ \t]*#/ { next }
    /^[ \t]*\[/ { h=$0; sub(/^[ \t]*\[/,"",h); sub(/\].*/,"",h); cur=trim(h); next }
    {
      if (cur!=want) next
      p=index($0,"="); if(p==0) next
      k=trim(substr($0,1,p-1)); if(k!=key) next
      v=trim(substr($0,p+1))
      sub(/^\[/,"",v); sub(/\].*$/,"",v)
      n=split(v,a,","); for(i=1;i<=n;i++){ it=unq(a[i]); if(it!="") print it }
      exit
    }
  ' "$1"
}

manifest_sections() {
  awk -v pfx="$2" '
    function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    /^[ \t]*\[/ {
      h=$0; sub(/^[ \t]*\[/,"",h); sub(/\].*/,"",h); h=trim(h)
      if (index(h,pfx)==1) print substr(h,length(pfx)+1)
    }
  ' "$1"
}

manifest_target_enabled() {
  [ "$(manifest_get "$1" "targets.$2" enabled)" = "true" ]
}

manifest_target_out() {
  local out; out="$(manifest_get "$1" "targets.$2" out)"
  printf '%s' "${out:-.}"
}

manifest_mapping() {
  manifest_list "$1" mappings "$2"
}
