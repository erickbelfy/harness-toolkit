# Gastown sandbox image — adapted from gastownhall/gastown's Dockerfile.
#
# Builds Gastown from source at a pinned ref so any project can run the sandbox
# with no external checkout. This is BEST-EFFORT and UNVERIFIED here (we have no
# Docker in CI) — Gastown is experimental and its build may change. Verify the
# build against your Gastown version and adjust as needed; bump GASTOWN_REF to a
# release tag for reproducibility.
FROM docker/sandbox-templates:claude-code

ARG GASTOWN_REF=main
ARG GO_VERSION=1.25.8
ARG DOLT_VERSION=2.0.7

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Toolchain matching Gastown's image: git, build tools, sqlite, and utilities.
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential ca-certificates curl git gnupg sqlite3 \
      tmux ripgrep zsh netcat-openbsd vim tini \
    && rm -rf /var/lib/apt/lists/*

# Go toolchain.
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
      | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:/root/go/bin:/usr/local/bin:${PATH}"

# Dolt — the versioned SQL backend that beads uses.
RUN curl -fsSL "https://github.com/dolthub/dolt/releases/download/v${DOLT_VERSION}/dolt-linux-amd64.tar.gz" \
      | tar -C /usr/local --strip-components=1 -xz dolt-linux-amd64/bin/dolt

# Build Gastown (the `gt` CLI) from source at the pinned ref.
RUN git clone --depth 1 --branch "${GASTOWN_REF}" \
      https://github.com/steveyegge/gastown /opt/gastown \
    && make -C /opt/gastown build \
    && (install -m 0755 /opt/gastown/bin/* /usr/local/bin/ 2>/dev/null || true)

# beads (`bd`) — install if not already provided by the Gastown build.
RUN command -v bd >/dev/null 2>&1 || \
      go install github.com/gastownhall/beads/cmd/bd@latest || true

WORKDIR /gt
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# tini reaps zombies; the entrypoint sets git identity then runs CMD.
ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
