import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../comum"

// Bluetooth: liga/desliga, procura enquanto a página está aberta,
// clique conecta/desconecta; dispositivo novo pareia e conecta em seguida.
Subpagina {
    id: raiz

    property bool ativa: false
    readonly property var adaptador: Bluetooth.defaultAdapter
    readonly property bool ligado: adaptador?.enabled ?? false

    readonly property var dispositivos: {
        const ds = Bluetooth.devices.values.slice()
        const peso = d => d.connected ? 0 : (d.paired || d.bonded) ? 1 : 2
        return ds.filter(d => d.connected || d.paired || d.bonded || (d.name && d.name.replace(/[-:]/g, "") !== d.address.replace(/:/g, "")))
                 .sort((a, b) => peso(a) - peso(b) || (a.name || "").localeCompare(b.name || ""))
    }

    titulo: "Bluetooth"
    subtitulo: !adaptador ? "sem adaptador" : !ligado ? "desligado"
             : adaptador.discovering ? "procurando dispositivos…" : "ligado"

    // procura só enquanto a página está aberta
    function ajustarBusca() { if (adaptador && ligado) adaptador.discovering = ativa }
    onAtivaChanged: ajustarBusca()
    onLigadoChanged: ajustarBusca()

    direita: Interruptor {
        visible: raiz.adaptador !== null
        ligado: raiz.ligado
        onAlternado: raiz.adaptador.enabled = !raiz.adaptador.enabled
    }

    Column {
        width: parent.width
        spacing: Tema.px(4)

        Repeater {
            model: raiz.ligado ? raiz.dispositivos : []
            delegate: Rectangle {
                id: linha
                required property var modelData
                readonly property var d: modelData
                readonly property bool conhecido: d.paired || d.bonded
                property bool conectarAoParear: false
                readonly property bool ocupado: d.pairing || d.state === BluetoothDeviceState.Connecting
                                                || d.state === BluetoothDeviceState.Disconnecting

                Connections {
                    target: linha.d
                    function onPairedChanged() {
                        if (linha.d.paired && linha.conectarAoParear) { linha.conectarAoParear = false; linha.d.connect() }
                    }
                }

                width: parent.width
                height: Tema.px(48)
                radius: Tema.px(10)
                color: d.connected ? Tema.salviaClara : (ma.containsMouse ? Tema.pergaminho : "transparent")
                border.color: d.connected ? Tema.salvia : "transparent"
                border.width: Tema.k

                MouseArea {
                    id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const d = linha.d
                        if (linha.ocupado) return
                        if (d.connected) d.disconnect()
                        else if (linha.conhecido) d.connect()
                        else { d.trusted = true; linha.conectarAoParear = true; d.pair() }
                    }
                }

                RowLayout {
                    x: Tema.px(12); width: parent.width - Tema.px(20); height: parent.height
                    spacing: Tema.px(10)
                    Text {
                        text: {
                            const i = linha.d.icon || ""
                            return i.indexOf("headset") >= 0 || i.indexOf("headphone") >= 0 ? "󰋋"
                                 : i.indexOf("audio") >= 0 ? "󰓃" : i.indexOf("mouse") >= 0 ? "󰍽"
                                 : i.indexOf("keyboard") >= 0 ? "󰌌" : i.indexOf("phone") >= 0 ? "󰏲"
                                 : i.indexOf("joystick") >= 0 || i.indexOf("gaming") >= 0 ? "󰊴" : "󰂯"
                        }
                        font.family: Tema.mono; font.pixelSize: Tema.px(17); color: Tema.salviaEscura
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: linha.d.name || linha.d.address
                            elide: Text.ElideRight
                            font.family: Tema.ui; font.pixelSize: Tema.px(14)
                            font.weight: linha.d.connected ? Font.DemiBold : Font.Normal
                            color: Tema.tinta
                        }
                        Text {
                            text: linha.d.pairing ? "pareando…"
                                : linha.d.state === BluetoothDeviceState.Connecting ? "conectando…"
                                : linha.d.state === BluetoothDeviceState.Disconnecting ? "desconectando…"
                                : linha.d.connected ? (ma.containsMouse ? "clique para desconectar" : "conectado")
                                                      + (linha.d.batteryAvailable ? " · " + Math.round(linha.d.battery * 100) + "%" : "")
                                : linha.conhecido ? "pareado" : "novo · clique para parear"
                            font.family: Tema.ui; font.pixelSize: Tema.px(12); color: Tema.tintaSuave
                        }
                    }
                    // esquecer (só pareados)
                    Text {
                        visible: linha.conhecido && ma.containsMouse && !linha.d.connected
                        text: "esquecer"
                        font.family: Tema.ui; font.pixelSize: Tema.px(12); font.underline: esq.containsMouse
                        color: Tema.cobreEscuro
                        MouseArea { id: esq; anchors.fill: parent; anchors.margins: -Tema.px(6); hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: linha.d.forget() }
                    }
                }
            }
        }

        Text {
            visible: !raiz.ligado || raiz.dispositivos.length === 0
            width: parent.width
            topPadding: Tema.px(30)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: !raiz.adaptador ? "Nenhum adaptador Bluetooth" : !raiz.ligado ? "Bluetooth desligado"
                : "Nenhum dispositivo ainda — deixe o fone/mouse em modo de pareamento"
            font.family: Tema.ui; font.pixelSize: Tema.px(14); color: Tema.tintaSuave
        }
    }
}
