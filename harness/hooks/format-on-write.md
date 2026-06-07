---
id: format-on-write
event: PostToolUse
matcher: "Edit|Write"
type: command
command: "${CLAUDE_PROJECT_DIR}/.harness/hooks/format.sh"
timeout: 30
git_hook: pre-commit
---
Runs the project formatter after any file write so generated edits stay
consistent with the repo's style. The referenced script is copied to
`.harness/hooks/` in the target project.
