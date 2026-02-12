# --- Stage 1: Builder ---
FROM debian:trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /extract/nv /extract/zj /extract/lg /extract/fzf /extract/sf

# 1. Neovim
RUN curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | tar -C /extract/nv -xz --strip-components=1

# 2. Zellij
RUN curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -C /extract/zj -xz

# 3. Lazygit
RUN curl -L https://github.com/jesseduffield/lazygit/releases/download/v0.57.0/lazygit_0.57.0_linux_x86_64.tar.gz | tar -C /extract/lg -xz lazygit

# 4. Superfile (Direct binary download to bypass script issues)
# We fetch the latest release version dynamically via GitHub API or use a fixed version for stability
RUN curl -L https://github.com/yorukot/superfile/releases/latest/download/superfile-linux-v1.5.0-amd64.tar.gz | tar -C /extract/sf -xz

# 5. FZF: Binary + Shell scripts
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf && \
    /tmp/fzf/install --bin && \
    cp /tmp/fzf/bin/fzf /extract/fzf/ && \
    cp -r /tmp/fzf/shell /extract/fzf/

# 6. Download .deb packages (ripgrep & fd)
RUN curl -L -o /extract/rg.deb https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep_15.1.0-1_amd64.deb && \
    curl -L -o /extract/fd.deb https://github.com/sharkdp/fd/releases/download/v10.3.0/fd_10.3.0_amd64.deb

# --- Stage 2: Final ---
FROM node:lts-trixie-slim

ENV TZ=America/Toronto
ARG USER=coder

# Install all runtime dependencies (LazyVim + SSH + Pip + Essentials)
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl git python3-minimal python3-pip python3-venv \
    ca-certificates unzip openssh-client build-essential make gettext \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder
COPY --from=builder /extract/nv/bin/nvim /usr/local/bin/
COPY --from=builder /extract/nv/lib/nvim /usr/local/lib/nvim
COPY --from=builder /extract/nv/share/nvim /usr/local/share/nvim
COPY --from=builder /extract/zj/zellij /usr/local/bin/
COPY --from=builder /extract/lg/lazygit /usr/local/bin/
COPY --from=builder /extract/sf/dist/*/spf /usr/local/bin/spf 
COPY --from=builder /extract/fzf/fzf /usr/local/bin/
COPY --from=builder /extract/fzf/shell /usr/local/share/fzf/shell

# Install .debs and Bun
COPY --from=builder /extract/rg.deb /extract/fd.deb /tmp/
RUN dpkg -i /tmp/rg.deb /tmp/fd.deb && rm /tmp/*.deb && \
    curl -fsSL https://bun.sh/install | bash && \
    mv /root/.bun/bin/bun /usr/local/bin/bun && \
    ln -s /usr/local/bin/bun /usr/local/bin/bunx

# Setup User
RUN useradd ${USER} --groups sudo --create-home --shell /bin/bash && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}
WORKDIR /home/${USER}

# Post-install config: SSH & FZF
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null && \
    echo 'eval "$(fzf --bash)"' >> ~/.bashrc

CMD ["bash"]