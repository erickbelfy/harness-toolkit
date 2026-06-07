# harness-toolkit

Author your AI-agent configuration **once**, generate it for **every agent**.

`harness` keeps rules, agent personas, commands, skills, hooks, MCP servers, and
orchestrator memory in one canonical markdown source and generates valid,
per-agent config for:

| Target | What it generates |
|--------|-------------------|
| **agentsmd** | `AGENTS.md` (the cross-tool standard — Codex, Copilot, Windsurf, Amp, Devin, …) |
| **claude** | `CLAUDE.md`, `.claude/agents/`, `.claude/commands/`, `.claude/skills/`, `.mcp.json`, `.claude/settings.json` hooks |
| **cursor** | `.cursor/rules/*.mdc` (and reuses `AGENTS.md`) |
| **gastown** | `.gastown/roles.json` + role prompts, `.github/hooks/gastown.json`, `.mcp.json`, `.beads/issues.jsonl` |

It is **shell + markdown only** — no Node/Python build step. Skills follow the
[Agent Skills specification](https://agentskills.io/specification).

## Why

Every agent reads config in its own format, so the same guidance gets copied into
`.claude/`, `.cursor/`, `AGENTS.md`, and orchestrator files — and drifts. Here you
edit one source of truth and run `harness build`.

## Install

```sh
git clone <this-repo> harness-toolkit
cd harness-toolkit
./install.sh            # symlinks bin/harness into ~/.local/bin
harness doctor          # check optional deps (jq/yq/bd/skills-ref)
```

`jq` is optional — without it the toolkit uses a built-in awk JSON writer and
falls back to writing a `*.harness.json` fragment (instead of clobbering) when a
hand-edited `.mcp.json`/`settings.json` already exists.

## Quickstart

Use the toolkit's bundled content, or start your own in any project:

```sh
cd my-project
harness init                 # scaffold ./harness/ + harness.toml
harness add rule my-style    # scaffold an artifact from a template
harness add agent my-bot
harness validate             # check everything parses and is well-formed
harness build                # generate per-agent files into this project
```

Generated files land in the project root and under `.claude/`, `.cursor/`, etc.
**Git-ignore them in the target project** (see `.gitignore`) — the canonical
`harness/` source is what you commit.

## Commands

| Command | Description |
|---------|-------------|
| `harness init` | Scaffold a `harness/` tree + `harness.toml` (Gastown docker sandbox enabled) in the current dir |
| `harness build` (alias `sync`) | Generate all enabled targets |
| `harness diff` | Dry run — show what `build` would change |
| `harness validate` | Check frontmatter, required fields, name rules, dangling refs |
| `harness list [category]` | List artifacts and their target mappings |
| `harness add <type> <name>` | Scaffold a new artifact from a template |
| `harness doctor` | Report optional-dependency availability |

Global flags: `--dir <path>` (output dir), `--source <path>` (canonical source),
`--manifest <path>`, `--target <name>`, `--dry-run`, `--verbose`, `--quiet`.

## How it resolves source vs. output

- **Canonical source**: `./harness/` if present in the current project, otherwise
  the toolkit's bundled `harness/`. Override with `--source`.
- **Manifest**: the `harness.toml` next to the source, else the bundled one.
- **Output**: the current directory (or `--dir`).

So you can run `harness build` inside any project to refresh that project's agent
files from either its own `harness/` or the shared toolkit content.

## Repo layout

```
bin/harness          CLI entrypoint (subcommand dispatch + shared helpers)
lib/                 sourced libraries (frontmatter, manifest, emit, json, common)
generators/          one per target: agentsmd.sh claude.sh cursor.sh gastown.sh
harness/             CANONICAL SOURCE: rules agents commands skills hooks mcp memory
templates/           scaffolds used by `harness add`
tests/               run.sh (zero-dep), bats/, golden/, golden.sh
docs/                authoring guide, schema, targets, internals
harness.toml         manifest: enabled targets + category→target mappings
```

## Documentation

- [docs/authoring-guide.md](docs/authoring-guide.md) — how to write each artifact.
- [docs/canonical-schema.md](docs/canonical-schema.md) — frontmatter reference.
- [docs/targets.md](docs/targets.md) — what each target emits + format gotchas.
- [docs/internals.md](docs/internals.md) — codebase walkthrough for contributors.
- [docs/gastown-docker.md](docs/gastown-docker.md) — opt-in Gastown Docker sandbox (isolated container + web dashboard).

## Bundled content

Specialist **skills** (Agent Skills spec) and composing **agent roles** for use in
Gastown and Claude: `ui-engineer`, `software-architect`, `project-manager`,
`backend-engineer`, and a composite `software-engineer`; plus `tdd`,
`code-review-and-quality`, and the `using-agent-skills` meta-skill. A global
**honesty / no-sycophancy** rule applies across all targets. Skill content draws
on the [Agent Skills](https://agentskills.io) and
[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) catalogs.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — branch/commit conventions, the per-PR
workflow, local checks, golden-fixture refresh, and the invariants to preserve.

## License

See [LICENSE](LICENSE).
