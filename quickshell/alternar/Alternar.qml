import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../comum"

// Alt+Tab com prévia ao vivo das janelas, na ordem do histórico de foco.
// Alt+Tab / Alt+Shift+Tab avançam/voltam (binds no Hyprland chamam o IPC);
// soltar o Alt foca a escolhida (bind de release + Keys.onReleased aqui).
//   qs ipc call alternar proxima|anterior|confirmar|cancelar
Scope {
    id: raiz

    property bool aberto: false
    property var janelas: []          // [{ endereco, titulo, classe, area, toplevel }]
    property int indice: 0
    property int passoPendente: 0     // Tabs que chegaram antes da lista ficar pronta

    readonly property var romanos: ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    function normalizar(e) { return String(e).replace(/^0x/, "").toLowerCase() }

    function passo(d) {
        if (!aberto) {
            passoPendente = d
            Hyprland.refreshToplevels()
            leitor.running = true
            return
        }
        if (janelas.length) indice = (indice + d + janelas.length) % janelas.length
        semTab.restart()
    }

    function montar(json) {
        const tops = Hyprland.toplevels.values
        const lista = JSON.parse(json)
            .filter(c => c.mapped && c.workspace.id > 0)
            .sort((a, b) => a.focusHistoryID - b.focusHistoryID)
            .map(c => ({
                endereco: c.address,
                titulo: c.title || c.class,
                classe: c.class,
                area: c.workspace.id,
                toplevel: tops.find(t => normalizar(t.address) === normalizar(c.address)) ?? null
            }))
        if (lista.length === 0) return
        janelas = lista
        indice = lista.length > 1 ? (passoPendente < 0 ? lista.length - 1 : 1) : 0
        passoPendente = 0
        aberto = true
        semTab.restart()
    }

    // rede de segurança: sem Tab por 1,2 s, escolhe a selecionada
    Timer { id: semTab; interval: 1200; onTriggered: raiz.confirmar() }

    function confirmar() {
        if (!aberto) return
        const j = janelas[indice]
        aberto = false
        semTab.stop()
        if (j) Hyprland.dispatch(`hl.dsp.focus({ window = "address:${j.endereco}" })`)
    }
    function cancelar() { aberto = false; semTab.stop() }

    Process {
        id: leitor
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector { onStreamFinished: raiz.montar(text) }
    }

    IpcHandler {
        target: "alternar"
        function proxima(): void { raiz.passo(1) }
        function anterior(): void { raiz.passo(-1) }
        function confirmar(): void { raiz.confirmar() }
        function cancelar(): void { raiz.cancelar() }
    }

    PanelWindow {
        visible: raiz.aberto
        anchors { top: true; bottom: true; left: true; right: true }
        color: Qt.rgba(58 / 255, 51 / 255, 40 / 255, 0.25)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        // sem foco de teclado: o Alt solto chega ao Hyprland (bind de release)
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "mucha-alternar"

        MouseArea { anchors.fill: parent; onClicked: raiz.cancelar() }

        Item {
            anchors.fill: parent
            focus: raiz.aberto
            Keys.onPressed: e => {
                if (e.key === Qt.Key_Escape) raiz.cancelar()
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) raiz.confirmar()
                else if (e.key === Qt.Key_Backtab || e.key === Qt.Key_Left) raiz.passo(-1)
                else if (e.key === Qt.Key_Tab || e.key === Qt.Key_Right) raiz.passo(1)
                else return
                e.accepted = true
            }
            Keys.onReleased: e => { if (e.key === Qt.Key_Alt) raiz.confirmar() }
        }

        Rectangle {
            id: faixa
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, linha.implicitWidth + 40)
            height: linha.implicitHeight + 40
            radius: 6
            color: Tema.creme
            border.color: Tema.ouro
            border.width: 1.2
            clip: true

            Rectangle {
                anchors.fill: parent; anchors.margins: 5; radius: 3; color: "transparent"
                border.color: Qt.rgba(184 / 255, 149 / 255, 90 / 255, 0.45); border.width: 1
            }

            Flickable {
                id: rolagem
                anchors.fill: parent
                anchors.margins: 20
                contentWidth: linha.implicitWidth
                interactive: contentWidth > width
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: linha
                    spacing: 14

                    Repeater {
                        model: raiz.janelas
                        delegate: Rectangle {
                            id: cartao
                            required property var modelData
                            required property int index
                            readonly property bool escolhido: index === raiz.indice
                            width: 230
                            height: 186
                            radius: 8
                            color: escolhido ? Tema.salviaClara : Tema.pergaminho
                            border.color: escolhido ? Tema.cobre : "#D5C7A8"
                            border.width: escolhido ? 2.4 : 1

                            onEscolhidoChanged: if (escolhido) {
                                const x = cartao.x
                                if (x < rolagem.contentX) rolagem.contentX = x
                                else if (x + width > rolagem.contentX + rolagem.width)
                                    rolagem.contentX = x + width - rolagem.width
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 4
                                    color: Tema.trilho
                                    clip: true
                                    ScreencopyView {
                                        anchors.fill: parent
                                        captureSource: raiz.aberto ? cartao.modelData.toplevel?.wayland ?? null : null
                                        live: true
                                        constraintSize: Qt.size(width, height)
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Text {
                                        Layout.fillWidth: true
                                        text: cartao.modelData.titulo
                                        elide: Text.ElideRight
                                        font.family: Tema.ui; font.pixelSize: 13
                                        font.weight: cartao.escolhido ? Font.DemiBold : Font.Normal
                                        color: Tema.tinta
                                    }
                                    Text {
                                        text: raiz.romanos[cartao.modelData.area] ?? cartao.modelData.area
                                        font.family: "Alegreya Sans"; font.pixelSize: 12
                                        color: Tema.cobreEscuro
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { raiz.indice = cartao.index; raiz.confirmar() }
                            }
                        }
                    }
                }
            }
        }
    }
}
