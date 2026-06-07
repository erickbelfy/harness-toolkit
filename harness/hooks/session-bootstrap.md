---
id: session-bootstrap
event: SessionStart
type: command
command: "${CLAUDE_PROJECT_DIR}/.harness/hooks/session-info.sh"
timeout: 10
targets: [claude, gastown]
---
Prints a short repo summary at session start so the agent has immediate context.
Maps to Gastown's `sessionStart` event.
