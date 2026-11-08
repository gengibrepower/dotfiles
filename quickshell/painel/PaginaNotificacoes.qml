import QtQuick
import QtQuick.Layouts
import "../comum"

// histórico das notificações da sessão (Estado.historico, mais nova primeiro)
Subpagina {
    id: raiz

    titulo: "Notificações"
    subtitulo: Estado.historico.length === 0 ? "nada por aqui"
             : Estado.historico.length === 1 ? "1 notificação" : Estado.historico.length + " notificações"

    function quando(d) {
        const min = Math.floor((Date.now() - d.getTime()) / 60000)
        if (min < 1) return "agora"
        if (min < 60) return "há " + min + " min"
        return Qt.formatTime(d, "HH:mm")
    }

    direita: Rectangle {
        visible: Estado.historico.length > 0
        implicitWidth: rl.implicitWidth + Tema.px(22); implicitHeight: Tema.px(30)
        radius: height / 2
        color: ml.containsMouse ? Tema.trilho : Tema.pergaminho
        border.color: Tema.ouro; border.width: Tema.k
        Text { id: rl; anchors.centerIn: parent; text: "Limpar"; font.family: Tema.ui; font.pixelSize: Tema.px(13); color: Tema.tinta }
        MouseArea { id: ml; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Estado.limparHistorico() }
    }

    Column {
        width: parent.width
        spacing: Tema.px(6)

        Repeater {
            model: Estado.historico
            delegate: Rectangle {
                id: item
                required property var modelData
                width: parent.width
                height: col.implicitHeight + Tema.px(16)
                radius: Tema.px(10)
                color: Tema.pergaminho
                border.color: modelData.critica ? Tema.cobre : "#D5C7A8"
                border.width: modelData.critica ? 1.4 * Tema.k : Tema.k

                ColumnLayout {
                    id: col
                    x: Tema.px(12); y: Tema.px(8)
                    width: parent.width - Tema.px(24)
                    spacing: Tema.px(2)
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: item.modelData.app.toUpperCase()
                            elide: Text.ElideRight
                            font.family: Tema.ui; font.pixelSize: Tema.px(11); font.letterSpacing: Tema.px(0.8)
                            color: item.modelData.critica ? Tema.cobreEscuro : Tema.tintaSuave
                        }
                        Text {
                            text: raiz.quando(item.modelData.hora)
                            font.family: Tema.ui; font.pixelSize: Tema.px(11); color: Tema.tintaSuave
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: item.modelData.resumo
                        wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight
                        font.family: Tema.ui; font.pixelSize: Tema.px(14); font.weight: Font.DemiBold
                        color: Tema.tinta
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: item.modelData.corpo
                        wrapMode: Text.WordWrap; maximumLineCount: 3; elide: Text.ElideRight
                        textFormat: Text.PlainText
                        font.family: Tema.ui; font.pixelSize: Tema.px(13)
                        color: Tema.tintaSuave
                    }
                }
            }
        }

        Text {
            visible: Estado.historico.length === 0
            width: parent.width
            topPadding: Tema.px(30)
            horizontalAlignment: Text.AlignHCenter
            text: "As notificações desta sessão aparecem aqui"
            font.family: Tema.ui; font.pixelSize: Tema.px(14); color: Tema.tintaSuave
        }
    }
}
