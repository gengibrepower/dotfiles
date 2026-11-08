import QtQuick
import QtQuick.Layouts
import "../comum"

// Bloco do grid 2x2: ícone, rótulo pequeno e valor.
Rectangle {
    id: raiz

    property string icone: ""
    property string rotulo: ""
    property string valor: ""
    property bool ativo: false
    signal clicado()

    implicitHeight: Tema.px(56)
    radius: Tema.px(12)
    color: ativo ? Tema.salviaClara : (area.containsMouse ? Tema.trilho : Tema.pergaminho)
    border.color: ativo ? Tema.salvia : "#D5C7A8"
    border.width: Tema.k

    Accessible.role: Accessible.Button
    Accessible.name: rotulo + ": " + valor

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tema.px(12)
        anchors.rightMargin: Tema.px(10)
        spacing: Tema.px(10)

        Text {
            text: raiz.icone
            font.family: Tema.mono
            font.pixelSize: Tema.px(16)
            color: Tema.salviaEscura
            Layout.preferredWidth: Tema.px(18)
            horizontalAlignment: Text.AlignHCenter
        }
        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Text {
                text: raiz.rotulo
                font.family: Tema.ui
                font.pixelSize: Tema.px(12)
                color: Tema.tintaSuave
            }
            Text {
                text: raiz.valor
                font.family: Tema.ui
                font.pixelSize: Tema.px(14)
                font.weight: Font.Medium
                color: Tema.tinta
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: raiz.clicado()
    }
}
