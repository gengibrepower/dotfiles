#!/usr/bin/env bash
# Instala o tema SDDM "Mucha" e ativa o SDDM no próximo boot.
# Copia (não linka): o usuário sddm não lê a home.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"

sudo install -d /usr/share/sddm/themes/mucha
sudo cp -r "$dir/mucha/." /usr/share/sddm/themes/mucha/
sudo install -Dm644 "$dir/10-mucha.conf" /etc/sddm.conf.d/10-mucha.conf
sudo systemctl enable sddm.service

echo "Tema instalado. O SDDM assume a partir do próximo boot."
echo "Prévia sem reiniciar: sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/mucha"
