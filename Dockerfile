FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo curl wget git unzip ffmpeg python3 python3-pip \
    neofetch tmux tzdata nano vim htop net-tools iputils-ping \
    ca-certificates gnupg build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

# Node.js 22 (sudah termasuk npm)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Claude Code + Railway CLI (untuk auto TCP proxy port 22)
RUN npm install -g @anthropic-ai/claude-code @railway/cli

# Deno (dibutuhkan bot) + uv
RUN curl -fsSL https://deno.land/install.sh | sh \
    && curl -LsSf https://astral.sh/uv/install.sh | sh

# PATH untuk Docker dan untuk sesi SSH (SSH tidak mewarisi ENV Docker)
ENV PATH="/root/.deno/bin:/root/.local/bin:${PATH}"
RUN echo 'export PATH="/root/.deno/bin:/root/.local/bin:$PATH"' > /etc/profile.d/custom-path.sh \
    && echo 'export PATH="/root/.deno/bin:/root/.local/bin:$PATH"' >> /root/.bashrc

# Banner login, perintah sysinfo, alias, folder projects
COPY sysinfo /usr/local/bin/sysinfo
COPY motd.sh /etc/profile.d/99-motd.sh
RUN chmod +x /usr/local/bin/sysinfo \
    && mkdir -p /root/projects \
    && printf "alias cl='claude'\\nalias projects='cd ~/projects'\\n" >> /root/.bashrc \
    && chmod -x /etc/update-motd.d/* 2>/dev/null || true

# Konfigurasi SSH
RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config \
    && echo "ClientAliveCountMax 5" >> /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
