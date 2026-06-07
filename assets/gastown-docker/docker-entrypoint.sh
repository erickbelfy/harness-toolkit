#!/usr/bin/env bash
# Gastown sandbox entrypoint: set the container's git identity from the
# environment, mark /gt safe, then exec the container command.
set -euo pipefail

git config --global user.name  "${GIT_USER:-TestUser}"        || true
git config --global user.email "${GIT_EMAIL:-test@example.com}" || true
git config --global --add safe.directory /gt                   || true

exec "$@"
