import QtQuick
import QtQuick.Layouts
import "../comum"

// Medidor da sessão do Claude Code no painel: barra da janela de 5 h,
// com renovação e uso da semana embaixo. Só leitura.
RowLayout {
    id: raiz
    required property var uso          // ClaudeUso
    visible: uso.temDados
    spacing: Tema.px(12)

    readonly property real v: Math.max(0, Math.min(1, uso.sessao / 100))
    readonly property color corNivel: uso.sessao >= 90 ? Tema.cobreEscuro : uso.sessao >= 70 ? Tema.ouro : Tema.salvia

    Accessible.role: Accessible.ProgressBar
    Accessible.name: "Sessão do Claude Code: " + Math.round(uso.sessao) + "%"

    Text {
        text: "󰚩"
        font.family: Tema.mono
        font.pixelSize: Tema.px(16)
        color: Tema.salviaEscura
        Layout.preferredWidth: Tema.px(20)
        horizontalAlignment: Text.AlignHCenter
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tema.px(3)
        Item {
            Layout.fillWidth: true
            implicitHeight: Tema.px(10)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: Tema.px(6); radius: height / 2
                color: Tema.trilho
                Rectangle {
                    width: parent.width * raiz.v; height: parent.height; radius: parent.radius
                    color: raiz.corNivel
                    Behavior on width { NumberAnimation { duration: 250 } }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            text: "Claude · " + (raiz.uso.sessaoRenovou ? "sessão nova"
                  : raiz.uso.renova !== "" ? "renova " + raiz.uso.renova : "sessão")
                  + " · semana " + Math.round(raiz.uso.semana) + "%"
            elide: Text.ElideRight
            font.family: Tema.ui
            font.pixelSize: Tema.px(12)
            color: Tema.tintaSuave
        }
    }

    Text {
        text: Math.round(raiz.uso.sessao) + "%"
        font.family: Tema.ui
        font.pixelSize: Tema.px(14)
        color: Tema.tinta
        Layout.preferredWidth: Tema.px(40)
        horizontalAlignment: Text.AlignRight
    }
}
