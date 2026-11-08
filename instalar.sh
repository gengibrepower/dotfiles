#!/usr/bin/env bash
# instalar.sh — monta o rice Mucha num Arch recém-instalado (Hyprland).
# Pode rodar de novo quando quiser: o que já está certo fica como está.
#
#   ./instalar.sh              tudo
#   ./instalar.sh --simular    só mostra o que faria
#   ./instalar.sh --sem-pacotes / --sem-sistema   pula essas etapas
#
# Etapas: pacotes (pacman + paru) → fontes → links em ~/.config →
#         shell, padrões de apps e GTK → sistema (serviços, ufw, snapper, SDDM)
set -euo pipefail

DOTS="$(cd "$(dirname "$0")" && pwd)"
DATA="$(date +%F)"
SIMULAR=0; PACOTES=1; SISTEMA=1
for a in "$@"; do
    case "$a" in
        --simular) SIMULAR=1 ;;
        --sem-pacotes) PACOTES=0 ;;
        --sem-sistema) SISTEMA=0 ;;
        -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "opção desconhecida: $a" >&2; exit 2 ;;
    esac
done

# ---- saída ----
c_ok=$'\e[32m'; c_faz=$'\e[33m'; c_tit=$'\e[1;35m'; c_av=$'\e[31m'; c_0=$'\e[0m'
etapa() { printf '\n%s== %s%s\n' "$c_tit" "$1" "$c_0"; }
ok()    { printf '  %s✓%s %s\n' "$c_ok" "$c_0" "$1"; }
aviso() { printf '  %s!%s %s\n' "$c_av" "$c_0" "$1"; AVISOS+=("$1"); }
AVISOS=()
# executa (ou só mostra, no --simular)
fazer() {
    printf '  %s→%s %s\n' "$c_faz" "$c_0" "$*"
    [ "$SIMULAR" = 1 ] || "$@"
}

[ "$(id -u)" -ne 0 ] || { echo "Rode como seu usuário (o script chama o sudo quando precisa)." >&2; exit 1; }
command -v pacman >/dev/null || { echo "Isto é para Arch Linux." >&2; exit 1; }

# =====================================================================
REPO=(
    # Hyprland e companhia
    hyprland hyprlock hypridle hyprsunset hyprpolkitagent xdg-desktop-portal-hyprland
    quickshell qt6-svg qt6ct adw-gtk-theme
    # terminal e ferramentas
    ghostty tmux neovim zed yazi lazygit lazydocker btop fzf zoxide fd ripgrep
    # captura, clipboard, mídia
    grim slurp satty wf-recorder wl-clipboard cliphist playerctl mpv mpv-mpris imv
    zathura zathura-pdf-mupdf firefox
    # hardware e serviços
    pipewire pipewire-pulse wireplumber networkmanager bluez bluez-utils
    power-profiles-daemon upower brightnessctl udiskie fwupd libnotify xdg-user-dirs
    # sistema
    snapper snap-pac pacman-contrib ufw sddm
    # fontes do sistema (as do rice vêm na etapa de fontes)
    noto-fonts noto-fonts-emoji
)
AUR=()   # nada do AUR por enquanto; o paru fica para atualizar e para o futuro

