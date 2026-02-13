# CodingSpace

A Docker-based development environment for deploying Node.js and Python development workflows.

## Features

This image is built on `node:lts-trixie-slim` using a **multi-stage build** process to ensure a lightweight and optimized final image. It comes pre-configured with a powerful suite of CLI tools and languages, with customizable versions.

### Core Runtimes & Languages
- **Node.js LTS**: The backbone of the environment.
- **Bun (v1.3.9)**: A fast all-in-one JavaScript runtime.
- **Python 3**: Pre-installed with `python3-venv`, `pip`, and `python3-minimal`.

### Development & Terminal Tools
- **Neovim**: Hyperextensible Vim-based text editor.
- **Zellij**: A modern terminal workspace/multiplexer.
- **Lazygit**: Simple terminal UI for git commands.
- **Superfile**: A pretty and fancy terminal file manager.
- **Ripgrep**: Line-oriented search tool that recursively searches the current directory.
- **Fd**: A simple, fast and user-friendly alternative to 'find'.
- **FZF**: A general-purpose command-line fuzzy finder.
- **Build Essentials**: Includes `make`, `gcc`, etc.
- **OpenSSH Client**: For secure remote connections.

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
  --build-arg LG_VERSION=0.40.0 \
  -t codingspace .
```

### Run the Container
```bash
docker run -it codingspace
```
This will drop you into a bash shell as the `coder` user with `sudo` privileges.
