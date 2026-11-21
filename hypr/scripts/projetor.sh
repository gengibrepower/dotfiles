#!/usr/bin/env bash
# projetor.sh [estender|espelhar|externo|interno|alternar|desconectou]
# Modo de tela com monitor externo / projetor (HDMI). Super+Shift+P alterna:
#   estender -> espelhar -> externo (só projetor) -> estender ...
# "desconectou" é chamado pelo hook monitor.removed: sem externo, religa a tela interna
# (evita ficar com tudo apagado ao puxar o cabo no modo "externo").
INTERNA="eDP-1"
ESTADO="${XDG_STATE_HOME:-$HOME/.local/state}/rice/projetor"
mkdir -p "$(dirname "$ESTADO")"

externo() { hyprctl monitors all -j | python3 -I -c "
import json,sys
m=[x['name'] for x in json.load(sys.stdin) if x['name'] != '$INTERNA']
print(m[0] if m else '')"; }

avisar() { notify-send -a Projetor -i video-display "Projetor" "$1"; }
regra() { hyprctl eval "hl.monitor({ $1 })" >/dev/null; }
interna_ligada() { regra "output = \"$INTERNA\", mode = \"preferred\", position = \"0x0\", scale = 1.5"; }

EXT="$(externo)"
modo="${1:-alternar}"

if [ "$modo" = desconectou ]; then
    sleep 0.5
    [ -z "$(externo)" ] && interna_ligada && echo estender >"$ESTADO"
    exit 0
fi

if [ -z "$EXT" ]; then
    [ "$modo" = interno ] && interna_ligada
    avisar "Nenhum monitor externo conectado."
    exit 0
fi

if [ "$modo" = alternar ]; then
    case "$(cat "$ESTADO" 2>/dev/null)" in
        estender) modo=espelhar ;;
        espelhar) modo=externo ;;
        *)        modo=estender ;;
    esac
fi

case "$modo" in
    estender)
        interna_ligada
        regra "output = \"$EXT\", mode = \"preferred\", position = \"auto-right\", scale = \"auto\""
        avisar "Estender: $EXT à direita da tela do notebook." ;;
    espelhar)
        interna_ligada
        regra "output = \"$EXT\", mode = \"preferred\", position = \"auto-right\", scale = \"auto\", mirror = \"$INTERNA\""
        avisar "Espelhar: $EXT mostra a mesma imagem do notebook." ;;
    externo)
        regra "output = \"$EXT\", mode = \"preferred\", position = \"0x0\", scale = \"auto\""
        regra "output = \"$INTERNA\", disabled = true"
        avisar "Só $EXT: tela do notebook desligada." ;;
    interno)
        interna_ligada
        regra "output = \"$EXT\", disabled = true"
        avisar "Só o notebook: $EXT desligado." ;;
    *) echo "uso: $0 [estender|espelhar|externo|interno|alternar]" >&2; exit 2 ;;
esac
echo "$modo" >"$ESTADO"
