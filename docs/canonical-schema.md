# Canonical Schema Reference

Field-by-field reference for each artifact category. `req` = required.
Unknown fields are ignored (not an error). See `authoring-guide.md` for examples.

## Manifest — `harness.toml`

```toml
[project]          name = "..."
[targets.<name>]   enabled = true|false   out = "."   # gastown also: beads_mode = "jsonl"|"script"
[mappings]         <category> = ["target", ...]       # default targets per category
```
Targets: `agentsmd`, `claude`, `cursor`, `gastown`.

## rules
| field | req | type | notes |
|-------|-----|------|-------|
| `id` | – | string | defaults to filename; used for output names/headings |
| `description` | – | string | used as Cursor rule description |
| `globs` | – | string | comma list, **unquoted in output** (Cursor auto-attach) |
| `alwaysApply` | – | bool | Cursor "Always" mode (default false) |
| `priority` | – | int | concat order, ascending (default 50) |
| `targets` | – | list | override category mapping |

## agents
| field | req | type | notes |
|-------|-----|------|-------|
| `name` | ✓ | string | output filename / role key |
| `description` | ✓ | string | routing hint / role summary |
| `tools` | – | list | Claude subagent tool allowlist (emitted comma-joined) |
| `skills` | – | list | referenced skill names; **validated** against `harness/skills` |
| `model` | – | string | `sonnet\|opus\|haiku\|inherit\|<id>`; omitted if `inherit` |
| `gastown_role` | – | string | label → `roles.json` `preset` |
| `targets` | – | list | override mapping |

The generator appends a `## Skills` section built from each referenced skill's
`name` + `description` — do not duplicate skill content in the body.

## commands
| field | req | type | notes |
|-------|-----|------|-------|
| `name` | ✓ | string | output filename / command name |
| `description` | ✓ | string | emitted as Claude command frontmatter |
| `targets` | – | list | override mapping |

## skills (Agent Skills spec) — `<category>/<name>/SKILL.md`
| field | req | type | notes |
|-------|-----|------|-------|
| `name` | ✓ | string | ≤64, lowercase/digits/hyphen, **must equal dir name** |
| `description` | ✓ | string | ≤1024, "what + when" |
| `license` | – | string | |
| `compatibility` | – | string | ≤500 |
| `metadata` | – | map | arbitrary string→string |
| `allowed-tools` | – | string | space-separated (experimental) |

Bundled non-frontmatter dirs (`references/`, `scripts/`, `assets/`) are copied
verbatim.

## hooks
| field | req | type | notes |
|-------|-----|------|-------|
| `id` | – | string | defaults to filename |
| `event` | ✓ | string | Claude event vocabulary (see below) |
| `matcher` | – | string | tool matcher (e.g. `Edit\|Write`); omitted if empty |
| `type` | – | string | handler type (default `command`) |
| `command` | – | string | command to run; `${CLAUDE_PROJECT_DIR}` supported |
| `timeout` | – | int | seconds |
| `git_hook` | – | string | also emit `.harness/git-hooks/<name>` shim |
| `targets` | – | list | override mapping |

Gastown event map: `SessionStart→sessionStart`, `SessionEnd→sessionEnd`,
`UserPromptSubmit→userPromptSubmitted`, `PreToolUse→preToolUse`. Others dropped
for Gastown.

## mcp
| field | req | type | notes |
|-------|-----|------|-------|
| `name` | ✓ | string | server key in `mcpServers` |
| `transport` | – | string | `stdio` (default) or `http` |
| `command` | stdio | string | executable |
| `args` | – | list | stdio args |
| `env` | – | map | stdio env (values may use `${VAR}`) |
| `url` | http | string | endpoint |
| `headers` | – | map | http headers |
| `targets` | – | list | override mapping |

## memory
| field | req | type | notes |
|-------|-----|------|-------|
| `id` | – | string | defaults to filename |
| `kind` | ✓ | string | `beads` (others ignored for now) |
| `beads` | ✓ | list of maps | each: `title` (req), `priority` (int), `type` |
| `targets` | – | list | override mapping (typically `[gastown]`) |
