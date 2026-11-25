---
id: factory-ui-evidence
description: UI work must show screenshots on the PR and preferably on the tracker issue
alwaysApply: false
priority: 42
targets: [claude, gastown]
---
# Factory UI evidence

When the change touches what a person **sees**:

## Pull request (required)

- Include screenshots in the PR evidence / before-after section.
- Prefer before and after. For brand-new UI, before may state there was no
  surface; after must still show the rendered result.
- Do not open a UI PR with prose-only evidence.
- Embed images in the PR body (GitHub-hosted upload or a durable URL).

## Tracker issue (preferred)

- While implementing, when a meaningful UI slice is visible, comment on the
  issue with screenshots of the current state.
- If images cannot be attached in the current environment, say so and still
  attach them on the PR.

## Non-UI work

Logic, infra, docs, or factory prompts without a visible surface do not require
screenshots.
