import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../comum"

// Painel de status sob demanda (Super+Esc ou o puxador no topo da tela).
// IPC: qs ipc call painel toggle
Scope {
    id: raiz

    readonly property string home: Quickshell.env("HOME")
    property real brilho: 1
    property string rede: "…"
    property string confirmando: ""      // ação de sessão aguardando 2º clique
    property bool sessaoAberta: false

    function abrir() {
        sessaoAberta = false; confirmando = ""
        lerBrilho.running = true
        lerRede.running = true
        Estado.painelAberto = true
    }
    function fechar() { Estado.painelAberto = false }

    IpcHandler {
        target: "painel"
        function toggle(): void { Estado.painelAberto ? raiz.fechar() : raiz.abrir() }
        function abrir(): void { raiz.abrir() }
        function fechar(): void { raiz.fechar() }
    }

    // ---- dados ----
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    readonly property var saida: Pipewire.defaultAudioSink?.audio ?? null

    Process {
        id: lerBrilho
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const campos = text.trim().split(",")
                if (campos.length >= 4) raiz.brilho = parseInt(campos[3]) / 100
            }
        }
    }
    function definirBrilho(v) {
        brilho = Math.max(0.01, v)
        Quickshell.execDetached(["brightnessctl", "-q", "set", Math.round(brilho * 100) + "%"])
    }

    Process {
        id: lerRede
        command: ["nmcli", "-t", "-f", "TYPE,NAME", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: {
                const linhas = text.trim().split("\n").filter(l => l && !l.startsWith("loopback") && !l.startsWith("bridge"))
                const wifi = linhas.find(l => l.startsWith("802-11-wireless:"))
                const cabo = linhas.find(l => l.startsWith("802-3-ethernet:"))
                raiz.rede = wifi ? wifi.slice(wifi.indexOf(":") + 1) : (cabo ? "cabo" : "desconectado")
            }
        }
    }

    readonly property var bateria: UPower.displayDevice
    readonly property int pctBateria: {
        const p = bateria?.percentage ?? 0
        return Math.round(p <= 1 ? p * 100 : p)
    }
    function textoBateria() {
        if (!bateria || !bateria.isPresent) return "sem bateria"
        const st = bateria.state
        let s = pctBateria + "%"
        if (st === UPowerDeviceState.Charging) s += " · carregando"
        else if (!UPower.onBattery) s += " · tomada"
        else if (bateria.timeToEmpty > 0) {
            const h = Math.floor(bateria.timeToEmpty / 3600), m = Math.round((bateria.timeToEmpty % 3600) / 60)
            s += ` · ${h}h${String(m).padStart(2, "0")}`
        }
        return s
    }
    function iconeBateria() {
        if (bateria?.state === UPowerDeviceState.Charging) return ""
        const p = pctBateria
        return p > 85 ? "" : p > 60 ? "" : p > 35 ? "" : p > 12 ? "" : ""
    }
    readonly property var perfis: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    readonly property var nomesPerfis: ["economia", "equilibrado", "desempenho"]
    function proximoPerfil() {
        const i = perfis.indexOf(PowerProfiles.profile)
        PowerProfiles.profile = perfis[(i + 1) % perfis.length]
    }

    readonly property var adaptador: Bluetooth.defaultAdapter
    function textoBluetooth() {
        if (!adaptador) return "sem adaptador"
        if (!adaptador.enabled) return "desligado"
        const c = Bluetooth.devices.values.find(d => d.connected)
        return c ? c.name : "ligado"
    }

    readonly property var dias: ["domingo", "segunda", "terça", "quarta", "quinta", "sexta", "sábado"]
    readonly property var meses: ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"]
    SystemClock { id: relogio; precision: SystemClock.Minutes }

    readonly property var acoesSessao: [
        { id: "bloquear",  rotulo: "Bloquear",  cmd: ["loginctl", "lock-session"], confirmar: false },
        { id: "suspender", rotulo: "Suspender", cmd: ["systemctl", "suspend"], confirmar: false },
        { id: "sair",      rotulo: "Sair",      cmd: ["sh", "-c", "command -v hyprshutdown >/dev/null && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"], confirmar: true },
        { id: "reiniciar", rotulo: "Reiniciar", cmd: ["systemctl", "reboot"], confirmar: true },
        { id: "desligar",  rotulo: "Desligar",  cmd: ["systemctl", "poweroff"], confirmar: true },
    ]
    function executarSessao(a) {
        if (a.confirmar && confirmando !== a.id) { confirmando = a.id; return }
        fechar()
        Quickshell.execDetached(a.cmd)
    }

    // ---- puxador no topo da tela ----
    PanelWindow {
        anchors.top: true
        exclusiveZone: 0
        implicitWidth: Tema.px(52)
        implicitHeight: Tema.px(22)
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "mucha-puxador"

        Image {
            anchors.fill: parent
            source: "file://" + raiz.home + "/.config/rice/assets/puxador.png"
            smooth: true; mipmap: true
            opacity: puxArea.containsMouse ? 1 : 0.85
        }
        MouseArea {
            id: puxArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Estado.painelAberto ? raiz.fechar() : raiz.abrir()
        }
    }

    // ---- painel ----
    PanelWindow {
        id: janela
        visible: Estado.painelAberto
        anchors { top: true; bottom: true; left: true; right: true }
        color: Qt.rgba(58 / 255, 51 / 255, 40 / 255, 0.12)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "mucha-painel"

        MouseArea { anchors.fill: parent; onClicked: raiz.fechar() }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: raiz.fechar()
        }

        Item {
            id: corpo
            width: Tema.px(384)
            height: Tema.px(716)
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: Tema.px(20)
            anchors.topMargin: Tema.px(74)

            MouseArea { anchors.fill: parent }

            Arco {
                anchors.fill: parent
                raioBase: Tema.px(14)
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: Tema.px(100)
                anchors.leftMargin: Tema.px(26)
                anchors.rightMargin: Tema.px(26)
                anchors.bottomMargin: Tema.px(22)
                spacing: Tema.px(18)

                // workspaces em algarismos romanos
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["I", "II", "III", "IV", "V"]
                        delegate: Rectangle {
                            id: ws
                            required property string modelData
                            required property int index
                            readonly property int num: index + 1
                            readonly property bool ativo: Hyprland.focusedWorkspace?.id === num
                            readonly property bool ocupado: Hyprland.workspaces.values.some(w => w.id === num && w.toplevels.values.length > 0)

                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: Tema.px(44)
                            implicitWidth: Tema.px(44); implicitHeight: Tema.px(44)
                            radius: width / 2
                            color: ativo ? Tema.cobreEscuro : (wsArea.containsMouse ? Tema.pergaminho : "transparent")
                            border.color: ativo ? Tema.cobreEscuro : (ocupado ? Tema.borda : Tema.ouro)
                            border.width: 1.4 * Tema.k
                            Accessible.role: Accessible.Button
                            Accessible.name: "Workspace " + num

                            Text {
                                anchors.centerIn: parent
                                text: ws.modelData
                                // Federant desenha o V como U; Alegreya lê sem ambiguidade
                                font.family: Tema.ui
                                font.weight: Font.Medium
                                font.letterSpacing: Tema.px(0.5)
                                font.pixelSize: Tema.px(15)
                                color: ws.ativo ? Tema.creme : Tema.tinta
                            }
                            MouseArea {
                                id: wsArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${ws.num} })`)
                            }
                        }
                    }
                }

                // volume e brilho
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tema.px(14)
                    Deslizante {
                        Layout.fillWidth: true
                        rotulo: "Volume"
                        icone: raiz.saida?.muted ? "" : ""
                        apagado: raiz.saida?.muted ?? false
                        valor: raiz.saida?.volume ?? 0
                        onMover: v => { if (raiz.saida) { raiz.saida.volume = v; raiz.saida.muted = false } }
                        onClicarIcone: { if (raiz.saida) raiz.saida.muted = !raiz.saida.muted }
                    }
                    Deslizante {
                        Layout.fillWidth: true
                        rotulo: "Brilho"
                        icone: ""
                        valor: raiz.brilho
                        onMover: v => raiz.definirBrilho(v)
                    }
                }

                // blocos
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Tema.px(8)
                    columnSpacing: Tema.px(8)

                    Bloco {
                        Layout.fillWidth: true
                        icone: raiz.rede === "cabo" ? "" : ""
                        rotulo: "Rede"
                        valor: raiz.rede
                        onClicado: { raiz.fechar(); Quickshell.execDetached(["ghostty", "-e", "nmtui"]) }
                    }
                    Bloco {
                        Layout.fillWidth: true
                        icone: raiz.iconeBateria()
                        rotulo: "Bateria · " + raiz.nomesPerfis[Math.max(0, raiz.perfis.indexOf(PowerProfiles.profile))]
                        valor: raiz.textoBateria()
                        onClicado: raiz.proximoPerfil()
                    }
                    Bloco {
                        Layout.fillWidth: true
                        icone: ""
                        rotulo: "Bluetooth"
                        valor: raiz.textoBluetooth()
                        ativo: raiz.adaptador?.enabled ?? false
                        onClicado: { if (raiz.adaptador) raiz.adaptador.enabled = !raiz.adaptador.enabled }
                    }
                    Bloco {
                        Layout.fillWidth: true
                        icone: ""
                        rotulo: "Não perturbe"
                        valor: Estado.naoPerturbe ? "ligado" : "desligado"
                        ativo: Estado.naoPerturbe
                        onClicado: Estado.naoPerturbe = !Estado.naoPerturbe
                    }
                }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#D5C29A" }

                // sessão
                RowLayout {
                    Layout.fillWidth: true
                    MouseArea {
                        Layout.fillWidth: true
                        implicitHeight: Tema.px(44)
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { raiz.sessaoAberta = !raiz.sessaoAberta; raiz.confirmando = "" }
                        Accessible.role: Accessible.Button
                        Accessible.name: "Menu de sessão"

                        RowLayout {
                            anchors.fill: parent
                            spacing: Tema.px(10)
                            Item {
                                implicitWidth: Tema.px(44); implicitHeight: Tema.px(44)
                                Image {
                                    id: fotoSessao
                                    anchors.fill: parent
                                    source: "file://" + raiz.home + "/.config/rice/assets/sessao.png"
                                    smooth: true; mipmap: true
                                    visible: false
                                }
                                Rectangle { id: mascara; anchors.fill: parent; radius: width / 2; visible: false; layer.enabled: true }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: fotoSessao
                                    maskEnabled: true
                                    maskSource: mascara
                                }
                                Rectangle {
                                    anchors.fill: parent; radius: width / 2
                                    color: "transparent"; border.color: Tema.borda; border.width: 1.6 * Tema.k
                                }
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Sessão"; font.family: Tema.ui; font.pixelSize: Tema.px(14); font.weight: Font.Medium; color: Tema.tinta }
                                Text { text: "Super + Esc fecha"; font.family: Tema.ui; font.pixelSize: Tema.px(12); color: Tema.tintaSuave }
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                    Rectangle {
                        implicitWidth: Tema.px(36); implicitHeight: Tema.px(36)
                        radius: width / 2
                        color: engArea.containsMouse ? Tema.pergaminho : "transparent"
                        border.color: "#D5C7A8"; border.width: Tema.k
                        Accessible.role: Accessible.Button
                        Accessible.name: "Configurações (dotfiles)"
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: Tema.mono
                            font.pixelSize: Tema.px(15)
                            color: Tema.salviaEscura
                        }
                        MouseArea {
                            id: engArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                raiz.fechar()
                                Quickshell.execDetached(["ghostty", "--working-directory=" + raiz.home + "/Projects/dotfiles", "-e", "nvim", "."])
                            }
                        }
                    }
                }

                // menu de sessão (ações perigosas pedem 2º clique)
                Flow {
                    Layout.fillWidth: true
                    visible: raiz.sessaoAberta
                    spacing: Tema.px(6)
                    Repeater {
                        model: raiz.acoesSessao
                        delegate: Rectangle {
                            id: bs
                            required property var modelData
                            readonly property bool pedindo: raiz.confirmando === modelData.id
                            implicitHeight: Tema.px(32)
                            implicitWidth: rotuloBs.implicitWidth + Tema.px(24)
                            radius: height / 2
                            color: pedindo ? Tema.cobreEscuro : (bsArea.containsMouse ? Tema.trilho : Tema.pergaminho)
                            border.color: pedindo ? Tema.cobreEscuro : Tema.ouro
                            border.width: 1.2 * Tema.k
                            Text {
                                id: rotuloBs
                                anchors.centerIn: parent
                                text: bs.pedindo ? bs.modelData.rotulo + "?" : bs.modelData.rotulo
                                font.family: Tema.ui
                                font.pixelSize: Tema.px(14)
                                font.weight: bs.pedindo ? Font.DemiBold : Font.Normal
                                color: bs.pedindo ? Tema.creme : Tema.tinta
                            }
                            MouseArea {
                                id: bsArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: raiz.executarSessao(bs.modelData)
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: Tema.px(92)
                    radius: Tema.px(8)
                    color: "transparent"
                    border.color: Tema.borda
                    border.width: 1.4 * Tema.k
                    clip: true
                    Image {
                        anchors.fill: parent
                        anchors.margins: 1.4 * Tema.k
                        source: "file://" + raiz.home + "/.config/rice/assets/cartela-painel.png"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true; mipmap: true
                    }
                }
            }

            // medalhão do relógio, sobre o arco
            Rectangle {
                id: medalhao
                width: Tema.px(156); height: width
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                y: Tema.px(4) - Tema.px(74)
                color: Tema.creme
                border.color: Tema.borda
                border.width: 2 * Tema.k

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Tema.sombra
                    shadowVerticalOffset: 14 * Tema.k
                    shadowBlur: 1.0
                    blurMax: 40
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6 * Tema.k
                    radius: width / 2
                    color: "transparent"
                    border.color: Tema.ouro
                    border.width: Tema.k
                }
                Column {
                    anchors.centerIn: parent
                    spacing: Tema.px(2)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(relogio.date, "HH:mm")
                        font.family: Tema.display
                        font.pixelSize: Tema.px(44)
                        color: Tema.tinta
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${raiz.dias[relogio.date.getDay()]}, ${relogio.date.getDate()} ${raiz.meses[relogio.date.getMonth()]}`
                        font.family: Tema.ui
                        font.pixelSize: Tema.px(13)
                        color: Tema.tintaSuave
                    }
                }
            }
        }
    }
}
