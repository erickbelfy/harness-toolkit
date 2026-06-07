# Authoring Guide

Everything you put in `harness/` is **markdown with YAML frontmatter**. Frontmatter
is config; the markdown body is the content. Each generator reads only the fields
it understands and ignores the rest, so one artifact can serve several targets.

Use `harness add <type> <name>` to scaffold any artifact from a template, then edit.

## Targeting: where an artifact goes

By default an artifact is generated for the targets mapped to its category in
`harness.toml` (`[mappings]`). Override per-artifact with a `targets:` list:

```yaml
targets: [claude, gastown]   # only these, regardless of the mapping
```

## Conventions (shared)

- **ids/names** are lowercase, digits, and hyphens (`code-reviewer`), no leading/
  trailing/consecutive hyphens. A skill's `name` must equal its directory name.
- **descriptions** say *what it does and when to use it* — include trigger words.
- Keep bodies focused. For skills, push depth into `references/` (progressive
  disclosure) and keep `SKILL.md` under ~500 lines.

## Rules — `harness/rules/<id>.md`
Guidance/instructions. Concatenated into `CLAUDE.md` and `AGENTS.md` (ordered by
`priority`, ascending) and fanned out to `.cursor/rules/<id>.mdc`.

```yaml
id: typescript-style
description: TypeScript code style and conventions
globs: "*.ts,*.tsx"      # Cursor auto-attach; comma list. Empty = none.
alwaysApply: false        # Cursor "Always" mode when true
priority: 50              # lower sorts first
```

## Agent roles — `harness/agents/<name>.md`
Reusable personas. Become Claude subagents (`.claude/agents/`) and Gastown roles
(`.gastown/roles.json` + a role prompt). Reference skills with `skills:` — the
generator auto-injects a `## Skills` section (name + description pulled from each
skill), so **don't restate skill content in the persona**.

```yaml
name: ui-engineer
description: Frontend UI specialist. Use for components, layouts, a11y, ...
tools: [Read, Write, Edit, Grep, Glob, Bash]
skills: [ui-engineering]   # must reference skills that exist; validated
model: sonnet              # sonnet|opus|haiku|inherit|<id>
gastown_role: specialist   # free-form label → roles.json "preset"
```

## Commands — `harness/commands/<name>.md`
Slash-command prompts. Become `.claude/commands/<name>.md`; in Cursor a manual
(`@name`) rule shim; listed in `AGENTS.md`.

```yaml
name: changelog
description: Generate a changelog entry from the staged diff
```

## Skills — `harness/skills/<category>/<name>/SKILL.md`
Follow the [Agent Skills spec](https://agentskills.io/specification). Copied
verbatim (with `references/`, `scripts/`, `assets/`) into `.claude/skills/<name>/`.
Categories: `engineering`, `productivity`, `misc`.

```yaml
name: ui-engineering            # must equal the directory name
description: Build production-quality UIs. Use when ...
license: MIT
metadata: { discipline: frontend }
allowed-tools: "Bash(git:*) Read"   # optional, experimental
```

## Hooks — `harness/hooks/<id>.md`
Lifecycle hooks. Frontmatter is config; body is documentation. Put the referenced
script under `harness/hooks/scripts/`; it's copied to `.harness/hooks/` in the
target. Merged into `.claude/settings.json` and translated into
`.github/hooks/gastown.json`.

```yaml
id: format-on-write
event: PostToolUse        # canonical = Claude event vocabulary
matcher: "Edit|Write"
type: command
command: "${CLAUDE_PROJECT_DIR}/.harness/hooks/format.sh"
timeout: 30
git_hook: pre-commit      # optional: also emit a .harness/git-hooks shim
```

Only `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreToolUse` map to Gastown;
others (e.g. `PostToolUse`) are dropped for that target with a warning.

## MCP servers — `harness/mcp/<name>.md`
Become `.mcp.json` (`mcpServers`) for Claude and Gastown; a note in `AGENTS.md`.

```yaml
name: github
transport: stdio          # stdio | http
command: npx
args: ["-y", "@modelcontextprotocol/server-github"]
env:
  GITHUB_TOKEN: "${GITHUB_TOKEN}"
# http: url: https://...   headers: { Authorization: "Bearer ${T}" }
```

## Memory / beads — `harness/memory/<id>.md`
Seeds for Gastown's beads tracker. Emitted as `.beads/issues.jsonl` (for
`bd import`) or a `bd create` seed script per `beads_mode` in the manifest. The
Dolt-backed beads DB itself is never written.

```yaml
id: backlog
kind: beads
beads:
  - title: "Wire up CI"
    priority: 1
    type: task
targets: [gastown]
```
