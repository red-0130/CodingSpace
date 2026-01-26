# Use the specified base image
FROM node:lts-trixie

ENV TZ=America/Toronto

# Download neovim, zellij, ripgrep, lazygit, fdfind
ADD ["https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz", "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz", "https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep_15.1.0-1_amd64.deb", "https://github.com/jesseduffield/lazygit/releases/download/v0.57.0/lazygit_0.57.0_linux_x86_64.tar.gz", "https://github.com/sharkdp/fd/releases/download/v10.3.0/fd_10.3.0_amd64.deb", "/"]

ARG USER=coder

RUN apt-get update && \
    apt-get install -y sudo curl python3-venv python3-pip && \
    ln /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/* /home/node && \
    git clone --depth 1 https://github.com/junegunn/fzf.git /var/lib/fzf && \
    /var/lib/fzf/install --all && \
    ln /var/lib/fzf/bin/* /usr/local/bin/ && \
    cat /root/.fzf.bash >> /etc/skel/.bashrc && \
    curl -fsSL https://bun.sh/install | bash && \
    mv $HOME/.bun/bin/bun /usr/local/bin/ && \
    ln /usr/local/bin/bun /usr/local/bin/bunx && \
    chmod a+x /usr/local/bin/bun /usr/local/bin/bunx && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/ && \
    ln -sf /opt/nvim-linux-x86_64/lib/nvim /usr/local/lib/ && \
    tar -xvf zellij*.tar.gz && \
    install zellij -D -t /usr/local/bin/ && \
    sudo dpkg -i fd_10.3.0_amd64.deb && \
    sudo dpkg -i ripgrep_15.1.0-1_amd64.deb && \
    tar xf lazygit*.tar.gz lazygit && \
    install lazygit -D -t /usr/local/bin/ && \
    bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)" && \
    useradd ${USER} --groups sudo --no-create-home --shell /bin/bash && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    rm -rf ripgrep* nvim-linux-x86_64.tar.gz zellij* lazygit* fd_*

USER ${USER}
WORKDIR /home/${USER}
