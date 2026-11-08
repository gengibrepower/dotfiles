import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../comum"

// Menu de captura (Print) + indicador de gravação.
// O trabalho fica em hypr/scripts/captura.sh; aqui só se escolhe.
//   qs ipc call captura abrir     qs ipc call gravacao inicio|fim
Scope {
    id: raiz

    property bool aberto: false
    property bool anotar: false
    property bool som: false
    property bool gravando: false
    property int segundos: 0
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/captura.sh"

    function abrir() { aberto = true }
    function fechar() { aberto = false }

    // fecha o menu e espera ele sumir da tela antes de capturar
    property var pendente: []
    Timer { id: atraso; interval: 260; onTriggered: Quickshell.execDetached([raiz.script].concat(raiz.pendente)) }
    function executar(args) { pendente = args; fechar(); atraso.restart() }

    function foto(modo) { executar(anotar ? [modo, "anotar"] : [modo]) }
    function gravar(modo) { executar(som ? ["gravar", modo, "som"] : ["gravar", modo]) }

    IpcHandler {
        target: "captura"
        function abrir(): void { raiz.abrir() }
        function toggle(): void { raiz.aberto ? raiz.fechar() : raiz.abrir() }
    }
    IpcHandler {
        target: "gravacao"
        function inicio(): void { raiz.segundos = 0; raiz.gravando = true }
        function fim(): void { raiz.gravando = false }
    }
    Timer { interval: 1000; repeat: true; running: raiz.gravando; onTriggered: raiz.segundos++ }

    function relogio(s) {
        const m = Math.floor(s / 60), r = s % 60
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }

    // ---- menu ----
    PanelWindow {
        visible: raiz.aberto
        anchors { top: true; bottom: true; left: true; right: true }
        color: Tema.veu
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "mucha-captura"

        MouseArea { anchors.fill: parent; onClicked: raiz.fechar() }

        Rectangle {
            id: cartao
            anchors.centerIn: parent
            width: 460
            height: coluna.implicitHeight + 48
            radius: 6
            color: Tema.creme
            border.color: Tema.ouro
            border.width: 1.2
            focus: raiz.aberto

            Keys.onPressed: e => {
                const t = e.text
                if (e.key === Qt.Key_Escape) raiz.fechar()
                else if (e.key === Qt.Key_Return || t === "a") raiz.foto("area")
                else if (t === "j") raiz.foto("janela")
                else if (t === "t") raiz.foto("tela")
                else if (t === "g") raiz.gravar("area")
                else if (t === "G") raiz.gravar("tela")
                else if (t === "n") raiz.anotar = !raiz.anotar
                else if (t === "s") raiz.som = !raiz.som
                else return
                e.accepted = true
            }

            MouseArea { anchors.fill: parent }
            Rectangle {
                anchors.fill: parent; anchors.margins: 5; radius: 3; color: "transparent"
                border.color: Tema.fileteOuro; border.width: 1
            }

            component Botao: Rectangle {
                id: b
                property string glifo
                property string rotulo
                property string tecla
                property color corGlifo: Tema.cobreEscuro
                signal acionado()
                Layout.fillWidth: true
                implicitHeight: 74
                radius: 8
                color: ab.containsMouse ? Tema.salviaClara : Tema.pergaminho
                border.color: ab.containsMouse ? Tema.salvia : Tema.linha
                border.width: 1
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    Text { Layout.alignment: Qt.AlignHCenter; text: b.glifo; font.family: Tema.mono; font.pixelSize: 22; color: b.corGlifo }
                    Text { Layout.alignment: Qt.AlignHCenter; text: b.rotulo; font.family: Tema.ui; font.pixelSize: 14; color: Tema.tinta }
                    Text { Layout.alignment: Qt.AlignHCenter; text: b.tecla; font.family: Tema.mono; font.pixelSize: 11; color: Tema.tintaSuave }
                }
                MouseArea { id: ab; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.acionado() }
            }

            component Opcao: Rectangle {
                id: o
                property string rotulo
                property string tecla
                property bool ligado
                signal alternado()
                implicitHeight: 32
                implicitWidth: lo.implicitWidth + 28
                radius: height / 2
                color: ligado ? Tema.salviaClara : (ao.containsMouse ? Tema.trilho : "transparent")
                border.color: ligado ? Tema.salvia : Tema.linha
                border.width: 1
                Text {
                    id: lo
                    anchors.centerIn: parent
                    text: (o.ligado ? "✓ " : "") + o.rotulo + "  " + o.tecla
                    font.family: Tema.ui; font.pixelSize: 13
                    color: o.ligado ? Tema.salviaEscura : Tema.tinta
                }
                MouseArea { id: ao; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: o.alternado() }
            }

            ColumnLayout {
                id: coluna
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                Text { text: "Capturar"; font.family: Tema.display; font.pixelSize: 26; color: Tema.cobreEscuro }

                Text { text: "Screenshot"; font.family: Tema.ui; font.pixelSize: 13; font.capitalization: Font.SmallCaps; font.letterSpacing: 1.2; color: Tema.salviaEscura }
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Botao { glifo: "󰩭"; rotulo: "Área"; tecla: "a"; onAcionado: raiz.foto("area") }
                    Botao { glifo: "󰖯"; rotulo: "Janela"; tecla: "j"; onAcionado: raiz.foto("janela") }
                    Botao { glifo: "󰍹"; rotulo: "Tela"; tecla: "t"; onAcionado: raiz.foto("tela") }
                }

                Text { text: "● Gravar vídeo"; font.family: Tema.ui; font.pixelSize: 13; font.capitalization: Font.SmallCaps; font.letterSpacing: 1.2; color: Tema.salviaEscura }
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Botao { glifo: "󰩭"; corGlifo: Tema.vermelho; rotulo: "Área"; tecla: "g"; onAcionado: raiz.gravar("area") }
                    Botao { glifo: "󰍹"; corGlifo: Tema.vermelho; rotulo: "Tela"; tecla: "G"; onAcionado: raiz.gravar("tela") }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Opcao { rotulo: "Anotar"; tecla: "n"; ligado: raiz.anotar; onAlternado: raiz.anotar = !raiz.anotar }
                    Opcao { rotulo: "Som do sistema"; tecla: "s"; ligado: raiz.som; onAlternado: raiz.som = !raiz.som }
                    Item { Layout.fillWidth: true }
                    Text { text: "Esc fecha"; font.family: Tema.ui; font.pixelSize: 12; color: Tema.tintaSuave }
                }
            }
        }
    }

    // ---- indicador de gravação (clique para parar; Print também para) ----
    PanelWindow {
        visible: raiz.gravando
        anchors.top: true
        margins.top: 8
        exclusiveZone: 0
        implicitWidth: 150
        implicitHeight: 30
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "mucha-gravando"

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: pa.containsMouse ? Tema.cobreEscuro : Tema.creme
            border.color: Tema.cobreEscuro
            border.width: 1.2
            Row {
                anchors.centerIn: parent
                spacing: 8
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 10; height: 10; radius: 5
                    color: pa.containsMouse ? Tema.creme : Tema.vermelho
                    SequentialAnimation on opacity {
                        running: raiz.gravando; loops: Animation.Infinite
                        NumberAnimation { to: 0.25; duration: 700 }
                        NumberAnimation { to: 1; duration: 700 }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: pa.containsMouse ? "parar" : raiz.relogio(raiz.segundos)
                    font.family: Tema.mono; font.pixelSize: 13
                    color: pa.containsMouse ? Tema.creme : Tema.tinta
                }
            }
            MouseArea {
                id: pa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached([raiz.script, "parar"])
            }
        }
    }
}
