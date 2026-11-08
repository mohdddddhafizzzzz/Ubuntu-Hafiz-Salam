# syntax=docker/dockerfile:1
# =====================================================
#  Hafiz Cloud Workstation2  -  Ubuntu 22.04 + SSH
#  Satu file sahaja. Deploy ke Railway terus.
#  Variables: ROOT_PASSWORD (wajib) / SSH_PUBLIC_KEY (opsional)
#             RAILWAY_API_TOKEN (opsional, auto TCP proxy port 22)
# =====================================================
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

# Claude Code + Railway CLI
RUN npm install -g @anthropic-ai/claude-code @railway/cli

# Deno + uv
RUN curl -fsSL https://deno.land/install.sh | sh \
    && curl -LsSf https://astral.sh/uv/install.sh | sh

# PATH untuk Docker dan sesi SSH
ENV PATH="/root/.deno/bin:/root/.local/bin:${PATH}"
RUN echo 'export PATH="/root/.deno/bin:/root/.local/bin:$PATH"' > /etc/profile.d/custom-path.sh \
    && echo 'export PATH="/root/.deno/bin:/root/.local/bin:$PATH"' >> /root/.bashrc

# ---------- sysinfo ----------
RUN <<'DOCKER_EOT'
set -e
cat > /usr/local/bin/sysinfo <<'EOF_FILE'
#!/bin/bash
# Informasi sistem (dipakai juga oleh banner login)

B='\033[94m'; C='\033[96m'; G='\033[92m'; Y='\033[93m'; D='\033[90m'; N='\033[0m'

row() { printf '  • %-12s: %b%s%b\n' "$1" "$2" "$3" "$N"; }

# Region dari IP geolocation (di-cache supaya login seterusnya laju)
cache=/tmp/.geo_region
if [ ! -s "$cache" ]; then
  g=$(curl -fsS --max-time 3 'http://ip-api.com/line/?fields=city,country' 2>/dev/null | paste -sd, - | sed 's/,/, /')
  [ -n "$g" ] && echo "$g" > "$cache"
fi
region=$(cat "$cache" 2>/dev/null)
[ -z "$region" ] && region="${RAILWAY_REPLICA_REGION:-Unknown}"

os=$(. /etc/os-release && echo "$PRETTY_NAME")
node_v=$(node -v 2>/dev/null || echo "n/a")
py_v=$(python3 -V 2>/dev/null | awk '{print $2}')

printf '  %bSYSTEM INFORMATION%b\n' "$B" "$N"
row "Host"         "$B" "${HOST_LABEL:-Hafiz Cloud Workstation2}"
row "OS"           "$C" "$os"
row "Kernel"       "$C" "$(uname -r)"
row "Architecture" "$C" "$(uname -m)"
row "Region"       "$G" "$region"
row "Region ID"    "$G" "IP Geolocation"
row "Timezone"     "$Y" "$(date +'%Z (UTC%:z)')"
row "Replica ID"   "$G" "${RAILWAY_REPLICA_ID:-Unavailable}"
row "Detection"    "$D" "Public IP Detection"
row "Node.js"      "$C" "$node_v"
row "Python"       "$C" "$py_v"
row "Access"       "$B" "SSH / Railway TCP Proxy"
EOF_FILE
chmod 755 /usr/local/bin/sysinfo
DOCKER_EOT

# ---------- banner login ----------
RUN <<'DOCKER_EOT'
set -e
cat > /etc/profile.d/99-motd.sh <<'EOF_FILE'
#!/bin/bash
# Banner login. Hanya tampil di terminal interaktif, sekali per sesi.
[ -t 1 ] || return 0 2>/dev/null || exit 0
[ -n "$MOTD_SHOWN" ] && return 0 2>/dev/null
export MOTD_SHOWN=1

ESC=$'\033'
G='\033[92m'; B='\033[94m'; Y='\033[93m'; W='\033[1;97m'; D='\033[90m'; N='\033[0m'

# Huruf HAFIZ: badan putih, garis tepi hijau
art() {
  sed -e "s/█/${ESC}[1;97m█${ESC}[92m/g" <<'ART'
██╗  ██╗ █████╗ ███████╗██╗███████╗
██║  ██║██╔══██╗██╔════╝██║╚══███╔╝
███████║███████║█████╗  ██║  ███╔╝ 
██╔══██║██╔══██║██╔══╝  ██║ ███╔╝  
██║  ██║██║  ██║██║     ██║███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
ART
}

clear
echo
printf '%b' "$G"; art; printf '%b' "$N"
echo; echo
printf '         %bSSH WORKSTATION2%b\n\n' "$W" "$N"
printf '  %bPremium Ubuntu Cloud Workstation2%b\n' "$W" "$N"
printf '  %bBy Hafiz/Salam%b\n\n' "$G" "$N"

