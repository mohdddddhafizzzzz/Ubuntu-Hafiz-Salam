#!/bin/bash
# Banner login. Hanya tampil di terminal interaktif, sekali per sesi.
[ -t 1 ] || return 0 2>/dev/null || exit 0
[ -n "$MOTD_SHOWN" ] && return 0 2>/dev/null
export MOTD_SHOWN=1

P='\033[92m'; B='\033[94m'; G='\033[92m'; Y='\033[93m'; W='\033[1;97m'; N='\033[0m'

TITLE="${BANNER_TEXT:-HAFIZ}"
SUBTITLE="${BANNER_SUBTITLE:-SSH WORKSTATION2}"
FONT="${BANNER_FONT:-small}"   # small muat di layar HP; ganti ke big/block kalau layar lebar

clear
printf '%b' "$P"
figlet -f "$FONT" -w 60 "$TITLE" 2>/dev/null || echo "$TITLE"
printf '%b\n' "$N"
printf '%b  %s%b\n' "$W" "$SUBTITLE" "$N"
printf '%b  Hafiz Cloud Workstation2%b\n' "$P" "$N"
echo

sysinfo
echo

printf '%bAVAILABLE FEATURES%b\n' "$Y" "$N"
printf '%b✓ Ubuntu Cloud Environment%b\n' "$G" "$N"
printf '%b✓ SSH Remote Terminal%b\n' "$G" "$N"
printf '%b✓ Node.js & Python Development%b\n' "$G" "$N"
printf '%b✓ Claude Code Ready%b\n' "$G" "$N"
printf '%b✓ TMUX Session Support%b\n' "$G" "$N"
echo

printf '%bQUICK COMMANDS%b\n' "$Y" "$N"
printf '%b%-10s%b %s\n' "$B" "cl"       "$N" "Start Claude Code"
printf '%b%-10s%b %s\n' "$B" "projects" "$N" "Open project directory"
printf '%b%-10s%b %s\n' "$B" "tmux"     "$N" "Manage terminal sessions"
printf '%b%-10s%b %s\n' "$B" "sysinfo"  "$N" "Show system information"
echo

printf '%bSUPPORT ME%b\n' "$Y" "$N"
echo "Allah"
echo "Mak"
echo

printf '%bOWNER INFORMATION%b\n' "$Y" "$N"
printf 'Pemilik  : %s\n' "${OWNER_NAME:-Hafiz/Salam}"
printf 'Telegram : %s\n' "${OWNER_TELEGRAM:-@Vnrav}"
echo

printf '%b%s%b\n\n' "$P" "${BANNER_FOOTER:-Managed by Hafiz}" "$N"
