# Hafiz Cloud Workstation2

Ubuntu 22.04 + SSH di Railway, lengkap dengan banner login, Node.js 22, Python, Deno, uv, ffmpeg, tmux dan Claude Code.

## Isi Project

| File | Fungsi |
|------|--------|
| `Dockerfile` | Image Ubuntu 22.04 + semua tools |
| `entrypoint.sh` | Set password/key lalu jalankan SSH server |
| `motd.sh` | Banner login (HAFIZ) |
| `sysinfo` | Perintah info sistem |
| `railway.json` | Konfigurasi build Railway |

## Deploy ke Railway

1. Push semua file ke repo GitHub (file harus di root repo).
2. Railway: **New Project → Deploy from GitHub repo**.
3. Tab **Variables**, tambahkan:
   - `ROOT_PASSWORD` : password login root
   - `SSH_PUBLIC_KEY` : (opsional) public key, lebih aman dari password
4. **Settings → Networking → TCP Proxy**, tambahkan port `22`.
5. Railway memberi alamat seperti `xxx.proxy.rlwy.net:12345`.

## Connect

```bash
ssh root@xxx.proxy.rlwy.net -p 12345
```

## Perintah Cepat

| Perintah | Fungsi |
|----------|--------|
| `cl` | Jalankan Claude Code |
| `projects` | Masuk ke `~/projects` |
| `tmux new -s bot` | Sesi terminal yang tetap hidup |
| `tmux attach -t bot` | Masuk lagi ke sesi |
| `sysinfo` | Info sistem |

## Variables Opsional (Banner)

Semua sudah ada default, isi hanya kalau mau ubah.

| Variable | Default |
|----------|---------|
| `BANNER_TEXT` | `HAFIZ` |
| `BANNER_SUBTITLE` | `SSH WORKSTATION2` |
| `BANNER_FONT` | `small` (atau `big`, `block`) |
| `BANNER_FOOTER` | `Managed by Hafiz` |
| `HOST_LABEL` | `Hafiz Cloud Workstation2` |
| `OWNER_NAME` | `Hafiz/Salam` |
| `OWNER_TELEGRAM` | `@Vnrav` |

## Catatan

- Disk Railway sementara: file hilang saat redeploy. Pasang **Volume** (misal mount ke `/root`) untuk data permanen.
- Sesi tmux ikut hilang kalau container restart.
- Port SSH terbuka ke publik. Pakai password kuat atau `SSH_PUBLIC_KEY` saja (kosongkan `ROOT_PASSWORD` untuk mematikan login password).
- Untuk Claude Code, login sendiri atau isi `ANTHROPIC_API_KEY` di Variables.
