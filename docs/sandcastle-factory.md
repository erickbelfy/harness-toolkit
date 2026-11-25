# Sandcastle factory (with harness)

How to use this toolkit as the **instruction** layer next to
[Sandcastle](https://github.com/mattpocock/sandcastle) (`@ai-hero/sandcastle`) as
the **orchestrator**.

Gastown is a different orchestrator. For this factory pattern, leave
`[targets.gastown]` disabled (and `docker_env = false`). Do not treat beads or
`.gastown/docker` as the queue.

## Layers

| Layer | Role |
|-------|------|
| **harness** (`harness/` + optional `harness build`) | Rules, personas, skills — what agents should obey |
| **Sandcastle** (`.sandcastle/` in the consumer) | Plan → implement → review → open PR loop, sandboxes, branches |
| **Hand-authored guides** (`AGENTS.md`, `.cursor/rules`, …) | Optional; keep them if the team already edits them by hand |

This toolkit does **not** ship a Sandcastle generator target. Consumer repos own
`.sandcastle/main.mts` and the prompt markdown files. Bundled factory personas
and the `sandcastle-factory` skill are the shared starting point.

## Bundled factory artifacts

| Path | Purpose |
|------|---------|
| `harness/agents/factory-planner.md` | Queue analysis + `<plan>` output |
| `harness/agents/factory-implementer.md` | Single-issue implementation |
| `harness/agents/factory-reviewer.md` | Same-branch review after commits |
| `harness/agents/factory-merger.md` | Open PRs for completed branches (auto-merge after CI ok) |
| `harness/rules/factory-isolation.md` | One issue per run; `sandcastle/issue-{id}` |
| `harness/rules/factory-ui-evidence.md` | Screenshots on UI PRs; prefer images on the issue |
| `harness/skills/engineering/sandcastle-factory/SKILL.md` | Loop + consumer layout contract |

## Consumer that already has AGENTS / Cursor rules

If the project already maintains agent guides by hand:

1. Copy or adapt the factory agents/rules/skill into the project's own `harness/`.
2. Set every `[targets.*] enabled = false` in that project's `harness.toml` (or
   never run `harness build` there).
3. Point Sandcastle prompts at the local personas, for example
   `@harness/agents/factory-implementer.md`.
4. Keep coding standards in `.sandcastle/CODING_STANDARDS.md` (and optionally
   thin factory rules under `harness/rules/`).

Do **not** run `harness build` over existing `AGENTS.md` / `.cursor/rules` /
`CLAUDE.md` unless you intentionally switch to generated-owned files (and
gitignore the outputs).

## Consumer starting from this toolkit only

```sh
cd my-project
harness init
# Disable gastown (and any target you do not want) in harness.toml
harness add agent factory-planner   # or copy from the toolkit tree
# Scaffold .sandcastle via the Sandcastle docs / init, then wire prompts
```

Still prefer Sandcastle for the AFK loop. Use Gastown only if you deliberately
choose that orchestrator instead.

## Syncing generics into a product repo

There is no required submodule. Refresh product personas by copying the
toolkit files and re-applying product-specific anchors (lint commands, UI stack,
delivery rules). Document the sync step in the product README.

## Related docs

- [authoring-guide.md](authoring-guide.md) — writing harness artifacts
- [targets.md](targets.md) — what each generator emits
- [gastown-docker.md](gastown-docker.md) — Gastown sandbox (not used by this factory)
