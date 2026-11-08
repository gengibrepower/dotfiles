//@ pragma UseQApplication
import QtQuick
import Quickshell
import "notificacoes"
import "launcher"
import "painel"

// Rice Art Nouveau "Mucha" — notificações, launcher e painel de status
ShellRoot {
    Notificacoes {}
    Launcher {}
    Painel {}
}
