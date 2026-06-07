#!/usr/bin/env bats
# Unit tests for lib/frontmatter.sh

setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  # shellcheck source=../../lib/common.sh
  source "$ROOT/lib/common.sh"
  # shellcheck source=../../lib/frontmatter.sh
  source "$ROOT/lib/frontmatter.sh"
  FIX="$(mktemp -d)"
  cat >"$FIX/a.md" <<'EOF'
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
Body line 1
Body line 2
EOF
  cat >"$FIX/nofm.md" <<'EOF'
no frontmatter here
just body
EOF
}

teardown() { rm -rf "$FIX"; }

@test "fm_get strips double quotes" {
  run fm_get "$FIX/a.md" description
  [ "$output" = "a quoted value" ]
}

@test "fm_get preserves comma-list scalar" {
  run fm_get "$FIX/a.md" globs
  [ "$output" = "*.ts,*.tsx" ]
}

@test "fm_get_list parses inline flow list" {
  run fm_get_list "$FIX/a.md" tools
  [ "${lines[0]}" = "Read" ]
  [ "${lines[1]}" = "Grep" ]
  [ "${lines[2]}" = "Glob" ]
}

@test "fm_get_list unquotes inline items with spaces" {
  run fm_get_list "$FIX/a.md" args
  [ "${lines[0]}" = "-y" ]
  [ "${lines[1]}" = "pkg name" ]
}

@test "fm_get_list parses block sequence" {
  run fm_get_list "$FIX/a.md" block
  [ "${lines[0]}" = "one" ]
  [ "${lines[1]}" = "two" ]
}

@test "fm_has true for present key, false for absent" {
  run fm_has "$FIX/a.md" id;     [ "$status" -eq 0 ]
  run fm_has "$FIX/a.md" nope;   [ "$status" -ne 0 ]
}

@test "fm_body returns markdown after fence" {
  run fm_body "$FIX/a.md"
  [ "${lines[0]}" = "Body line 1" ]
  [ "${lines[1]}" = "Body line 2" ]
}

@test "fm_raw fails when no frontmatter fence" {
  run fm_raw "$FIX/nofm.md"
  [ "$status" -ne 0 ]
}

@test "fm_body returns whole file when no frontmatter" {
  run fm_body "$FIX/nofm.md"
  [ "${lines[0]}" = "no frontmatter here" ]
}
