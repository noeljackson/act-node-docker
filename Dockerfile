# act-node-docker
# GitHub Actions compatible runner image with Node.js and Docker CLI
# Based on catthehacker/ubuntu:act-latest

FROM catthehacker/ubuntu:act-latest

LABEL org.opencontainers.image.source="https://github.com/noeljackson/act-node-docker"
LABEL org.opencontainers.image.description="GitHub Actions runner image with Node.js, Docker CLI, and kubectl for Gitea Actions"
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

# Install kubectl for Kubernetes deployments
RUN curl -fsSL "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install kustomize for Kubernetes manifests
RUN curl -fsSL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash \
    && mv kustomize /usr/local/bin/

# Verify installations
RUN node --version && npm --version && docker --version && kubectl version --client && kustomize version
