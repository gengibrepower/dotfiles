import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../comum"

// Lista de atalhos (Super+ß ou o botão de teclado do painel).
// Os do Hyprland vêm ao vivo de `hyprctl binds -j`: cada hl.bind tem
// desc = "Grupo|Ação" em hypr/hyprland.lua; atalhos com a mesma descrição
// viram uma linha só. Os do tmux são fixos (tmux/tmux.conf).
Scope {
    id: raiz

    property bool aberto: false
    property var colunas: [[], [], []]

    readonly property var ordem: ["Apps", "Sistema", "Janelas", "Áreas", "Clipboard", "Captura", "Mídia", "tmux"]

    readonly property var tmux: [
        { acao: "Prefixo", teclas: "Ctrl + Espaço" },
        { acao: "Ir para a aba", teclas: "Alt + 1…9" },
        { acao: "Aba anterior / próxima", teclas: "Alt + h l" },
        { acao: "Aba anterior / próxima (alt.)", teclas: "Ctrl + Shift + h l" },
        { acao: "Nova aba", teclas: "prefixo  c" },
        { acao: "Dividir lado / embaixo", teclas: "prefixo  |  -" },
        { acao: "Focar painel", teclas: "prefixo  h j k l" },
        { acao: "Redimensionar painel", teclas: "prefixo  H J K L" },
        { acao: "Copiar (modo cópia)", teclas: "v  ·  y" },
        { acao: "Recarregar config", teclas: "prefixo  r" },
    ]

    function abrir() { leitor.running = true; aberto = true }
    function fechar() { aberto = false }

    IpcHandler {
        target: "atalhos"
        function toggle(): void { raiz.aberto ? raiz.fechar() : raiz.abrir() }
        function abrir(): void { raiz.abrir() }
    }

    // ---- montagem da lista ----
    readonly property var nomesTecla: ({
        "Return": "Enter", "space": "Espaço", "Escape": "Esc", "Print": "PrtSc",
        "left": "←", "right": "→", "up": "↑", "down": "↓", "ssharp": "ß",
        "mouse:272": "clique esq.", "mouse:273": "clique dir.",
        "mouse_down": "roda ↓", "mouse_up": "roda ↑",
        "XF86AudioRaiseVolume": "Vol +", "XF86AudioLowerVolume": "Vol −",
        "XF86AudioMute": "tecla mudo", "XF86AudioMicMute": "tecla mic",
        "XF86MonBrightnessUp": "Brilho +", "XF86MonBrightnessDown": "Brilho −",
        "XF86AudioNext": "Próxima", "XF86AudioPrev": "Anterior",
        "XF86AudioPlay": "Play", "XF86AudioPause": "Pause"
    })

    function mods(mask) {
        const m = []
        if (mask & 64) m.push("Super")
        if (mask & 4) m.push("Ctrl")
        if (mask & 8) m.push("Alt")
        if (mask & 1) m.push("Shift")
        return m.join(" + ")
    }
    function tecla(k) {
        if (nomesTecla[k] !== undefined) return nomesTecla[k]
        return k.length === 1 ? k.toUpperCase() : k
    }

    // junta as teclas de uma mesma ação: "Super + h j k l ← ↓ ↑ →", "Super + 1…0"
    function juntar(binds) {
        const porMods = {}
        const ordemMods = []
        for (const b of binds) {
            const m = mods(b.modmask)
            if (!(m in porMods)) { porMods[m] = []; ordemMods.push(m) }
            const t = tecla(b.key)
            if (porMods[m].indexOf(t) < 0) porMods[m].push(t)
        }
        return ordemMods.map(m => {
            let ts = porMods[m]
            if (ts.length >= 9 && ts.every(t => /^[0-9]$/.test(t))) ts = ["1…0"]
            else if (ts.length > 1) {
                const pos = ["H", "J", "K", "L", "←", "↓", "↑", "→"]
                if (ts.every(t => pos.indexOf(t) >= 0)) {
                    ts = pos.filter(p => ts.indexOf(p) >= 0)
                    if (ts.length === 8) ts = ["H J K L / setas"]
                }
            }
            const lista = ts.join(ts.every(t => t.length <= 1 || t === "1…0" || t.indexOf("setas") >= 0) ? " " : " / ")
            return m ? m + " + " + lista : lista
        }).join("\n")   // modificadores diferentes: um por linha
    }

    function montar(json) {
        const grupos = {}
        const ordemAcoes = {}
        for (const b of JSON.parse(json)) {
            const d = b.description || ""
            const sep = d.indexOf("|")
            const g = sep > 0 ? d.slice(0, sep) : "Outros"
            const a = sep > 0 ? d.slice(sep + 1) : (d || b.key)
            if (!grupos[g]) { grupos[g] = {}; ordemAcoes[g] = [] }
            if (!grupos[g][a]) { grupos[g][a] = []; ordemAcoes[g].push(a) }
            grupos[g][a].push(b)
        }
        const lista = []
        for (const g of ordem.concat(Object.keys(grupos).filter(x => ordem.indexOf(x) < 0))) {
            if (g === "tmux") { lista.push({ nome: "tmux", itens: tmux }); continue }
            if (!grupos[g]) continue
            lista.push({ nome: g, itens: ordemAcoes[g].map(a => ({ acao: a, teclas: juntar(grupos[g][a]) })) })
        }
        // distribui os grupos nas 3 colunas, sempre na mais curta
        const cols = [[], [], []], alt = [0, 0, 0]
        for (const g of lista) {
            const i = alt.indexOf(Math.min(...alt))
            cols[i].push(g)
            alt[i] += g.itens.length + 2.2
        }
        colunas = cols
    }

    Process {
        id: leitor
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector { onStreamFinished: raiz.montar(text) }
    }

    // ---- tela ----
    PanelWindow {
        visible: raiz.aberto
        anchors { top: true; bottom: true; left: true; right: true }
        color: Qt.rgba(58 / 255, 51 / 255, 40 / 255, 0.28)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "mucha-atalhos"

        MouseArea { anchors.fill: parent; onClicked: raiz.fechar() }

        Rectangle {
            id: folha
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 1180)
            height: Math.min(parent.height - 40, conteudo.implicitHeight + 64)
            radius: 6
            color: Tema.creme
            border.color: Tema.ouro
            border.width: 1.2

            focus: raiz.aberto
            Keys.onEscapePressed: raiz.fechar()
            Keys.onPressed: e => { if (e.key === Qt.Key_Q || e.key === Qt.Key_ssharp) raiz.fechar() }

            MouseArea { anchors.fill: parent }   // cliques na folha não fecham

            // filete interno
            Rectangle {
                anchors.fill: parent; anchors.margins: 5; radius: 3
                color: "transparent"
                border.color: Qt.rgba(184 / 255, 149 / 255, 90 / 255, 0.45); border.width: 1
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 28
                contentHeight: conteudo.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: conteudo
                    width: parent.width
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Atalhos"
                            font.family: Tema.display
                            font.pixelSize: 30
                            color: Tema.cobreEscuro
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Esc fecha"
                            font.family: Tema.ui; font.pixelSize: 13
                            color: Tema.tintaSuave
                        }
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Tema.ouro; opacity: 0.6 }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 28

                        Repeater {
                            model: raiz.colunas
                            delegate: ColumnLayout {
                                id: coluna
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.alignment: Qt.AlignTop
                                spacing: 16

                                Repeater {
                                    model: coluna.modelData
                                    delegate: ColumnLayout {
                                        id: grupo
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 3

                                        Text {
                                            text: grupo.modelData.nome
                                            font.family: Tema.ui; font.pixelSize: 15
                                            font.weight: Font.DemiBold
                                            font.capitalization: Font.SmallCaps
                                            font.letterSpacing: 1.2
                                            color: Tema.salviaEscura
                                            bottomPadding: 2
                                        }
                                        Repeater {
                                            model: grupo.modelData.itens
                                            delegate: RowLayout {
                                                id: linha
                                                required property var modelData
                                                Layout.fillWidth: true
                                                spacing: 10
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: linha.modelData.acao
                                                    font.family: Tema.ui; font.pixelSize: 14
                                                    color: Tema.tinta
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    Layout.maximumWidth: coluna.width * 0.7
                                                    text: linha.modelData.teclas
                                                    font.family: Tema.mono; font.pixelSize: 12
                                                    color: Tema.cobreEscuro
                                                    horizontalAlignment: Text.AlignRight
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
