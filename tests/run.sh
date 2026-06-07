#!/usr/bin/env bash
# tests/run.sh — zero-dependency test runner (no bats required).
# Runs library unit checks and golden-file integration checks.
# Exit non-zero on any failure.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
no()   { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; [ -n "${2:-}" ] && printf '       %s\n' "$2"; }
# eq <name> <expected> <actual>
eq()   { if [ "$2" = "$3" ]; then ok "$1"; else no "$1" "expected [$2] got [$3]"; fi; }

# shellcheck source=../lib/common.sh
source lib/common.sh
# shellcheck source=../lib/frontmatter.sh
source lib/frontmatter.sh
# shellcheck source=../lib/emit.sh
source lib/emit.sh

echo "== frontmatter =="
FX="$(mktemp -d)"
cat >"$FX/a.md" <<'EOF'
---
id: sample
description: "a quoted value"
globs: "*.ts,*.tsx"
tools: [Read, Grep, Glob]
args: ["-y", "pkg name"]
block:
  - one
  - two
---
Body 1
Body 2
EOF
eq "fm_get quoted"      "a quoted value"  "$(fm_get "$FX/a.md" description)"
eq "fm_get comma-list"  "*.ts,*.tsx"      "$(fm_get "$FX/a.md" globs)"
eq "fm_get_list inline" $'Read\nGrep\nGlob' "$(fm_get_list "$FX/a.md" tools)"
eq "fm_get_list spaces" $'-y\npkg name'   "$(fm_get_list "$FX/a.md" args)"
eq "fm_get_list block"  $'one\ntwo'       "$(fm_get_list "$FX/a.md" block)"
eq "fm_body"            $'Body 1\nBody 2' "$(fm_body "$FX/a.md")"
if fm_has "$FX/a.md" id; then ok "fm_has present"; else no "fm_has present"; fi
if fm_has "$FX/a.md" nope; then no "fm_has absent"; else ok "fm_has absent"; fi
rm -rf "$FX"

echo "== json =="
eq "json_escape" 'a\"b\\c\tend' "$(printf 'a"b\\c\tend' | json_escape)"
eq "json_str"    '"he said \"hi\""' "$(json_str 'he said "hi"')"

echo "== golden =="
if [ -d tests/golden ] && [ -n "$(ls -A tests/golden 2>/dev/null)" ]; then
  TMP="$(mktemp -d)"
  bin/harness build --dir "$TMP" --quiet
  for t in tests/golden/*/; do
    tname="$(basename "$t")"
    while IFS= read -r gf; do
      rel="${gf#"$t"}"
      if [ ! -f "$TMP/$rel" ]; then no "golden/$tname/$rel" "missing in output"; continue; fi
      if diff -u "$gf" "$TMP/$rel" >/tmp/harness-golden-diff 2>&1; then
        ok "golden/$tname/$rel"
      else
        no "golden/$tname/$rel" "$(head -20 /tmp/harness-golden-diff)"
      fi
    done < <(find "$t" -type f | LC_ALL=C sort)
  done
  rm -rf "$TMP"
else
  echo "  (no golden fixtures yet — skipped)"
fi

echo
echo "== idempotency =="
TMP2="$(mktemp -d)"
bin/harness build --dir "$TMP2" --quiet
out="$(bin/harness build --dir "$TMP2" 2>&1)"
if printf '%s' "$out" | grep -qE '^(created|updated) '; then
  no "second build is a no-op" "$out"
else
  ok "second build is a no-op"
fi
rm -rf "$TMP2"

echo
echo "== gastown docker sandbox =="
# opt-out: default manifest emits no docker files
TMPD="$(mktemp -d)"
bin/harness build --target gastown --dir "$TMPD" --quiet
if [ -e "$TMPD/.gastown/docker/docker-compose.yml" ]; then
  no "docker_env off -> no sandbox"
else
  ok "docker_env off -> no sandbox"
fi
rm -rf "$TMPD"

# opt-in: docker_env=true emits the sandbox
MAN="$(mktemp)"; sed 's/^docker_env = false/docker_env = true/' harness.toml >"$MAN"
TMPD="$(mktemp -d)"
bin/harness build --target gastown --dir "$TMPD" --manifest "$MAN" --quiet
for f in docker-compose.yml Dockerfile docker-entrypoint.sh .env.example docker-compose.override.yml; do
  if [ -f "$TMPD/.gastown/docker/$f" ]; then ok "sandbox emits $f"; else no "sandbox emits $f"; fi
done
# base file matches vendored source
if cmp -s "$TMPD/.gastown/docker/docker-compose.yml" assets/gastown-docker/docker-compose.yml; then
  ok "base compose matches asset"; else no "base compose matches asset"; fi
# create-once: edit override, rebuild -> preserved
printf '\n# USER EDIT\n' >>"$TMPD/.gastown/docker/docker-compose.override.yml"
bin/harness build --target gastown --dir "$TMPD" --manifest "$MAN" --quiet
if grep -q "USER EDIT" "$TMPD/.gastown/docker/docker-compose.override.yml"; then
  ok "override is create-once (preserved)"; else no "override is create-once (preserved)"; fi
# idempotency with docker_env on
out="$(bin/harness build --target gastown --dir "$TMPD" --manifest "$MAN" 2>&1)"
if printf '%s' "$out" | grep -qE '^(created|updated) '; then
  no "docker build idempotent" "$out"; else ok "docker build idempotent"; fi
rm -rf "$TMPD" "$MAN"

echo
echo "result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
