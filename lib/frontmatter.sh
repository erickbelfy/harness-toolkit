# shellcheck shell=bash
# frontmatter.sh — zero-dependency YAML frontmatter parser (awk-based).
#
# Supports the constrained YAML subset the canonical schema uses:
#   - scalars:        key: value   |   key: "value"   |   key: 'value'
#   - inline lists:   key: [a, b, "c d"]
#   - block lists:    key:\n  - a\n  - b
# It deliberately does NOT support nested maps (beads are parsed separately).
#
# Public API:
#   fm_raw  <file>            -> frontmatter lines (without --- fences); rc!=0 if none
#   fm_body <file>            -> markdown body after the closing fence
#   fm_get  <file> <key>      -> scalar value (quotes stripped); empty if missing
#   fm_has  <file> <key>      -> exit 0 if key present
#   fm_get_list <file> <key>  -> list items, one per line (inline or block)
#   fm_get_map  <file> <key>  -> nested map entries as "subkey\tvalue" lines

[ -n "${_HARNESS_FRONTMATTER_SH:-}" ] && return 0
_HARNESS_FRONTMATTER_SH=1

# Print the frontmatter block (between the first two `---` fences), fences excluded.
# Returns non-zero if the file has no leading frontmatter fence.
fm_raw() {
  awk '
    NR==1 && $0!="---" { exit 2 }       # no leading fence
    NR==1 { infm=1; next }
    infm && $0=="---" { exit 0 }
    infm { print }
  ' "$1"
}

# Print everything after the closing frontmatter fence (the markdown body).
fm_body() {
  awk '
    NR==1 && $0!="---" { body=1 }       # no frontmatter: whole file is body
    body { print; next }
    NR==1 { seen=1; next }
    seen && $0=="---" { body=1; next }
  ' "$1"
}

# Internal: strip matched surrounding quotes and trailing whitespace from a value.
_fm_unquote() {
  awk '{
    v=$0
    sub(/[ \t]+$/, "", v)
    if (v ~ /^".*"$/ || v ~ /^'\''.*'\''$/) v=substr(v, 2, length(v)-2)
    print v
  }'
}

# fm_get <file> <key> — first scalar match wins.
fm_get() {
  fm_raw "$1" | awk -v key="$2" '
    {
      line=$0
      # split on first ":"
      p=index(line, ":")
      if (p==0) next
      k=substr(line, 1, p-1)
      gsub(/^[ \t]+|[ \t]+$/, "", k)
      if (k!=key) next
      v=substr(line, p+1)
      gsub(/^[ \t]+/, "", v)
      print v
      exit
    }
  ' | _fm_unquote
}

# fm_has <file> <key>
fm_has() {
  fm_raw "$1" | awk -v key="$2" '
    { p=index($0,":"); if(p==0) next
      k=substr($0,1,p-1); gsub(/^[ \t]+|[ \t]+$/,"",k)
      if(k==key){found=1; exit} }
    END { exit (found?0:1) }
  '
}

# fm_get_list <file> <key> — emits one item per line. Handles inline [..] and
# block "- " sequences. Quotes and surrounding whitespace are stripped per item.
fm_get_list() {
  fm_raw "$1" | awk -v key="$2" '
    function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    function unq(s){
      s=trim(s)
      if (s ~ /^".*"$/ || s ~ /^'\''.*'\''$/) s=substr(s,2,length(s)-2)
      return s
    }
    {
      if (incb) {
        # inside a block list: indented "- item" lines continue it
        if ($0 ~ /^[ \t]+-[ \t]*/) {
          item=$0; sub(/^[ \t]+-[ \t]*/,"",item); print unq(item); next
        } else { incb=0 }   # block ended; fall through to re-test this line
      }
      p=index($0,":"); if(p==0) next
      k=substr($0,1,p-1); gsub(/^[ \t]+|[ \t]+$/,"",k)
      if (k!=key) next
      v=trim(substr($0,p+1))
      if (v=="") { incb=1; next }                  # block list follows
      if (v ~ /^\[.*\]$/) {                         # inline flow list
        inner=substr(v,2,length(v)-2)
        n=split(inner, a, ",")
        for(i=1;i<=n;i++){ it=unq(a[i]); if(it!="") print it }
        exit
      }
      print unq(v)                                  # single scalar as 1-item list
      exit
    }
  '
}

# fm_get_map <file> <key> — for a block map:
#   key:
#     sub1: val1
#     sub2: "val2"
# emits TAB-separated "sub<TAB>value" lines. Values are unquoted.
fm_get_map() {
  fm_raw "$1" | awk -v key="$2" '
    function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
    function unq(s){ s=trim(s)
      if(s ~ /^".*"$/ || s ~ /^'\''.*'\''$/) s=substr(s,2,length(s)-2); return s }
    {
      if (inmap) {
        if ($0 ~ /^[ \t]+[^ \t-]/ && index($0,":")>0) {   # indented "sub: val"
          p=index($0,":"); sk=trim(substr($0,1,p-1)); sv=trim(substr($0,p+1))
          printf "%s\t%s\n", sk, unq(sv); next
        } else { exit }                                   # dedent ends the map
      }
      p=index($0,":"); if(p==0) next
      k=substr($0,1,p-1); gsub(/^[ \t]+|[ \t]+$/,"",k)
      if (k!=key) next
      if (trim(substr($0,p+1))=="") inmap=1               # only a bare "key:" opens a map
    }
  '
}
