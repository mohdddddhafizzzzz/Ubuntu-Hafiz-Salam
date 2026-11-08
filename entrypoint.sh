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
