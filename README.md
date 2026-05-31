# act-node-docker

GitHub/Gitea Actions compatible runner image with Node.js, Docker CLI,
Kubernetes tools, and infrastructure CLIs for use with Gitea Actions
(act-runner).

## Features

- Based on `catthehacker/ubuntu:act-latest` (GitHub Actions compatible)
- Node.js pre-installed (for GitHub Actions that require it)
- Docker CLI with Buildx and Compose plugins
- Kubernetes tooling with `kubectl` and `kustomize`
- Infrastructure tooling with `atmos`, `tofu`, `infisical`, and `jq`
- Compatible with act-runner's Docker-in-Docker setup

## Usage

### Docker Hub

```bash
docker pull noeljackson/act-node-docker:latest
```

### Gitea Runner Configuration

Configure your act-runner labels to use this image:

```yaml
runner_labels:
  - "ubuntu-latest:docker://noeljackson/act-node-docker:latest"
  - "ubuntu-22.04:docker://noeljackson/act-node-docker:latest"
  - "ubuntu-24.04:docker://noeljackson/act-node-docker:latest"
```

### Docker Socket Access

For jobs that need to build Docker images, mount the Docker socket from the DinD sidecar. In your act-runner Helm values:

```yaml
container:
  options: "-v /var/run/docker.sock:/var/run/docker.sock"
```

## Building Locally

```bash
docker build -t act-node-docker:latest .
```

## What's Included

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | Latest from base image | For GitHub Actions |
| npm | Latest from base image | Package manager |
| Docker CLI | Latest stable | Client only, connects to external daemon |
| Docker Buildx | Latest stable | Multi-platform builds |
| Docker Compose | Latest stable | v2 plugin |
| kubectl | 1.36.1 | Kubernetes client |
| kustomize | 5.8.1 | Kubernetes manifest customization |
| atmos | noeljackson/atmos d64609ef8 | Stack and workflow orchestration with Hetzner auth support |
| OpenTofu | 1.11.6 | Terraform-compatible IaC |
| Infisical CLI | 0.43.58 | Secret injection |
| jq | OS package | JSON processing |

## License

MIT
