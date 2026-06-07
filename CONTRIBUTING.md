# Contributing

Thanks for working on harness-toolkit. This document captures how we make changes.

## Workflow: a PR per iteration

`main` is protected — never push to it directly. Every change lands via a pull
request:

1. Branch off the latest `main`.
2. Make the change; keep it focused and reversible.
3. Run the local checks (below) and refresh goldens if output changed.
4. Commit using the conventions below; push the branch.
5. Open a PR into `main`. CI must pass before merge.

### Branch naming
`<type>/<short-kebab-summary>`, where `<type>` is one of:

| Type | Use for |
|------|---------|
| `feat` | new capability (generator, artifact field, skill, agent) |
| `fix` | bug fix |
| `docs` | documentation only |
| `refactor` | behavior-preserving code change |
| `test` | tests / fixtures only |
| `chore` | tooling, CI, deps, housekeeping |

Examples: `feat/windsurf-target`, `fix/cursor-globs-quoting`, `docs/beads-modes`.

### Commit messages
[Conventional Commits](https://www.conventionalcommits.org): `type: imperative
summary`, optional body explaining *why*. Co-authored commits keep the trailer:

```
feat: add windsurf target

Windsurf reads AGENTS.md plus its own rules dir; add a generator and mapping.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

## Local development

Edit the canonical source under `harness/` (never edit generated output). Then:

```sh
harness validate                 # frontmatter, required fields, dangling refs
harness build --dir /tmp/out     # generate into a scratch dir and inspect
bash tests/run.sh                # zero-dependency test runner (unit + golden + idempotency)
```

Optional tools sharpen things but are not required locally (CI runs them):
`jq` (in-place JSON merge), `bats` (unit tests), `shellcheck` (lint),
`skills-ref` (deep skill validation). Run `harness doctor` to see what's present.

## Tests and golden fixtures

- `tests/run.sh` — zero-dep runner; use it locally.
- `tests/bats/` — the same units for CI.
- `tests/golden/<target>/` — expected generator output, committed.

When a change **intentionally** alters generated output, refresh and review:

```sh
bash tests/golden.sh             # regenerate fixtures
git diff -- tests/golden         # review every change before committing
```

CI fails if goldens are stale, so always commit the refresh with the change.

## Invariants (do not break)

See [docs/internals.md](docs/internals.md) for the full list. The critical ones:

1. **No pipes into `emit_write`** — use process substitution
   (`emit_write "$p" < <(printf …)`); a pipe runs it in a subshell and loses the
   change counters.
2. **Builds are idempotent** — a second `build` with no source change writes nothing.
3. **awk is the default contract** — everything works without `jq`/`yq`; never
   clobber a divergent JSON file without `jq` (write a `*.harness.json` fragment).
4. **Cursor `globs` are emitted unquoted** — quoting silently breaks matching.
5. **Generators end cleanly** (`return 0`) so `set -e` doesn't abort the build.
6. **Files are LF** (enforced by `.gitattributes`) and scripts keep their `+x` bit.

## Adding things

- **A new artifact field** — parse it in the relevant generator, document it in
  `docs/canonical-schema.md` + `docs/authoring-guide.md`, add/adjust a fixture,
  refresh goldens.
- **A new target** — add `generators/<target>.sh` defining `gen_<target>`, register
  it in `harness.toml` (`[targets.<target>]` + `[mappings]`) and `ALL_TARGETS` in
  `bin/harness`, add a golden fixture, document it in `docs/targets.md`.
- **A new skill/agent** — follow the patterns in `harness/skills/` and
  `harness/agents/`; agents reference skills via `skills:` (validated) and the
  `## Skills` section is generated — don't duplicate skill content in personas.
