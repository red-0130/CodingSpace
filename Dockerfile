# --- Version Configuration ---
ARG NV_VERSION=latest
ARG ZJ_VERSION=latest
ARG LG_VERSION=0.57.0
ARG RG_VERSION=15.1.0
ARG FD_VERSION=10.3.0
ARG SF_VERSION=1.5.0

# --- Stage 1: Builder ---
FROM debian:trixie-slim AS builder

ARG NV_VERSION
ARG ZJ_VERSION
ARG LG_VERSION
ARG RG_VERSION
ARG FD_VERSION
ARG SF_VERSION

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /extract/nv /extract/zj /extract/lg /extract/sf /extract/fzf_bin

# 1. Neovim
RUN NV_DL_URL=$(if [ "$NV_VERSION" = "latest" ]; then echo "latest/download"; else echo "download/v$NV_VERSION"; fi) && \
    curl -L "https://github.com/neovim/neovim/releases/$NV_DL_URL/nvim-linux-x86_64.tar.gz" | tar -C /extract/nv -xz --strip-components=1

# 2. Zellij
RUN ZJ_DL_URL=$(if [ "$ZJ_VERSION" = "latest" ]; then echo "latest/download"; else echo "download/v$ZJ_VERSION"; fi) && \
    curl -L "https://github.com/zellij-org/zellij/releases/$ZJ_DL_URL/zellij-x86_64-unknown-linux-musl.tar.gz" | tar -C /extract/zj -xz

# 3. Lazygit
RUN curl -L "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_linux_x86_64.tar.gz" | tar -C /extract/lg -xz lazygit

# 4. Superfile (Direct binary using the vX.X.X pattern)
RUN curl -L "https://github.com/yorukot/superfile/releases/download/v${SF_VERSION}/superfile-linux-v${SF_VERSION}-amd64.tar.gz" | tar -C /extract/sf -xz

# 5. FZF (Binary only)
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf && \
    /tmp/fzf/install --bin && \
    cp /tmp/fzf/bin/fzf /extract/fzf_bin/

# 6. Ripgrep & FD
RUN curl -L -o /extract/rg.deb "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}-1_amd64.deb" && \
    curl -L -o /extract/fd.deb "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb"

# --- Stage 2: Final ---
FROM node:lts-trixie-slim

ENV TZ=America/Toronto
ARG USER=coder

# Dependencies for LazyVim, SSH, and Pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl git python3-minimal python3-pip python3-venv \
    ca-certificates unzip openssh-client build-essential make gettext \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Copy tools from builder
COPY --from=builder /extract/nv/bin/nvim /usr/local/bin/
COPY --from=builder /extract/nv/lib/nvim /usr/local/lib/nvim
COPY --from=builder /extract/nv/share/nvim /usr/local/share/nvim
COPY --from=builder /extract/zj/zellij /usr/local/bin/
COPY --from=builder /extract/lg/lazygit /usr/local/bin/
COPY --from=builder /extract/sf/dist/*/spf /usr/local/bin/spf
COPY --from=builder /extract/fzf_bin/fzf /usr/local/bin/

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

# Config: SSH & FZF (Modern eval method)
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null && \
    echo 'eval "$(fzf --bash)"' >> ~/.bashrc

CMD ["bash"]
