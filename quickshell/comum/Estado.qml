pragma Singleton

import QtQuick
import Quickshell

// Estado compartilhado entre painel e notificações.
Singleton {
    property bool naoPerturbe: false
    property bool painelAberto: false
}
