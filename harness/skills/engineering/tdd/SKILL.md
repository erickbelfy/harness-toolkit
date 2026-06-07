---
name: tdd
description: Drive implementation with a strict red-green-refactor loop. Use when implementing logic, fixing a bug, or changing behavior and you want tests to prove correctness.
metadata:
  source: mattpocock/skills
  category: engineering
---
# Test-Driven Development

Follow the red-green-refactor loop. Do not skip steps.

## Loop
1. **Red** — write the smallest failing test that expresses the next desired
   behavior. Run it; confirm it fails for the right reason.
2. **Green** — write the minimum code to make the test pass. No more.
3. **Refactor** — clean up implementation and tests while green. Re-run.

## Rules
- One behavior per test; name tests for the behavior, not the function.
- Never write production code without a failing test demanding it.
- For bug fixes, first write a test that reproduces the bug (the Prove-It pattern).
- Keep the suite fast; mock only true external boundaries.

See `references/patterns.md` for table-driven and Prove-It examples.
