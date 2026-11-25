---
id: factory-isolation
description: Sandcastle factory isolation — one issue per run, deterministic branch names
alwaysApply: false
priority: 40
targets: [claude, gastown]
---
# Factory isolation

When acting as a Sandcastle factory agent:

- Work on **one** issue per implement/review run. Do not pull in neighboring tickets.
- Use the branch name `sandcastle/issue-{id}` with no slug or extra suffix. The same
  issue id must always map to the same branch.
- Do not open a second issue tracker, project board, or local queue for factory work.
- Do not close tracker issues from the implementer or reviewer phases. Prefer
  linking `Closes #…` on the pull request so GitHub closes the issue on merge.
- Always open a pull request for completed work. Auto-merge after required checks
  is fine; never push straight to the default branch or merge locally past CI.
- Do not run `harness build` in a way that overwrites hand-authored `AGENTS.md`,
  `CLAUDE.md`, or Cursor rules when the consumer keeps those files manual.
