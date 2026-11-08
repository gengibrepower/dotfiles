#!/usr/bin/env bash
# captura.sh — screenshots e gravação do rice Mucha
#   captura.sh area|janela|tela [anotar]   screenshot (copia + salva; "anotar" abre o satty)
#   captura.sh gravar area|tela [som]      começa a gravar (som = áudio do sistema)
#   captura.sh parar                       para a gravação em andamento
#   captura.sh gravando                    sai 0 se há gravação em andamento
# Print abre o menu (quickshell/captura), que chama este script.
set -uo pipefail

fotos="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
videos="${XDG_VIDEOS_DIR:-$HOME/Videos}/Gravações"
pidf="${XDG_RUNTIME_DIR:-/tmp}/rice-gravacao.pid"
agora() { date +%F_%H-%M-%S; }
avisar() { notify-send -a "Captura" -i "$2" "$1" "${3:-}"; }

# seleção no estilo do rice: véu de tinta, contorno cobre
slurp_mucha() { slurp -d -b '3A332855' -c 'B0683Aff' -w 2 -B '00000000' "$@"; }

# retângulos das janelas visíveis (para escolher uma com um clique)
janelas() {
    hyprctl -j monitors | python3 -I -c '
import json, subprocess, sys
ws = {m["activeWorkspace"]["id"] for m in json.load(sys.stdin)}
for c in json.loads(subprocess.run(["hyprctl", "-j", "clients"], capture_output=True, text=True).stdout):
    if c["workspace"]["id"] in ws and c["mapped"] and not c["hidden"]:
        (x, y), (w, h) = c["at"], c["size"]
        print(f"{x},{y} {w}x{h}")'
}

gravando() { [ -f "$pidf" ] && kill -0 "$(cat "$pidf")" 2>/dev/null; }

case "${1:-}" in
area|janela|tela)
    mkdir -p "$fotos"
    arq="$fotos/$(agora).png"
    case "$1" in
        area)   geo=$(slurp_mucha) || exit 0; grim -g "$geo" "$arq" ;;
        janela) geo=$(janelas | slurp_mucha -r) || exit 0; grim -g "$geo" "$arq" ;;
        tela)   grim "$arq" ;;
    esac || exit 1
    if [ "${2:-}" = anotar ]; then
        # satty: Enter copia e salva por cima; Esc descarta as anotações
        satty --filename "$arq" --output-filename "$arq" --early-exit \
              --copy-command wl-copy --actions-on-enter save-to-clipboard,save-to-file
    else
        wl-copy --type image/png < "$arq"
    fi
    avisar "Screenshot copiado" "$arq" "${arq/#$HOME/\~}"
    ;;

gravar)
    gravando && exec "$0" parar
    mkdir -p "$videos"
    arq="$videos/$(agora).mp4"
    args=(-y -c h264_vaapi -d /dev/dri/renderD128 -f "$arq")
    case "${2:-tela}" in
        area) geo=$(slurp_mucha) || exit 0; args+=(-g "$geo") ;;
        tela) args+=(-o "$(hyprctl -j monitors | python3 -I -c 'import json,sys; print(next(m["name"] for m in json.load(sys.stdin) if m["focused"]))')") ;;
    esac
    [ "${3:-}" = som ] && args+=(--audio="$(pactl get-default-sink).monitor")
    wf-recorder "${args[@]}" >/dev/null 2>&1 &
    echo $! > "$pidf"
    echo "$arq" > "$pidf.arq"
    qs ipc call gravacao inicio >/dev/null 2>&1
    ;;

parar)
    gravando || exit 0
    kill -INT "$(cat "$pidf")"
    while kill -0 "$(cat "$pidf")" 2>/dev/null; do sleep 0.1; done
    arq=$(cat "$pidf.arq" 2>/dev/null)
    rm -f "$pidf" "$pidf.arq"
    qs ipc call gravacao fim >/dev/null 2>&1
    avisar "Gravação salva" "video-x-generic" "${arq/#$HOME/\~}"
    ;;

gravando) gravando ;;

*) sed -n 2,7p "$0"; exit 2 ;;
esac
