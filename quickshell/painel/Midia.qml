import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris
import "../comum"

// o que está tocando (MPRIS): capa, título, artista e controles.
// Prefere o player tocando; senão o primeiro que existir.
Rectangle {
    id: raiz

    readonly property var player: {
        const ps = Mpris.players.values
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null
    }
    visible: player !== null
    implicitHeight: Tema.px(64)
    radius: Tema.px(12)
    color: Tema.pergaminho
    border.color: Tema.linha; border.width: Tema.k

    RowLayout {
        anchors.fill: parent
        anchors.margins: Tema.px(8)
        spacing: Tema.px(10)

        Rectangle {
            implicitWidth: Tema.px(48); implicitHeight: Tema.px(48)
            radius: Tema.px(8)
            color: Tema.trilho
            border.color: Tema.ouro; border.width: Tema.k
            clip: true
            Image {
                id: capa
                anchors.fill: parent; anchors.margins: Tema.k
                source: raiz.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(96, 96)
                asynchronous: true
            }
            Text {
                anchors.centerIn: parent
                visible: capa.status !== Image.Ready
                text: "\uf001"   // nota musical
                font.family: Tema.mono; font.pixelSize: Tema.px(20); color: Tema.salviaEscura
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: raiz.player?.trackTitle || raiz.player?.identity || ""
                elide: Text.ElideRight
                font.family: Tema.ui; font.pixelSize: Tema.px(14); font.weight: Font.DemiBold
                color: Tema.tinta
            }
            Text {
                Layout.fillWidth: true
                text: raiz.player?.trackArtist || raiz.player?.identity || ""
                elide: Text.ElideRight
                font.family: Tema.ui; font.pixelSize: Tema.px(12)
                color: Tema.tintaSuave
            }
        }
        BotaoRedondo {
            glifo: "󰒮"; dica: "Anterior"; implicitWidth: Tema.px(30); implicitHeight: Tema.px(30)
            visible: raiz.player?.canGoPrevious ?? false
            onClicado: raiz.player.previous()
        }
        BotaoRedondo {
            glifo: raiz.player?.isPlaying ? "󰏤" : "󰐊"; dica: "Tocar/pausar"
            tamanhoGlifo: Tema.px(17)
            onClicado: raiz.player.togglePlaying()
        }
        BotaoRedondo {
            glifo: "󰒭"; dica: "Próxima"; implicitWidth: Tema.px(30); implicitHeight: Tema.px(30)
            visible: raiz.player?.canGoNext ?? false
            onClicado: raiz.player.next()
        }
    }
}
