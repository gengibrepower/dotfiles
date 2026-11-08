#!/usr/bin/env bash
# Atualização do sistema — rice Mucha (Super+Shift+U ou o bloco "Sistema" do painel)
# pacman (o snap-pac tira snapshot antes/depois) → AUR (paru) → firmware → .pacnew → reinício?

cobre=$'\e[1;38;2;138;75;38m'; salvia=$'\e[38;2;79;94;69m'; suave=$'\e[38;2;110;101;83m'
erro=$'\e[1;38;2;160;51;31m'; nada=$'\e[0m'
titulo() { printf '\n%s━━ %s%s\n' "$cobre" "$1" "$nada"; }
ok()     { printf '%s✓ %s%s\n' "$salvia" "$1" "$nada"; }
nota()   { printf '%s%s%s\n' "$suave" "$1" "$nada"; }

kernel_antes=$(uname -r)
problemas=0

printf '%s❦  Atualizar o sistema%s\n' "$cobre" "$nada"
nota "Encoste o dedo no leitor (ou digite a senha) quando o sudo pedir."

titulo "Pacotes oficiais"
nota "O snap-pac guarda um snapshot antes e depois (snapper list)."
if sudo pacman -Syu; then ok "pacman em dia"; else printf '%s✗ pacman falhou%s\n' "$erro" "$nada"; problemas=1; fi

if command -v paru >/dev/null; then
    titulo "AUR"
    if paru -Sua; then ok "AUR em dia"; else printf '%s✗ paru falhou%s\n' "$erro" "$nada"; problemas=1; fi
fi

if command -v fwupdmgr >/dev/null; then
    titulo "Firmware (BIOS e afins)"
    fwupdmgr refresh >/dev/null 2>&1
    saida=$(fwupdmgr get-updates --no-unreported-check 2>/dev/null); cod=$?
    if [ "$cod" -eq 0 ]; then
        printf '%s\n' "$saida" | grep -E 'System Update|Update:$|New version|Urgency' | sed 's/^[ │└├─]*/  /'
        nota "Para instalar: fwupdmgr update (na tomada; reinicia sozinho)."
    else
        ok "nenhuma atualização de firmware"
    fi
fi

titulo "Arquivos de configuração novos (.pacnew)"
pacnew=$(pacdiff -o 2>/dev/null)
if [ -n "$pacnew" ]; then
    printf '%s\n' "$pacnew"
    nota "Revise e mescle com: sudo DIFFPROG='nvim -d' pacdiff"
else
    ok "nenhum"
fi

# kernel novo: os módulos do kernel em uso somem de /usr/lib/modules
if [ ! -d "/usr/lib/modules/$kernel_antes" ]; then
    titulo "Reinício necessário"
    printf '%sO kernel foi atualizado — reinicie para usar o novo.%s\n' "$cobre" "$nada"
fi

# atualiza o contador do painel
qs ipc call atualizacoes recontar >/dev/null 2>&1

echo
if [ "$problemas" -eq 0 ]; then ok "Tudo atualizado."; else printf '%sAlgo falhou — veja acima.%s\n' "$erro" "$nada"; fi
read -rsn1 -p "$(nota 'Qualquer tecla fecha.')"