sysinfo

printf '  %bAVAILABLE FEATURES%b\n' "$Y" "$N"
printf '  %b✓ Ubuntu Cloud Environment%b\n' "$G" "$N"
printf '  %b✓ SSH Remote Terminal%b\n' "$G" "$N"
printf '  %b✓ Node.js & Python Development%b\n' "$G" "$N"
printf '  %b✓ Claude Code Ready (jika dikonfigurasi)%b\n' "$G" "$N"
printf '  %b✓ TMUX Session Support%b\n\n' "$G" "$N"

printf '  %bQUICK COMMANDS%b\n' "$Y" "$N"
printf '  %b%-11s%b%b%s%b\n' "$B" "cl"       "$N" "$G" "Start Claude Code"        "$N"
printf '  %b%-11s%b%b%s%b\n' "$B" "projects" "$N" "$G" "Open project directory"   "$N"
printf '  %b%-11s%b%b%s%b\n' "$B" "tmux"     "$N" "$G" "Manage terminal sessions" "$N"
printf '  %b%-11s%b%b%s%b\n' "$B" "sysinfo"  "$N" "$G" "Show system information"  "$N"
echo

printf '  %bSUPPORT ME%b\n' "$Y" "$N"
printf '  %bAllah%b\n  %bMak%b\n\n' "$W" "$N" "$W" "$N"

printf '  %bOWNER INFORMATION%b\n' "$Y" "$N"
printf '  %bPemilik : %s%b\n' "$W" "${OWNER_NAME:-Hafiz/Salam}" "$N"
printf '  %bTelegram: %s%b\n\n' "$W" "${OWNER_TELEGRAM:-@Vnrav}" "$N"

printf '  %bNyari Hafiz? pm aja kontak di atas!%b\n\n' "$G" "$N"
printf '  %bCopyright & Managed by Hafiz/Salam%b\n\n' "$D" "$N"
EOF_FILE
chmod 644 /etc/profile.d/99-motd.sh
DOCKER_EOT

# ---------- entrypoint ----------
RUN <<'DOCKER_EOT'
set -e
cat > /entrypoint.sh <<'EOF_FILE'
#!/bin/bash
set -e

if [ -z "$ROOT_PASSWORD" ] && [ -z "$SSH_PUBLIC_KEY" ]; then
  echo "ERROR: Set ROOT_PASSWORD atau SSH_PUBLIC_KEY di Railway Variables."
  exit 1
fi

# Password root
if [ -n "$ROOT_PASSWORD" ]; then
  echo "root:${ROOT_PASSWORD}" | chpasswd
else
  # Kalau hanya pakai key, matikan login password
  sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
fi

# Public key (opsional)
if [ -n "$SSH_PUBLIC_KEY" ]; then
  mkdir -p /root/.ssh
  echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
fi

# Teruskan variabel Railway/banner ke sesi SSH (sshd tidak mewarisi env container)
for v in $(compgen -e | grep -E '^(RAILWAY_|OWNER_|BANNER_)' | grep -vi 'TOKEN'); do
  printf 'export %s=%q\n' "$v" "${!v}"
done > /etc/profile.d/00-container-env.sh

# Auto TCP Proxy port 22 (hanya jalan kalau RAILWAY_API_TOKEN diisi)
# Kalau proxy sudah ada, perintah ini gagal dengan selamat dan diabaikan.
if [ -n "$RAILWAY_API_TOKEN" ]; then
  (
    sleep 5
    railway tcp-proxy create --port 22 \
      -p "$RAILWAY_PROJECT_ID" -e "$RAILWAY_ENVIRONMENT_ID" -s "$RAILWAY_SERVICE_ID" \
      > /var/log/tcp-proxy.log 2>&1 || true
  ) &
fi

# Host keys
ssh-keygen -A

echo "SSH server berjalan di port 22"
exec /usr/sbin/sshd -D -e
EOF_FILE
chmod 755 /entrypoint.sh
DOCKER_EOT

# Alias, folder projects, banner dari .bashrc, matikan mesej default Ubuntu
RUN mkdir -p /root/projects \
    && printf "alias cl='claude'\\nalias projects='cd ~/projects'\\n" >> /root/.bashrc \
    && echo '[ -f /etc/profile.d/99-motd.sh ] && . /etc/profile.d/99-motd.sh' >> /root/.bashrc \
    && rm -f /etc/motd /etc/legal \
    && chmod -x /etc/update-motd.d/* 2>/dev/null || true \
    && sed -i '/pam_motd.so/s/^/#/' /etc/pam.d/sshd

# Konfigurasi SSH
RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && echo "PrintMotd no" >> /etc/ssh/sshd_config \
    && echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config \
    && echo "ClientAliveCountMax 5" >> /etc/ssh/sshd_config

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
