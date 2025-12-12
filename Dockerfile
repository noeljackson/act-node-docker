# act-node-docker
# GitHub Actions compatible runner image with Node.js and Docker CLI
# Based on catthehacker/ubuntu:act-latest

FROM catthehacker/ubuntu:act-latest

LABEL org.opencontainers.image.source="https://github.com/noeljackson/act-node-docker"
LABEL org.opencontainers.image.description="GitHub Actions runner image with Node.js and Docker CLI for Gitea Actions"
LABEL org.opencontainers.image.licenses="MIT"

# Install Docker CLI (not daemon - we connect to external Docker via socket)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
RUN node --version && npm --version && docker --version
