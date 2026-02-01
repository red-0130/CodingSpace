# CodingSpace

A Docker-based development environment for deploying Node.js and Python development workflows.

## Features

This image is built on `node:lts-trixie` and comes pre-configured with a powerful suite of CLI tools and languages.

### Core Runtimes & Languages
- **Node.js LTS**: The backbone of the environment.
- **Bun (v1.3.8)**: A fast all-in-one JavaScript runtime.
- **Python 3**: Pre-installed with `python3-venv` and `pip`.

### Development & Terminal Tools
- **Neovim**: Hyperextensible Vim-based text editor (latest release).
- **Zellij**: A modern terminal workspace/multiplexer.
- **Lazygit**: Simple terminal UI for git commands.
- **Superfile**: A pretty and fancy terminal file manager.
- **Ripgrep**: Line-oriented search tool that recursively searches the current directory.
- **Fd**: A simple, fast and user-friendly alternative to 'find'.
- **FZF**: A general-purpose command-line fuzzy finder.

## Getting Started

### Prerequisites
- Docker installed on your system.

### Build the Image
```bash
docker build -t codingspace .
```

### Run the Container
```bash
docker run -it codingspace
```
This will drop you into a bash shell as the `coder` user with `sudo` privileges.