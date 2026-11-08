import QtQuick
import "../comum"

// interruptor liga/desliga no estilo do rice
Rectangle {
    id: raiz
    property bool ligado
    signal alternado()
    implicitWidth: Tema.px(44); implicitHeight: Tema.px(24)
    radius: height / 2
    color: ligado ? Tema.salvia : Tema.trilho
    border.color: ligado ? Tema.salviaEscura : Tema.linha; border.width: Tema.k
    Accessible.role: Accessible.CheckBox
    Accessible.checked: ligado
    Rectangle {
        width: parent.height - Tema.px(6); height: width; radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: raiz.ligado ? parent.width - width - Tema.px(3) : Tema.px(3)
        color: Tema.creme
        border.color: raiz.ligado ? Tema.salviaEscura : Tema.ouro; border.width: Tema.k
        Behavior on x { NumberAnimation { duration: 120 } }
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: raiz.alternado() }
}
