---
name: code-review-and-quality
description: Conduct multi-axis code review. Use before merging any change, and when reviewing code written by yourself, another agent, or a human. Assesses correctness, readability, architecture, security, and performance, and categorizes findings by severity.
license: MIT
metadata:
  discipline: quality
  reference: addyosmani/agent-skills/code-review-and-quality
---
# Code Review and Quality

Review honestly and specifically. The goal is improving code health, not
approval theatre — flag real problems directly, and never wave through work to be
agreeable.

## When to use
- Before merging any change.
- Reviewing code from yourself, another agent, or a human.
- Assessing quality across dimensions before code enters the main branch.

## The five axes
1. **Correctness** — Does it meet requirements? Are edge cases and error paths
   handled? Any off-by-one, race, or data-loss risk?
2. **Readability & simplicity** — Can another engineer understand it unaided? Is
   there a simpler equivalent?
3. **Architecture** — Does it fit the system design and respect boundaries? Any
   new coupling, cycles, or leaks?
4. **Security** — Input validation, authz, secrets, injection, unsafe defaults?
5. **Performance** — N+1 queries, unbounded loops/allocations, missing
   pagination, needless work on hot paths?

## Change sizing
- ~100 lines: ideal, fully reviewable.
- ~300 lines: acceptable for one logical change.
- ~1000+ lines: ask for a split before reviewing.

## Process
1. Understand the context and intent (what problem, what success looks like).
2. Review the tests first — do they prove the change and cover edge cases?
3. Review the implementation across the five axes.
4. Categorize every finding by severity (below).
5. Verify the verification story: was it actually run/tested? Demand evidence.

## Severity labels
| Label | Meaning |
|-------|---------|
| *(none)* | Required change before merge. |
| **Critical** | Blocks merge; correctness/security risk. |
| **Optional / Consider** | Worth doing; not required. |
| **Nit** | Minor; author may ignore. |
| **FYI** | Informational only. |

## Principles
- Approve only when the change improves overall code health.
- Require cleanup before merge, not "later"; don't accept "I'll fix it after".
- Separate refactoring from feature work.
- Cite `file:line` and give a concrete fix for each finding.
- Be honest about severity — don't inflate nits or downplay real defects to
  manage feelings.

## Verification checklist
- [ ] Reviewed against all five axes.
- [ ] Tests reviewed first and judged sufficient.
- [ ] Findings categorized by severity with file:line and a fix.
- [ ] Verification story confirmed (evidence, not assertion).
- [ ] Net effect on code health is positive.
