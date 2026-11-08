#!/usr/bin/env bash
# tampa.sh fechou|abriu — chamado pelos binds de switch da tampa (hyprland.lua).
# Sem monitor externo, quem age é o logind: fechar = bloquear (hypridle) e suspender.
# Com monitor externo, o logind não suspende (HandleLidSwitchDocked=ignore);
# aqui só desligamos a tela interna para as janelas irem para o monitor de fora.
INTERNA="eDP-1"
externos() { hyprctl monitors all -j | python3 -I -c "
import json,sys; print(sum(1 for m in json.load(sys.stdin) if m['name'] != '$INTERNA'))"; }

case "${1:-}" in
    fechou)
        [ "$(externos)" -gt 0 ] || exit 0
        hyprctl eval "hl.monitor({ output = \"$INTERNA\", disabled = true })" >/dev/null
        ;;
    abriu)
        hyprctl eval "hl.monitor({ output = \"$INTERNA\", mode = \"preferred\", position = \"auto\", scale = \"auto\" })" >/dev/null
        ;;
    *) echo "uso: $0 fechou|abriu" >&2; exit 2 ;;
esac
