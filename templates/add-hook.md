---
id: {{NAME}}
event: PostToolUse
matcher: "Edit|Write"
type: command
command: "${CLAUDE_PROJECT_DIR}/.harness/hooks/{{NAME}}.sh"
timeout: 30
targets: [claude]
---
TODO — what this hook does. Put the script at harness/hooks/scripts/{{NAME}}.sh.
Valid events: SessionStart, SessionEnd, UserPromptSubmit, PreToolUse, PostToolUse,
Stop (only SessionStart/SessionEnd/UserPromptSubmit/PreToolUse map to Gastown).
