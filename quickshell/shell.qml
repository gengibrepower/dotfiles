//@ pragma UseQApplication
import QtQuick
import Quickshell
import "notificacoes"
import "launcher"
import "painel"
import "osd"
import "energia"
import "atalhos"
import "captura"
import "alternar"
import "tema"

// Rice Art Nouveau "Mucha" — notificações, launcher e painel de status
ShellRoot {
    Notificacoes {}
    Launcher {}
    Painel {}
    Osd {}
    Energia {}
    Bateria {}
    Atalhos {}
    Captura {}
    Alternar {}
    Noturno {}
}
