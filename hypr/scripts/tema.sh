#!/usr/bin/env bash
# tema.sh claro|escuro — troca o tema do rice inteiro.
# Normalmente chamado por quickshell/tema/Noturno.qml (horário ou modo manual);
# para escolher o modo use: qs ipc call tema definir auto|claro|escuro
set -u
modo="${1:-claro}"
if [ "$modo" = escuro ]; then v=noite; else modo=claro; v=dia; fi

D="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"     # raiz dos dotfiles
E="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
mkdir -p "$E" && echo "$modo" > "$E/tema"

# versões ativas dos configs (links relativos, fora do git)
ln -sfn "config-$v.yml"   "$D/lazygit/config.yml"
ln -sfn "config-$v.yml"   "$D/lazydocker/config.yml"
ln -sfn "theme-$v.toml"   "$D/yazi/theme.toml"
ln -sfn "mucha-$v.theme"  "$D/btop/themes/mucha.theme"
ln -sfn "gtk-$v.css"      "$D/gtk/gtk-3.0/gtk.css"
ln -sfn "gtk-$v.css"      "$D/gtk/gtk-4.0/gtk.css"
mkdir -p "$HOME/.config/tmux"
ln -sfn "$D/tmux/cores-$v.conf" "$HOME/.config/tmux/cores.conf"
tmux source-file "$HOME/.config/tmux/cores.conf" 2>/dev/null || true

# GTK, Ghostty, Firefox e Zed seguem o color-scheme do sistema
if [ "$modo" = escuro ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3
fi

# Hyprland: bordas e papel de parede
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if [ "$modo" = escuro ]; then ativa=CC8550; inativa=4A4436; papel=wallpaper-noite.webp
    else ativa=B0683A; inativa=A9B39C; papel=wallpaper.webp; fi
    hyprctl eval "hl.config({ general = { col = { active_border = \"rgba(${ativa}ff)\", inactive_border = \"rgba(${inativa}ff)\" } } })" >/dev/null
    # no login o hyprpaper pode ainda não estar de pé: tenta de novo em seguida
    ( for _ in 1 2 3; do hyprctl hyprpaper wallpaper ",$D/rice/assets/$papel" >/dev/null 2>&1; sleep 2; done ) &
fi
