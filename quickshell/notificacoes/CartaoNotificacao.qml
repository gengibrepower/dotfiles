import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../comum"

// Um cartão: cabeçalho (ícone, app, hora), título, corpo, ações e barra de tempo.
Item {
    id: cartao

    required property Notification notificacao
    readonly property bool critica: notificacao.urgency === NotificationUrgency.Critical
    readonly property int duracao: notificacao.expireTimeout > 0 ? notificacao.expireTimeout : 6000
    readonly property var acoes: notificacao.actions.filter(a => a.identifier !== "default")
    readonly property var acaoPadrao: notificacao.actions.find(a => a.identifier === "default") ?? null
    readonly property date chegada: new Date()
    property real restante: 1.0

    width: Tema.px(384)
    implicitHeight: conteudo.implicitHeight + Tema.px(18) + Tema.px(16)

    function fechar() { notificacao.dismiss() }

    Cartela {
        anchors.fill: parent
        corBorda: cartao.critica ? Tema.cobreEscuro : Tema.borda
        espessura: (cartao.critica ? 2.5 : 2) * Tema.k
    }

    // tempo até expirar (pausa com o mouse em cima; críticas não expiram)
    NumberAnimation on restante {
        id: contagem
        running: !cartao.critica
        paused: running && hover.hovered
        from: 1; to: 0
        duration: cartao.duracao
        onFinished: cartao.notificacao.expire()
    }

    HoverHandler { id: hover }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: {
            if (cartao.acaoPadrao) cartao.acaoPadrao.invoke()
            else cartao.fechar()
        }
    }
    TapHandler {
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        onTapped: cartao.fechar()
    }

    ColumnLayout {
        id: conteudo
        anchors {
            left: parent.left; right: parent.right; top: parent.top
            leftMargin: Tema.px(28); rightMargin: Tema.px(28); topMargin: Tema.px(18)
        }
        spacing: Tema.px(6)

        // cabeçalho
        RowLayout {
            Layout.fillWidth: true
            spacing: Tema.px(10)

            Rectangle {
                implicitWidth: Tema.px(32); implicitHeight: Tema.px(32)
                radius: width / 2
                color: cartao.critica ? Tema.cobreEscuro : Tema.salviaClara
                border.color: Tema.borda
                border.width: 1.2 * Tema.k

                ClippingRectangle {
                    id: imagem
                    anchors.fill: parent
                    anchors.margins: 1.2 * Tema.k
                    radius: width / 2
                    color: "transparent"
                    visible: cartao.notificacao.image !== ""
                    Image {
                        anchors.fill: parent
                        source: cartao.notificacao.image
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(64, 64)
                    }
                }
                IconImage {
                    id: iconeApp
                    anchors.centerIn: parent
                    implicitSize: Tema.px(18)
                    visible: !imagem.visible && cartao.notificacao.appIcon !== "" && status === Image.Ready
                    source: cartao.notificacao.appIcon !== ""
                            ? Quickshell.iconPath(cartao.notificacao.appIcon, true) : ""
                }
                Text {
                    anchors.centerIn: parent
                    visible: !imagem.visible && !iconeApp.visible
                    text: cartao.critica ? "" : ""   // triângulo / sino
                    font.family: Tema.mono
                    font.pixelSize: Tema.px(14)
                    color: cartao.critica ? Tema.creme : Tema.salviaEscura
                }
            }

            Text {
                text: (cartao.notificacao.appName || "Sistema").toUpperCase()
                font.family: Tema.ui
                font.pixelSize: Tema.px(12)
                font.letterSpacing: Tema.px(12) * 0.1
                color: Tema.tintaSuave
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                id: quando
                font.family: Tema.ui
                font.pixelSize: Tema.px(12)
                color: Tema.tintaSuave
                text: cartao.critica ? "fica até dispensar" : rotuloTempo()
                function rotuloTempo() {
                    const min = Math.floor((Date.now() - cartao.chegada.getTime()) / 60000)
                    return min < 1 ? "agora" : `há ${min} min`
                }
                Timer {
                    interval: 30000; running: !cartao.critica; repeat: true
                    onTriggered: quando.text = quando.rotuloTempo()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: Tema.px(2)
            text: cartao.notificacao.summary
            font.family: Tema.ui
            font.pixelSize: Tema.px(16.5)
            font.weight: Font.Bold
            color: Tema.tinta
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: cartao.notificacao.body
            textFormat: Text.StyledText
            font.family: Tema.ui
            font.pixelSize: Tema.px(14.5)
            lineHeight: 1.15
            color: Tema.tinta
            linkColor: Tema.cobreEscuro
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        // ações: a primeira é a principal
        Flow {
            Layout.fillWidth: true
            Layout.topMargin: Tema.px(6)
            visible: cartao.acoes.length > 0
            spacing: Tema.px(8)

            Repeater {
                model: cartao.acoes
                delegate: Rectangle {
                    id: botao
                    required property NotificationAction modelData
                    required property int index
                    readonly property bool principal: index === 0

                    implicitHeight: Tema.px(34)
                    implicitWidth: rotulo.implicitWidth + Tema.px(28)
                    radius: height / 2
                    color: principal ? (area.containsMouse ? Tema.borda : Tema.cobreEscuro)
                                     : (area.containsMouse ? Tema.trilho : Tema.pergaminho)
                    border.color: principal ? Tema.cobreEscuro : Tema.ouro
                    border.width: 1.2 * Tema.k

                    Text {
                        id: rotulo
                        anchors.centerIn: parent
                        text: botao.modelData.text
                        font.family: Tema.ui
                        font.pixelSize: Tema.px(14)
                        font.weight: botao.principal ? Font.DemiBold : Font.Normal
                        color: botao.principal ? Tema.creme : Tema.tinta
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: botao.modelData.invoke()
                    }
                }
            }
        }

        // barra de tempo
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Tema.px(4)
            visible: !cartao.critica
            implicitHeight: 2 * Tema.k
            radius: height / 2
            color: Tema.trilho
            Rectangle {
                width: parent.width * cartao.restante
                height: parent.height
                radius: height / 2
                color: Tema.cobre
            }
        }
    }
}
