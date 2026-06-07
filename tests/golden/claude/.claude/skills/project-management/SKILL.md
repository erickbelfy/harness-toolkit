---
name: project-management
description: Turn goals and specs into ordered, verifiable work. Use to break large or vague work into implementable tasks, sequence them by dependency, define acceptance criteria, plan parallelizable streams, and track delivery. Optimizes for small reversible steps and a system that always works.
license: MIT
metadata:
  discipline: delivery
  reference: addyosmani/agent-skills/planning-and-task-breakdown
---
# Project Management

Decompose work into small, independently verifiable tasks with explicit
acceptance criteria, ordered so the system stays working after every step.

## When to use
- You have a spec or clear goal that needs breaking into work.
- A task feels too large or vague to start.
- Work could be parallelized across streams or agents.
- You need to communicate scope, sequence, or status to others.

**When not to use**: trivial single-file changes with an obvious path.

## The process

1. **Understand first.** Read the spec and relevant code read-only. Identify
   existing patterns, dependencies, risks, and unknowns.
2. **Map the dependency graph.** What must exist before what. Plan bottom-up:
   foundations before the things that use them.
3. **Slice vertically.** Each task delivers one complete, testable path
   (data→logic→surface), not a horizontal layer. Avoid "all DB, then all API".
4. **Write each task** with: description, testable acceptance criteria,
   verification steps, dependencies, files touched, and a size estimate.
5. **Order and checkpoint.** Satisfy dependencies first; tackle high-risk items
   early; leave the system working after each task; add a checkpoint every 2–3.

## Task sizing
- XS (1 file/one function) → XL (8+ files = too big, break it down).
- Aim for S/M. Break down further if it would take 2+ hours, has >3 acceptance
  bullets, spans independent subsystems, or has "and" in its title.

## Parallelization
- Safe in parallel: independent vertical slices, docs.
- Needs sequencing: migrations, shared-state changes.
- Needs coordination: tasks sharing an API contract (agree the contract first).

## Red flags
- No written task list, or vague/untestable acceptance criteria.
- Missing verification steps; everything sized XL; no checkpoints.
- Unordered dependencies; horizontal slicing; "big bang" tasks.

## Verification checklist
- [ ] Every task has testable acceptance criteria and verification steps.
- [ ] Dependencies are correct and tasks are ordered to satisfy them.
- [ ] Tasks are vertically sliced and reasonably sized (mostly S/M).
- [ ] Checkpoints leave the system working.
- [ ] Risks and open questions are listed; high-risk work is early.
