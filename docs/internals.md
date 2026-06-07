# Internals (codebase walkthrough)

For contributors. How the pieces fit and the invariants to preserve.

## Execution flow
`bin/harness <cmd>` →
1. resolves `HARNESS_ROOT` (follows the install symlink),
2. sources `lib/*.sh`,
3. parses global flags + subcommand,
4. `resolve_paths` sets **source** (`./harness` or bundled), **manifest**, **out**,
5. dispatches to a `cmd_*` function.

`cmd_build` loops the manifest's enabled targets, sources `generators/<t>.sh`, and
calls `gen_<t>`. Generators run **in the harness shell scope**, so they can use all
helpers defined in `bin/harness` and `lib/`.

## `bin/harness` — CLI + shared helpers
Subcommand dispatch plus helpers every generator relies on:
- `list_artifacts <cat>` — files for a category (skills = `SKILL.md` dirs).
- `artifact_id <file> <cat>` — canonical id/name for output paths.
- `artifact_targets` / `target_selected` — resolve per-artifact target binding
  (frontmatter `targets:` overrides `[mappings]`).
- `skill_file` / `skill_desc` / `agent_skills_section` — pull skill metadata so
  agents auto-render a `## Skills` block (single source of truth).
- `humanize` — slug → Title Case for headings.
- `cmd_validate` — frontmatter parses, required fields, Agent-Skills name rules,
  duplicate ids, dangling `skills:` references; non-zero exit on error.

## `lib/` — sourced libraries (all idempotent on source via include-guards)
- **common.sh** — logging (`info/warn/err/debug/die`), `has_cmd`, verbosity/dry-run
  globals, `HARNESS_ROOT`.
- **frontmatter.sh** — zero-dep awk YAML-subset parser:
  `fm_raw`, `fm_body`, `fm_get`, `fm_has`, `fm_get_list` (inline `[a,b]` + block
  `- a`), `fm_get_map` (block maps). Nested list-of-maps (beads) is parsed
  separately in `gastown.sh`.
- **manifest.sh** — minimal TOML reader: `manifest_get`, `manifest_list`,
  `manifest_sections`, `manifest_target_enabled/out`, `manifest_mapping`.
- **emit.sh** — `emit_write` (atomic, idempotent, dry-run aware; bumps
  EMIT_* counters), `emit_copy_tree`, `json_escape`, `json_str`.
- **json.sh** — JSON builders (`json_arr_from_lines`, `json_obj_from_tsv`) and the
  shared `.mcp.json` writer (`mcp_server_value`, `mcp_servers_object`,
  `write_mcp_json`) with the jq/awk merge-safety logic.

## `generators/` — one `gen_<target>()` each
`agentsmd.sh`, `claude.sh`, `cursor.sh`, `gastown.sh`. Each reads the canonical
source via the helpers and writes via `emit_write`. Format details live in
`docs/targets.md`.

## `harness/` — canonical source (the data, not code)
`rules/ agents/ commands/ skills/{engineering,productivity,misc}/ hooks/{,scripts/}
mcp/ memory/`. This is what you edit and commit.

## `tests/`
- **run.sh** — zero-dependency runner (no bats/jq needed): unit checks for
  frontmatter + json, golden-file diffs, idempotency. Use locally.
- **bats/** — the same units as bats tests for CI.
- **golden/<target>/** — expected output; **golden.sh** regenerates them.
- Refresh goldens after an intentional output change: `bash tests/golden.sh`, then
  review the diff before committing. CI fails if goldens are stale.

## Invariants (don't break these)
1. **No pipes into `emit_write`.** A pipeline runs the right side in a subshell, so
   the EMIT_* counters are lost. Use process substitution:
   `emit_write "$p" < <(printf ...)`, not `printf ... | emit_write "$p"`.
2. **Builds are idempotent.** `emit_write` content-compares; the JSON writers
   short-circuit when the file already equals a clean generate.
3. **awk is the default contract.** `jq`/`yq` are optional fast/safe paths only;
   everything must work without them (CI proves the `without-jq` path).
4. **Never clobber a divergent JSON file without jq** — write a `*.harness.json`
   fragment and warn instead.
5. **Generators end cleanly** (return 0). A trailing failing command under
   `set -e` aborts the whole build (see the `_cursor_skips` fix).
6. **Cursor `globs` are unquoted.** Quoting silently breaks matching.
