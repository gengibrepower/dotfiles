import QtQuick
import "../comum"

// botão circular com um glifo Nerd Font (e um número opcional no canto)
Rectangle {
    id: raiz
    property string glifo
    property string dica: ""
    property int contador: 0
    property real tamanhoGlifo: Tema.px(15)
    signal clicado()
    implicitWidth: Tema.px(34); implicitHeight: Tema.px(34)
    radius: width / 2
    color: ma.containsMouse ? Tema.pergaminho : "transparent"
    border.color: Tema.linha; border.width: Tema.k
    Accessible.role: Accessible.Button
    Accessible.name: dica
    Text {
        anchors.centerIn: parent
        text: raiz.glifo
        font.family: Tema.mono; font.pixelSize: raiz.tamanhoGlifo
        color: Tema.salviaEscura
    }
    Rectangle {
        visible: raiz.contador > 0
        anchors.right: parent.right; anchors.top: parent.top
        anchors.rightMargin: -Tema.px(3); anchors.topMargin: -Tema.px(3)
        width: Math.max(height, num.implicitWidth + Tema.px(8)); height: Tema.px(16)
        radius: height / 2
        color: Tema.cobreEscuro
        Text {
            id: num
            anchors.centerIn: parent
            text: raiz.contador > 9 ? "9+" : raiz.contador
            font.family: Tema.ui; font.pixelSize: Tema.px(10); font.weight: Font.Bold
            color: Tema.creme
        }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: raiz.clicado() }
}
