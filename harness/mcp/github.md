---
name: github
transport: stdio
command: npx
args: ["-y", "@modelcontextprotocol/server-github"]
env:
  GITHUB_TOKEN: "${GITHUB_TOKEN}"
---
GitHub MCP server providing repository, issue, and pull-request tools.
Requires a `GITHUB_TOKEN` environment variable with repo scope.
