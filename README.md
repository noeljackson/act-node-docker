# act-node-docker

GitHub Actions compatible runner image with Node.js and Docker CLI for use with Gitea Actions (act-runner).

## Features

- Based on `catthehacker/ubuntu:act-latest` (GitHub Actions compatible)
- Node.js pre-installed (for GitHub Actions that require it)
- Docker CLI with Buildx and Compose plugins
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

## License

MIT
