---
name: changelog
description: Generate a changelog entry from the staged diff. Use when cutting a release or finishing a feature.
---
Summarize the staged git diff into a Keep a Changelog entry under `[Unreleased]`.

Steps:
1. Run `git diff --staged` and read the changes.
2. Group them under Added / Changed / Fixed / Removed.
3. Write user-facing, present-tense bullet points (not commit messages).
4. Output only the markdown block, ready to paste into CHANGELOG.md.
