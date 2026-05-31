# act-node-docker
# GitHub/Gitea Actions compatible runner image with Node.js and infra CLIs
# Based on catthehacker/ubuntu:act-latest

FROM --platform=$BUILDPLATFORM golang:1.26.2-bookworm AS atmos-builder

ARG TARGETARCH
ARG ATMOS_REPO=https://github.com/noeljackson/atmos.git
ARG ATMOS_REF=d64609ef85bd9f5a4892e88f86dec16c23e4cb58

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates git; \
    rm -rf /var/lib/apt/lists/*; \
    git init /src/atmos; \
    cd /src/atmos; \
    git remote add origin "$ATMOS_REPO"; \
    git fetch --depth 1 origin "$ATMOS_REF"; \
    git checkout --detach FETCH_HEAD

WORKDIR /src/atmos

RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    CGO_ENABLED=0 GOOS=linux GOARCH="$arch" go build \
      -trimpath \
      -ldflags "-s -w -X 'github.com/cloudposse/atmos/pkg/version.Version=${ATMOS_REF}'" \
      -o /out/atmos

# act-node-docker
# GitHub/Gitea Actions compatible runner image with Node.js and infra CLIs
# Based on catthehacker/ubuntu:act-latest

FROM catthehacker/ubuntu:act-latest

ARG TARGETARCH
ARG KUBECTL_VERSION=v1.36.1
ARG KUSTOMIZE_VERSION=5.8.1
ARG OPENTOFU_VERSION=1.11.6
ARG INFISICAL_VERSION=0.43.58

ENV ATMOS_TELEMETRY_ENABLED=false \
    ATMOS_VERSION_CHECK_ENABLED=false

LABEL org.opencontainers.image.source="https://github.com/noeljackson/act-node-docker"
LABEL org.opencontainers.image.description="Actions runner image with Node.js, Docker CLI, Kubernetes, Atmos, OpenTofu, and Infisical CLIs"
LABEL org.opencontainers.image.licenses="MIT"

# Install Docker CLI (not daemon - we connect to external Docker via socket)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    jq \
    ripgrep \
    tar \
    unzip \
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
RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install kustomize for Kubernetes manifests
RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${arch}.tar.gz" -o /tmp/kustomize.tar.gz; \
    tar -xzf /tmp/kustomize.tar.gz -C /usr/local/bin kustomize; \
    rm -f /tmp/kustomize.tar.gz

# Install Atmos for stack and workflow orchestration.
COPY --from=atmos-builder /out/atmos /usr/local/bin/atmos

# Install OpenTofu for Terraform-compatible infrastructure plans/applies
RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_${arch}.deb" -o /tmp/tofu.deb; \
    dpkg -i /tmp/tofu.deb; \
    rm -f /tmp/tofu.deb

# Install Infisical CLI for OIDC-backed secret injection
RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/Infisical/cli/releases/download/v${INFISICAL_VERSION}/infisical_${INFISICAL_VERSION}_linux_${arch}.deb" -o /tmp/infisical.deb; \
    dpkg -i /tmp/infisical.deb; \
    rm -f /tmp/infisical.deb

# Verify installations
RUN node --version \
    && npm --version \
    && docker --version \
    && kubectl version --client \
    && kustomize version \
    && atmos version \
    && tofu version \
    && infisical --version \
    && jq --version \
    && rg --version
