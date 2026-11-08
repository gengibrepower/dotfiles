import QtQuick
import QtQuick.Layouts
import "../comum"

// Ícone + trilho com puxador + porcentagem. Arraste, clique ou role.
RowLayout {
    id: raiz

    property real valor: 0          // 0..1
    property string icone: ""
    property string rotulo: ""      // para leitores de tela
    property bool apagado: false    // ex.: mudo
    signal mover(real v)
    signal clicarIcone()

    spacing: Tema.px(12)

    Text {
        text: raiz.icone
        font.family: Tema.mono
        font.pixelSize: Tema.px(16)
        color: raiz.apagado ? Tema.tintaSuave : Tema.salviaEscura
        Layout.preferredWidth: Tema.px(20)
        horizontalAlignment: Text.AlignHCenter
        MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: raiz.clicarIcone() }
    }

    Item {
        id: trilho
        Layout.fillWidth: true
        implicitHeight: Tema.px(22)
        Accessible.role: Accessible.Slider
        Accessible.name: raiz.rotulo

        readonly property real v: Math.max(0, Math.min(1, raiz.valor))

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: Tema.px(6); radius: height / 2
            color: Tema.trilho
            Rectangle {
                width: parent.width * trilho.v; height: parent.height; radius: height / 2
                color: raiz.apagado ? Tema.salvia : Tema.cobre
            }
        }
        Rectangle {
            x: trilho.v * trilho.width - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: Tema.px(14); height: width; radius: width / 2
            color: Tema.creme
            border.color: raiz.apagado ? Tema.salvia : Tema.cobre
            border.width: 1.6 * Tema.k
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            function emitir(mx) { raiz.mover(Math.max(0, Math.min(1, mx / width))) }
            onPressed: m => emitir(m.x)
            onPositionChanged: m => { if (pressed) emitir(m.x) }
            onWheel: w => raiz.mover(Math.max(0, Math.min(1, raiz.valor + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
    }

    Text {
        text: Math.round(trilho.v * 100) + "%"
        font.family: Tema.ui
        font.pixelSize: Tema.px(14)
        font.weight: Font.Medium
        color: Tema.tinta
        Layout.preferredWidth: Tema.px(38)
        horizontalAlignment: Text.AlignRight
    }
}
