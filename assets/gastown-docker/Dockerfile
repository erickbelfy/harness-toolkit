# Gastown sandbox image — mirrors gastownhall/gastown's own Dockerfile, with a
# `git clone --branch $GASTOWN_REF` swapped in for their `COPY . /app/gastown`
# so any project can build the sandbox without a local Gastown checkout.
#
# Verified to build & run (gt/bd/dolt present) against Gastown @ main on
# 2026-06-07. Pin GASTOWN_REF to a tag from
# https://github.com/steveyegge/gastown/tags for reproducible builds, and keep
# this file in sync with upstream's Dockerfile when Gastown changes.
FROM docker/sandbox-templates:claude-code

ARG GASTOWN_REF=main
ARG GO_VERSION=1.25.8
ARG DOLT_VERSION=2.0.7

USER root

# System dependencies (matches upstream).
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    sqlite3 \
    tmux \
    curl \
    ripgrep \
    zsh \
    gh \
    netcat-openbsd \
    tini \
    vim \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Go from the official tarball (apt's is too old).
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -C /usr/local -xz
ENV PATH="/app/gastown:/usr/local/go/bin:/home/agent/go/bin:${PATH}"

# beads (bd) and dolt via their official install scripts.
RUN curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
RUN curl -fsSL "https://github.com/dolthub/dolt/releases/download/v${DOLT_VERSION}/install.sh" | bash

# Directories owned by the unprivileged agent user.
RUN mkdir -p /app /gt /gt/.dolt-data && chown -R agent:agent /app /gt

# Put gastown on PATH for both bash and zsh, and set sane terminal env.
RUN echo 'export PATH="/app/gastown:$PATH"' >> /etc/profile.d/gastown.sh && \
    echo 'export PATH="/app/gastown:$PATH"' >> /etc/zsh/zshenv && \
    echo 'export COLORTERM="truecolor"'     >> /etc/profile.d/colorterm.sh && \
    echo 'export COLORTERM="truecolor"'     >> /etc/zsh/zshenv && \
    echo 'export TERM="xterm-256color"'     >> /etc/profile.d/term.sh && \
    echo 'export TERM="xterm-256color"'     >> /etc/zsh/zshenv

USER agent

# Build Gastown from source at the pinned ref (replaces upstream's COPY).
RUN git clone --depth 1 --branch "${GASTOWN_REF}" \
      https://github.com/steveyegge/gastown /app/gastown \
    && cd /app/gastown && make build

COPY --chown=agent:agent docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

WORKDIR /gt

ENTRYPOINT ["tini", "--", "/app/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
