#!/usr/bin/env bash
# print.sh [tela|area] — salva em ~/Pictures/Screenshots e copia p/ clipboard
set -euo pipefail
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%F_%H-%M-%S).png"
case "${1:-tela}" in
    area) geo="$(slurp -d -b '3A332855' -c 'B0683Aff' -w 2)" || exit 0
          grim -g "$geo" "$file" ;;
    *)    grim "$file" ;;
esac
wl-copy --type image/png < "$file"