if [ "$PACOTES" = 1 ]; then
    etapa "Pacotes"
    faltam=()
    for p in "${REPO[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 || faltam+=("$p"); done
    if [ ${#faltam[@]} -eq 0 ]; then ok "todos os ${#REPO[@]} pacotes do repositório"
    else fazer sudo pacman -S --needed --noconfirm "${faltam[@]}"; fi

    if command -v paru >/dev/null; then ok "paru"
    else
        fazer sudo pacman -S --needed --noconfirm base-devel git
        tmp="$(mktemp -d)"
        fazer git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
        if [ "$SIMULAR" = 0 ]; then (cd "$tmp/paru-bin" && makepkg -si --noconfirm); fi
        rm -rf "$tmp"
    fi
    if [ ${#AUR[@]} -gt 0 ]; then fazer paru -S --needed --noconfirm "${AUR[@]}"; fi
fi

# =====================================================================
etapa "Fontes (Federant, Alegreya Sans, Maple Mono NF)"
F="$HOME/.local/share/fonts"
GF="https://raw.githubusercontent.com/google/fonts/main/ofl"
baixar() {   # url destino
    if [ -s "$2" ]; then ok "$(basename "$2")"; return; fi
    fazer curl -fsSL --create-dirs -o "$2" "$1"
}
baixar "$GF/federant/Federant-Regular.ttf" "$F/Federant-Regular.ttf"
for peso in Regular Medium Bold; do
    baixar "$GF/alegreyasans/AlegreyaSans-$peso.ttf" "$F/AlegreyaSans-$peso.ttf"
done
if ls "$F"/MapleMono/MapleMono-NF-Regular.ttf >/dev/null 2>&1; then ok "Maple Mono NF"
else
    tmp="$(mktemp -d)"
    fazer curl -fsSL -o "$tmp/maple.zip" https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF.zip
    fazer mkdir -p "$F/MapleMono"
    fazer bsdtar -xf "$tmp/maple.zip" -C "$F/MapleMono"
    rm -rf "$tmp"
fi
[ "$SIMULAR" = 1 ] || fc-cache -f "$F" >/dev/null

# =====================================================================
etapa "Links em ~/.config"
# linkar <origem no repo> <destino>: o que já existir vira <destino>.bak-<data>
linkar() {
    local src="$DOTS/$1" dst="$2"
    [ -e "$src" ] || { aviso "não existe no repo: $1"; return; }
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then ok "${dst/#$HOME/\~}"; return; fi
    [ -d "$(dirname "$dst")" ] || fazer mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then fazer mv "$dst" "$dst.bak-$DATA"; fi
    fazer ln -s "$src" "$dst"
}
for d in hypr ghostty quickshell rice btop yazi lazygit lazydocker mpv imv zathura satty qt6ct zed; do
    linkar "$d" "$HOME/.config/$d"
done
linkar gtk/gtk-3.0 "$HOME/.config/gtk-3.0"
linkar gtk/gtk-4.0 "$HOME/.config/gtk-4.0"
linkar nvim/.config/nvim "$HOME/.config/nvim"
linkar tmux/tmux.conf "$HOME/.config/tmux/tmux.conf"

# Firefox: o perfil só existe depois de abrir o Firefox uma vez
perfil="$(find "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" -maxdepth 1 -type d -name '*.default-release' 2>/dev/null | head -1 || true)"
if [ -n "$perfil" ]; then
    linkar firefox/chrome "$perfil/chrome"
    linkar firefox/user.js "$perfil/user.js"
else
    aviso "Firefox sem perfil ainda: abra o Firefox uma vez, feche e rode o script de novo"
fi

# =====================================================================
etapa "Shell, apps padrão e GTK"
linha='[ -f ~/Projects/dotfiles/shell/rice.sh ] && . ~/Projects/dotfiles/shell/rice.sh'
[ "$DOTS" = "$HOME/Projects/dotfiles" ] || linha="[ -f $DOTS/shell/rice.sh ] && . $DOTS/shell/rice.sh"
if grep -qF "shell/rice.sh" "$HOME/.bashrc" 2>/dev/null; then ok "~/.bashrc carrega shell/rice.sh"
else fazer sh -c "printf '\n# rice Mucha\n%s\n' '$linha' >> '$HOME/.bashrc'"; fi

padrao() {   # app.desktop tipo...
    local app="$1"; shift
    for t in "$@"; do
        [ "$(xdg-mime query default "$t" 2>/dev/null)" = "$app" ] || fazer xdg-mime default "$app" "$t"
    done
}
if command -v xdg-mime >/dev/null; then
    padrao org.pwmt.zathura.desktop application/pdf application/epub+zip
    padrao imv.desktop image/png image/jpeg image/gif image/webp image/bmp image/tiff image/svg+xml image/avif image/heic
    padrao mpv.desktop video/mp4 video/x-matroska video/webm video/quicktime video/x-msvideo audio/mpeg audio/ogg audio/flac
    ok "zathura (PDF), imv (imagens), mpv (vídeo/áudio)"
fi

if command -v gsettings >/dev/null; then
    gs() { [ "$(gsettings get org.gnome.desktop.interface "$1")" = "'$2'" ] || fazer gsettings set org.gnome.desktop.interface "$1" "$2"; }
    gs gtk-theme adw-gtk3
    gs color-scheme prefer-light
    gs font-name "Alegreya Sans 11"
    ok "GTK: adw-gtk3 claro, Alegreya Sans"
fi
[ "$SIMULAR" = 1 ] || xdg-user-dirs-update 2>/dev/null || true
mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Videos/Gravações" 2>/dev/null || true

# =====================================================================
if [ "$SISTEMA" = 1 ]; then
    etapa "Sistema (pede sudo)"
    ativar() {   # unidade [--user]
        if [ "${2:-}" = --user ]; then
            systemctl --user is-enabled -q "$1" 2>/dev/null && { ok "$1 (usuário)"; return; }
            fazer systemctl --user enable --now "$1"
        else
            systemctl is-enabled -q "$1" 2>/dev/null && { ok "$1"; return; }
            fazer sudo systemctl enable --now "$1"
        fi
    }
    for u in NetworkManager.service bluetooth.service power-profiles-daemon.service ufw.service \
             paccache.timer snapper-cleanup.timer snapper-timeline.timer; do ativar "$u"; done
    for u in pipewire.socket pipewire-pulse.socket wireplumber.service hyprpolkitagent.service; do ativar "$u" --user; done

    # firewall: nega entrada, libera saída
    if grep -qs "^ENABLED=yes" /etc/ufw/ufw.conf; then ok "ufw ativo"
    else
        fazer sudo ufw default deny incoming
        fazer sudo ufw default allow outgoing
        fazer sudo ufw --force enable
    fi

    # snapper: / (antes/depois de cada pacman, via snap-pac) e /home (de hora em hora)
    snap_config() {   # nome ponto-de-montagem chave=valor...
        local nome="$1" ponto="$2"; shift 2
        if [ -f "/etc/snapper/configs/$nome" ]; then ok "snapper $nome ($ponto)"; return; fi
        if [ "$(stat -f -c %T "$ponto")" != btrfs ]; then aviso "snapper $nome: $ponto não é btrfs, pulei"; return; fi
        fazer sudo snapper -c "$nome" create-config "$ponto" || { aviso "snapper $nome: create-config falhou (já existe $ponto/.snapshots?)"; return; }
        fazer sudo snapper -c "$nome" set-config "$@"
    }
    snap_config root / TIMELINE_CREATE=no NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=10
    snap_config home /home TIMELINE_CREATE=yes TIMELINE_CLEANUP=yes \
        TIMELINE_LIMIT_HOURLY=24 TIMELINE_LIMIT_DAILY=7 TIMELINE_LIMIT_WEEKLY=0 \
        TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_QUARTERLY=0 TIMELINE_LIMIT_YEARLY=0 \
        ALLOW_USERS="$USER" SYNC_ACL=yes

    # tela de login
    if [ -f /etc/sddm.conf.d/10-mucha.conf ] && diff -rq "$DOTS/sddm/mucha" /usr/share/sddm/themes/mucha >/dev/null 2>&1; then
        ok "SDDM com o tema Mucha"
    else
        fazer bash "$DOTS/sddm/instalar.sh"
    fi
fi

# =====================================================================
etapa "Pronto"
if [ ${#AVISOS[@]} -gt 0 ]; then
    echo "  Ficou pendente:"
    for a in "${AVISOS[@]}"; do echo "   - $a"; done
fi
cat <<'EOF'
  Próximos passos:
   - abra um terminal novo (zoxide, fzf e a função claude entram pelo ~/.bashrc)
   - no primeiro nvim, o lazy.nvim baixa os plugins sozinho
   - saia da sessão e entre de novo pelo SDDM para o Hyprland carregar tudo
   - Super+ß mostra todos os atalhos
EOF
[ "$SIMULAR" = 0 ] || echo "  (simulação: nada foi alterado)"
