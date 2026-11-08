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
