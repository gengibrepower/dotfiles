import QtQuick
import QtQuick.Layouts
import "../comum"

// Moldura das sub-páginas do painel: ‹ voltar · título · controle à direita,
// filete dourado e o conteúdo rolando embaixo.
ColumnLayout {
    id: raiz

    property string titulo
    property string subtitulo: ""
    default property alias conteudo: area.data
    property alias direita: slotDireita.data
    signal voltar()

    spacing: Tema.px(10)

    RowLayout {
        Layout.fillWidth: true
        spacing: Tema.px(8)

        Rectangle {
            implicitWidth: Tema.px(34); implicitHeight: Tema.px(34)
            radius: width / 2
            color: va.containsMouse ? Tema.pergaminho : "transparent"
            border.color: Tema.linha; border.width: Tema.k
            Accessible.role: Accessible.Button
            Accessible.name: "Voltar"
            Text {
                anchors.centerIn: parent
                text: "‹"
                font.family: Tema.ui; font.pixelSize: Tema.px(22)
                color: Tema.cobreEscuro
            }
            MouseArea { id: va; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: raiz.voltar() }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text { text: raiz.titulo; font.family: Tema.display; font.pixelSize: Tema.px(22); color: Tema.cobreEscuro }
            Text {
                visible: raiz.subtitulo !== ""
                text: raiz.subtitulo
                font.family: Tema.ui; font.pixelSize: Tema.px(12); color: Tema.tintaSuave
                elide: Text.ElideRight; Layout.fillWidth: true
            }
        }
        Item { id: slotDireita; implicitWidth: childrenRect.width; implicitHeight: childrenRect.height }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Tema.filete }

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentHeight: area.childrenRect.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Item { id: area; width: parent.width }
    }
}
