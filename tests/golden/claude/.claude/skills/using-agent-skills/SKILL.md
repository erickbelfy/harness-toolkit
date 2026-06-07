---
name: using-agent-skills
description: Discover and invoke the right agent skill for the task. Use at the start of a session or whenever you need to decide which skill applies. This is the meta-skill that governs how all other skills in this toolkit are selected and used.
license: MIT
metadata:
  discipline: meta
  reference: addyosmani/agent-skills/using-agent-skills
---
# Using Agent Skills

Before doing non-trivial work, check whether a skill applies and use it. Skills
encode how we work; skipping them is how quality drifts.

## Skill selection by phase
Match the task's phase to a skill (skills available in this toolkit):

- **Plan** — `project-management`: break goals/specs into ordered, verifiable
  tasks before building.
- **Design** — `software-architecture`: boundaries, contracts, trade-offs, ADRs.
- **Implement** —
  - `backend-python` for Python services/APIs/data/jobs.
  - `ui-engineering` for components, state, accessibility, responsive UIs.
- **Verify** — `tdd`: red-green-refactor; reproduce bugs before fixing.
- **Review** — `code-review-and-quality`: five-axis review before merge.

Several skills often apply in sequence for one feature (plan → design →
implement → verify → review). Follow each skill's steps in order; do not skip
verification.

## Core operating principles (non-negotiable)
These hold across every skill:

1. **Be honest; no sycophancy.** Tell the truth on every input, including when it
   is unwelcome. Don't flatter or agree reflexively; praise only what's earned.
   (See the global `honesty` rule.)
2. **Surface assumptions.** State your assumptions explicitly before implementing
   anything non-trivial.
3. **Manage confusion actively.** Stop and clarify conflicting or unclear
   requirements rather than guessing.
4. **Push back when warranted.** Flag technical problems directly, with concrete
   downsides and a better alternative.
5. **Enforce simplicity.** Resist overcomplication; prefer the obvious solution.
6. **Maintain scope discipline.** Change only what the task requires.
7. **Verify, don't assume.** "Done" requires evidence — passing tests or observed
   runtime behavior, not assertion.

## Selection rules
- Check for an applicable skill before starting work.
- When uncertain and the task is non-trivial, start with `project-management`
  (plan) or `software-architecture` (design) before coding.
- Specialist agents (ui-engineer, backend-engineer, software-architect,
  project-manager, software-engineer) already carry their discipline skills —
  let them drive their part and coordinate the handoffs.
