# TDD Patterns

## Prove-It (bug fixes)
1. Reproduce: write a test that fails because of the bug.
2. Confirm it fails for the documented reason.
3. Fix the code until the test passes.
4. Keep the test as a regression guard.

## Table-driven tests
Group many input/expected pairs into one parameterized test to cover edge
cases without duplication. Keep each row independent and named.
