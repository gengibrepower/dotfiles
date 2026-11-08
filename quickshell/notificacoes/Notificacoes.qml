import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../comum"

// Servidor de notificações + pilha de cartões no canto superior direito.
Scope {
    id: raiz

    // "Não perturbe" (Estado.naoPerturbe): guarda as notificações, mas só mostra as críticas.

    NotificationServer {
        id: servidor
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true
            Estado.registrar(n)
        }
    }

    PanelWindow {
        id: janela

        readonly property real folga: 24   // espaço para a sombra

        visible: cartoes.count > 0
        anchors { top: true; right: true }
        margins {
            top: Tema.px(24) - folga
            right: Tema.px(20) - folga
        }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "mucha-notificacoes"

        implicitWidth: Tema.px(384) + folga * 2
        implicitHeight: Math.max(1, pilha.implicitHeight) + folga * 2

        // só os cartões recebem clique; a folga da sombra deixa passar
        mask: Region { item: pilha }

        Column {
            id: pilha
            x: janela.folga
            y: janela.folga
            spacing: Tema.px(16)

            Repeater {
                id: cartoes
                // modelo estável: cartões não são recriados quando chega outra
                model: servidor.trackedNotifications
                delegate: CartaoNotificacao {
                    required property var modelData
                    notificacao: modelData
                    visible: !Estado.naoPerturbe || critica
                }
            }
        }
    }
}
