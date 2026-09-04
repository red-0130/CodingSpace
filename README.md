# CodingSpace

A Docker-based development environment for deploying Node.js and Python development workflows.

## Features

This image is built on `node:lts-trixie-slim` using a **multi-stage build** process to ensure a lightweight and optimized final image. It comes pre-configured with a powerful suite of CLI tools and languages, with customizable versions.

### Core Runtimes & Languages

- **Node.js LTS**: The backbone of the environment.
- **Bun (latest)**: A fast all-in-one JavaScript runtime.
- **Python 3**: Pre-installed with `python3` and `uv` (a fast Python package installer and resolver).

### Development & Terminal Tools

- **Neovim (latest)**: Hyperextensible Vim-based text editor.
- **Zellij (latest)**: A modern terminal workspace/multiplexer.
- **Lazygit (0.64.1)**: Simple terminal UI for git commands.
- **Superfile (1.6.0)**: A pretty and fancy terminal file manager.
- **Ripgrep (15.2.0)**: Line-oriented search tool that recursively searches the current directory.
- **Fd (10.5.0)**: A simple, fast and user-friendly alternative to 'find'.
- **FZF (latest)**: A general-purpose command-line fuzzy finder.
- **Tree-sitter CLI (0.27.0)**: Incremental parsing system for programming tools.
- **Build Essentials**: Includes `make`, `gcc`, etc.
- **OpenSSH Client**: For secure remote connections.

## Deployment Options

### Devcontainer / DevPod

This repository includes a `devcontainer.json` configuration, allowing you to easily spin up the environment using [DevPod](https://devpod.sh/) or other devcontainer clients:

- **Image**: `ghcr.io/red-0130/codingspace:latest`

### Coder Workspace

A pre-configured Coder template (`main.tf`) is provided for deploying workspaces as Docker containers. It includes:
- **VS Code Web**: Access your editor directly in the browser.
- **Dotfiles**: Automated personal configurations loading from a git repository.
- **Resource Monitoring**: Real-time CPU, RAM, and disk utilization stats.

## Getting Started

### Prerequisites

- Docker installed on your system.

### Build the Image

You can build the image with default versions:

```bash
docker build -t codingspace .
```

#### Customizing Versions

You can specify custom versions for tools using build arguments:

```bash
docker build \
  --build-arg NV_VERSION=0.10.0 \
  --build-arg ZJ_VERSION=0.40.0 \
  --build-arg LG_VERSION=0.64.1 \
  --build-arg TS_VERSION=0.27.0 \
  -t codingspace .
```

### Run the Container

```bash
docker run -it codingspace
```

This will drop you into a bash shell as the `coder` user with `sudo` privileges.
