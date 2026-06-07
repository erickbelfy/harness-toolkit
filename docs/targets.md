# Targets

What each generator emits, and the format details/mismatches it handles.

## agentsmd → `generators/agentsmd.sh`
Produces a single root **`AGENTS.md`** (plain markdown, **no frontmatter**):
- rules → prose sections, ordered by `priority`.
- commands → a `## Commands` list (name + description).
- mcp → a `## Tooling (MCP)` human-readable note.

AGENTS.md is read natively by Codex, Copilot, Cursor, Windsurf, Amp, Devin, and
others, so this one file covers many tools.

## claude → `generators/claude.sh`
- rules → **`CLAUDE.md`** (priority-ordered prose).
- agents → **`.claude/agents/<name>.md`** (subagent frontmatter: `name`,
  `description`, `tools` comma-joined, `skills`, `model`; body + auto `## Skills`).
- commands → **`.claude/commands/<name>.md`** (description frontmatter + prompt).
- skills → **`.claude/skills/<name>/`** (verbatim tree copy; spec-validated).
- mcp → **`.mcp.json`** (`mcpServers` map).
- hooks → **`.claude/settings.json`** (`hooks → <Event> → [{matcher, hooks:[…]}]`);
  scripts copied to `.harness/hooks/`; optional `.harness/git-hooks/<name>` shims.

## cursor → `generators/cursor.sh`
- rules → **`.cursor/rules/<id>.mdc`**, one per rule. Frontmatter `description`,
  `globs`, `alwaysApply`. **`globs` is emitted UNQUOTED** as a comma list —
  quoting causes Cursor to silently not match.
- commands → a Manual (`@name`) `.mdc` rule shim (Cursor has no native commands).
- AGENTS.md is owned by the **agentsmd** target (Cursor reads it natively); enable
  agentsmd to get the root file.
- agents / skills / hooks / mcp have no Cursor equivalent → skipped, logged as
  `SKIP target=cursor type=...` (only when explicitly bound to cursor).

## gastown → `generators/gastown.sh`
For Steve Yegge's [Gas Town](https://github.com/steveyegge/gastown) orchestrator.
- agents → **`.gastown/roles/<name>.md`** (persona + auto `## Skills`) and
  **`.gastown/roles.json`** (preset, model, description, skills, prompt path).
- hooks → **`.github/hooks/gastown.json`** with Claude event names translated
  (`SessionStart→sessionStart`, …); unmapped events dropped with a warning.
- mcp → **`.mcp.json`** (shared writer).
- memory → **`.beads/issues.jsonl`** (for `bd import`) or **`.beads/seed.sh`**
  (`bd create` calls), per `beads_mode`. The Dolt-backed beads DB is never written.

> Gastown is experimental and its schema is still moving. These are structured,
> documented interchange artifacts you wire in — review before relying on them.

## Cross-cutting policies
- **Mismatches** never fail the build: unsupported target/type pairs are skipped
  with a `SKIP` log; AGENTS.md never emits YAML; unmapped Gastown events warn.
- **JSON merge safety** (`.mcp.json`, `settings.json`): the file is treated as
  harness-owned when absent or identical to a clean generate (keeps builds
  idempotent). When a *divergent* file exists, `jq` merges it (preserving your
  keys); without `jq`, a `*.harness.json` fragment is written and a warning is
  printed rather than clobbering your file.
- **Idempotency**: every write is content-compared; a second `build` with no
  source changes reports zero changes.
