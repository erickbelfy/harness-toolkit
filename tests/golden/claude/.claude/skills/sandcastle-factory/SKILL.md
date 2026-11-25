---
name: sandcastle-factory
description: Orchestrate parallel AI coding via Sandcastle (plan → implement → review → open PR). Use when running or authoring an autonomous software factory with @ai-hero/sandcastle, not Gastown.
license: MIT
metadata:
  category: engineering
  discipline: factory
---
# Sandcastle factory

Sandcastle (`@ai-hero/sandcastle`) is the **orchestrator**. Harness content
(rules, agents, skills) is the **instruction** layer. Gastown is a different
orchestrator — leave it off for this factory pattern.

## Loop

1. **Plan** — read the open queue, build dependencies, emit unblocked issues with
   branches `sandcastle/issue-{id}`. Skip issues that already have an open PR on
   that head (CI / auto-merge in flight).
2. **Implement + review** — per issue, one sandbox/branch; implementer then reviewer
   when commits exist. Cap concurrency to protect API limits.
3. **Pull requests** — one agent opens a PR per completed branch. Auto-merge after
   green checks is allowed; landing without a PR is not. UI PRs require
   screenshots; progress images on the issue are preferred (`factory-ui-evidence`).
4. Repeat until the queue is empty or a max iteration cap is hit.

## Consumer layout

```
harness/                 # personas + factory rules (commit these)
.sandcastle/
  main.mts               # orchestration loop
  plan-prompt.md
  implement-prompt.md
  review-prompt.md
  merge-prompt.md
  CODING_STANDARDS.md
harness.toml             # may keep generation targets disabled
```

Prompts live in the consumer. Toolkit agents/skills are copied or adapted into
the consumer's `harness/`. Wire prompts with `@harness/agents/...` references.

## Hand-authored agent guides

If the project already maintains `AGENTS.md`, `.cursor/rules`, or `CLAUDE.md` by
hand, keep generation targets off in `harness.toml` and **do not** run
`harness build` over those files. Use `harness/` only for factory personas and
rules that Sandcastle prompts load.

## Queue contract

The consumer defines the queue (GitHub Issues + label, project board, etc.).
Factory agents must not invent a second tracker. Specs and human delivery docs
may live elsewhere (for example `.scratch/`) and are not the factory queue
unless the plan prompt says so.
