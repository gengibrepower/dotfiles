import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../comum"

// Indicador de volume/brilho: cartela de pergaminho no pé da tela, some
// sozinha. Volume vem do Pipewire (qualquer origem); brilho vem dos atalhos
// via IPC (qs ipc call osd brilho). Não aparece com o painel aberto.
Scope {
    id: raiz

    property string tipo: "volume"     // "volume" | "brilho"
    property real valor: 0
    property bool mudo: false
    property bool visivel: false

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    readonly property var saida: Pipewire.defaultAudioSink?.audio ?? null

    function mostrar(t, v, m) {
        if (!pronto.ok || Estado.painelAberto) return
        tipo = t; valor = Math.max(0, Math.min(1, v)); mudo = m
        visivel = true
        esconder.restart()
    }

    // ignora a leitura inicial do Pipewire ao subir o shell
    Timer { id: pronto; property bool ok: false; interval: 2500; running: true; onTriggered: ok = true }
    Timer { id: esconder; interval: 1400; onTriggered: raiz.visivel = false }

    Connections {
        target: raiz.saida
        function onVolumeChanged() { raiz.mostrar("volume", raiz.saida.volume, raiz.saida.muted) }
        function onMutedChanged() { raiz.mostrar("volume", raiz.saida.volume, raiz.saida.muted) }
    }

    Process {
        id: lerBrilho
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const c = text.trim().split(",")
                if (c.length >= 4) raiz.mostrar("brilho", parseInt(c[3]) / 100, false)
            }
        }
    }

    IpcHandler {
        target: "osd"
        function brilho(): void { lerBrilho.running = true }
        function volume(): void {
            if (raiz.saida) raiz.mostrar("volume", raiz.saida.volume, raiz.saida.muted)
        }
    }

    PanelWindow {
        visible: raiz.visivel || cartela.opacity > 0
        anchors.bottom: true
        margins.bottom: 56
        exclusiveZone: 0
        implicitWidth: 300
        implicitHeight: 64
        color: "transparent"
        mask: Region {}                       // não captura cliques
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "mucha-osd"

        Rectangle {
            id: cartela
            anchors.fill: parent
            anchors.margins: 6
            radius: 4
            color: Tema.creme
            border.color: Tema.ouro
            border.width: 1
            opacity: raiz.visivel ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            // filete interno, como nas cartelas do painel
            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 2
                color: "transparent"
                border.color: Qt.rgba(184 / 255, 149 / 255, 90 / 255, 0.4)
                border.width: 1
            }

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Tema.mono
                    font.pixelSize: 20
                    color: raiz.mudo ? Tema.tintaSuave : Tema.cobreEscuro
                    text: raiz.tipo === "brilho" ? "󰃠"
                        : raiz.mudo ? "󰖁"
                        : raiz.valor < 0.34 ? "󰕿" : raiz.valor < 0.67 ? "󰖀" : "󰕾"
                }

                Rectangle {
                    id: trilho
                    anchors.verticalCenter: parent.verticalCenter
                    width: 168
                    height: 6
                    radius: 3
                    color: Tema.trilho
                    Rectangle {
                        width: parent.width * raiz.valor
                        height: parent.height
                        radius: 3
                        color: raiz.mudo ? Tema.salvia : Tema.cobre
                        Behavior on width { NumberAnimation { duration: 90 } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    horizontalAlignment: Text.AlignRight
                    font.family: Tema.ui
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Tema.tinta
                    text: raiz.mudo ? "mudo" : Math.round(raiz.valor * 100) + "%"
                }
            }
        }
    }
}
