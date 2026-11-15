import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../comum"
import "busca.js" as Busca

// Launcher (Super+D): apps, arquivos, clipboard, emoji e calculadora; Tab troca o modo.
// Contas digitadas no modo apps (ex.: 2+2, =sqrt(2)) mostram o resultado no topo.
// Abre via IPC: qs ipc call launcher toggle
Scope {
    id: raiz

    property bool aberto: false
    property string modo: "apps"          // "apps" | "arquivos" | "clipboard" | "emoji" | "calc"
    readonly property var modos: ["apps", "arquivos", "clipboard", "emoji", "calc"]
    property var linhasClip: []
    property string consulta: ""
    property var resultados: []
    property int selecionado: 0
    readonly property string home: Quickshell.env("HOME")

    function abrir(m) {
        consulta = ""; selecionado = 0; modo = m || "apps"; resultados = []
        if (modo === "clipboard") lerClip.running = true
        atualizar(); aberto = true
    }
    function trocarModo() {
        modo = modos[(modos.indexOf(modo) + 1) % modos.length]
        resultados = []
        if (modo === "clipboard") lerClip.running = true
        atualizar()
    }
    function filtrarClip() {
        const q = consulta.trim().toLowerCase()
        resultados = linhasClip.filter(l => l !== "").map(l => {
            const prev = l.slice(l.indexOf("\t") + 1).replace(/\s+/g, " ").trim()
            const img = prev.startsWith("[[ binary data")
            return { tipo: "clip", linha: l, nome: img ? "imagem" : prev,
                     detalhe: img ? prev.replace(/^\[\[ binary data /, "").replace(/ \]\]$/, "") : "" }
        }).filter(it => q === "" || it.nome.toLowerCase().indexOf(q) >= 0).slice(0, 200)
        selecionado = 0
    }
    function fechar() { aberto = false }

    function atualizar() {
        if (modo === "apps") {
            const apps = Busca.buscarApps(DesktopEntries.applications.values, consulta, usosArquivo.usos)
                .concat(Busca.buscarSistema(consulta)).sort((a, b) => b.p - a.p)
            const conta = Busca.pareceConta(consulta) ? Busca.itemConta(consulta) : null
            resultados = conta ? [conta].concat(apps) : apps
            selecionado = 0
        } else if (modo === "calc") {
            const conta = Busca.itemConta(consulta)
            resultados = conta ? [conta] : []
            selecionado = 0
        } else if (modo === "emoji") {
            resultados = Busca.buscarEmojis(linhasEmoji, consulta)
            selecionado = 0
        } else if (modo === "clipboard") {
            filtrarClip()
        } else {
            atraso.restart()
        }
    }

    function lancar(item) {
        if (!item) return
        if (item.tipo === "app") {
            const e = item.entrada
            const u = Object.assign({}, usosArquivo.usos)
            u[e.id] = (u[e.id] || 0) + 1
            usosArquivo.usos = u
            arquivoUsos.writeAdapter()
            if (e.runInTerminal) Quickshell.execDetached(["ghostty", "-e"].concat(e.command))
            else e.execute()
        } else if (item.tipo === "clip") {
            Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "sh", item.linha])
        } else if (item.tipo === "sistema") {
            Quickshell.execDetached(item.cmd)
        } else if (item.tipo === "conta") {
            Quickshell.execDetached(["wl-copy", "--", item.valor])
        } else if (item.tipo === "emoji") {
            Quickshell.execDetached(["wl-copy", "--", item.emoji])
        } else if (item.tipo === "pasta") {
            Quickshell.execDetached(["ghostty", "-e", "yazi", item.caminho])
        } else {
            Quickshell.execDetached(["xdg-open", item.caminho])
        }
        fechar()
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { raiz.aberto ? raiz.fechar() : raiz.abrir("apps") }
        function abrir(): void { raiz.abrir("apps") }
        function clipboard(): void { raiz.aberto && raiz.modo === "clipboard" ? raiz.fechar() : raiz.abrir("clipboard") }
        function emoji(): void { raiz.aberto && raiz.modo === "emoji" ? raiz.fechar() : raiz.abrir("emoji") }
        function calc(): void { raiz.aberto && raiz.modo === "calc" ? raiz.fechar() : raiz.abrir("calc") }
        function fechar(): void { raiz.fechar() }
    }

    // nomes dos emojis (gerado do Unicode: emoji \t nome em inglês)
    readonly property var linhasEmoji: arquivoEmoji.text().split("\n")
    FileView { id: arquivoEmoji; path: Qt.resolvedUrl("emojis.tsv"); blockLoading: true }

    // contagem de uso dos apps, para ordenar
    FileView {
        id: arquivoUsos
        path: Quickshell.statePath("launcher-usos.json")
        atomicWrites: true
        adapter: JsonAdapter {
            id: usosArquivo
            property var usos: ({})
        }
    }

    // busca de arquivos com fd (com atraso para não rodar a cada tecla)
    Timer {
        id: atraso
        interval: 120
        onTriggered: {
            if (raiz.consulta.trim().length < 2) { raiz.resultados = []; return }
            buscaFd.running = false
            buscaFd.command = ["fd", "-i", "--max-results", "40", "--base-directory", raiz.home,
                               "--", raiz.consulta.trim()]
            buscaFd.running = true
        }
    }
    Process {
        id: lerClip
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                raiz.linhasClip = text.split("\n")
                if (raiz.modo === "clipboard") raiz.filtrarClip()
            }
        }
    }
    Process {
        id: buscaFd
        stdout: StdioCollector {
            onStreamFinished: {
                if (raiz.modo !== "arquivos") return
                raiz.resultados = Busca.itensArquivos(text.split("\n"), raiz.home)
                raiz.selecionado = 0
            }
        }
    }

    PanelWindow {
        id: janela
        visible: raiz.aberto
        anchors { top: true; bottom: true; left: true; right: true }
        color: Tema.veu
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "mucha-launcher"

        // clique fora do cartão fecha
        MouseArea { anchors.fill: parent; onClicked: raiz.fechar() }

        Item {
            id: cartao
            width: Tema.px(560)
            height: Tema.px(540)
            anchors.centerIn: parent

            MouseArea { anchors.fill: parent }   // não deixa o clique vazar

            Cartela {
                anchors.fill: parent
                corte: 29 * Tema.k
                raio: 30 * Tema.k
                recuoFilete: 6 * Tema.k
                raioFilete: 36 * Tema.k
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Tema.px(40)
                anchors.rightMargin: Tema.px(40)
                anchors.topMargin: Tema.px(30)
                anchors.bottomMargin: Tema.px(30)
                spacing: Tema.px(14)

                // campo de busca
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: Tema.px(48)
                    radius: height / 2
                    color: Tema.pergaminho
                    border.color: Tema.ouro
                    border.width: 1.4 * Tema.k

                    Shape {   // lupa
                        x: Tema.px(16); y: (parent.height - Tema.px(18)) / 2
                        width: 24; height: 24
                        preferredRendererType: Shape.CurveRenderer
                        scale: Tema.px(18) / 24
                        transformOrigin: Item.TopLeft
                        ShapePath {
                            strokeColor: Tema.tintaSuave; strokeWidth: 1.6 * 24 / Tema.px(18)
                            fillColor: "transparent"; capStyle: ShapePath.RoundCap
                            PathAngleArc { centerX: 11; centerY: 11; radiusX: 8; radiusY: 8; startAngle: 0; sweepAngle: 360 }
                        }
                        ShapePath {
                            strokeColor: Tema.tintaSuave; strokeWidth: 1.6 * 24 / Tema.px(18)
                            fillColor: "transparent"; capStyle: ShapePath.RoundCap
                            startX: 21; startY: 21
                            PathLine { x: 16.7; y: 16.7 }
                        }
                    }

                    TextInput {
                        id: campo
                        anchors.fill: parent
                        anchors.leftMargin: Tema.px(44)
                        anchors.rightMargin: Tema.px(18)
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Tema.ui
                        font.pixelSize: Tema.px(17)
                        color: Tema.tinta
                        selectionColor: Tema.salviaClara
                        selectedTextColor: Tema.tinta
                        focus: raiz.aberto
                        text: raiz.consulta
                        onTextEdited: { raiz.consulta = text; raiz.atualizar() }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: campo.text === ""
                            text: ({ apps: "Abrir… (ou faça uma conta)", arquivos: "Buscar arquivos em ~",
                                     clipboard: "Buscar no histórico de cópias", emoji: "Buscar emoji (em inglês: heart, fire…)",
                                     calc: "Conta: 2^10, sqrt(2), 15% de… = 0,15*x" })[raiz.modo]
                            font: campo.font
                            color: Tema.tintaSuave
                        }

                        Keys.onPressed: ev => {
                            const ctrl = ev.modifiers & Qt.ControlModifier
                            const n = raiz.resultados.length
                            if (ev.key === Qt.Key_Escape) raiz.fechar()
                            else if (ev.key === Qt.Key_Down || (ctrl && (ev.key === Qt.Key_J || ev.key === Qt.Key_N)))
                                raiz.selecionado = Math.min(raiz.selecionado + 1, n - 1)
                            else if (ev.key === Qt.Key_Up || (ctrl && (ev.key === Qt.Key_K || ev.key === Qt.Key_P)))
                                raiz.selecionado = Math.max(raiz.selecionado - 1, 0)
                            else if (ev.key === Qt.Key_Tab || ev.key === Qt.Key_Backtab) {
                                raiz.trocarModo()
                            }
                            else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter)
                                raiz.lancar(raiz.resultados[raiz.selecionado])
                            else return
                            ev.accepted = true
                        }
                    }
                }

                // resultados
                ListView {
                    id: lista
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Tema.px(2)
                    model: raiz.resultados
                    currentIndex: raiz.selecionado
                    highlightFollowsCurrentItem: false
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: linha
                        required property var modelData
                        required property int index
                        readonly property bool atual: index === raiz.selecionado

                        width: ListView.view.width
                        implicitHeight: Tema.px(42)
                        radius: Tema.px(12)
                        color: atual ? Tema.salviaClara : (area.containsMouse ? Qt.alpha(Tema.salviaClara, 0.5) : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tema.px(16)
                            anchors.rightMargin: Tema.px(16)
                            spacing: Tema.px(14)

                            Item {   // marcador: anel, com ponto quando selecionado
                                implicitWidth: Tema.px(10); implicitHeight: Tema.px(10)
                                Rectangle {
                                    anchors.fill: parent; radius: width / 2
                                    color: "transparent"
                                    border.color: linha.atual ? Tema.cobreEscuro : Tema.ouro
                                    border.width: 1.4 * Tema.k
                                }
                                Rectangle {
                                    anchors.centerIn: parent
                                    visible: linha.atual
                                    width: Tema.px(3.2); height: width; radius: width / 2
                                    color: Tema.cobreEscuro
                                }
                            }
                            Text {
                                text: linha.modelData.nome
                                font.family: Tema.ui
                                font.pixelSize: Tema.px(17)
                                font.weight: Font.Medium
                                color: Tema.tinta
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                            Text {
                                text: linha.modelData.detalhe
                                font.family: Tema.ui
                                font.pixelSize: Tema.px(14)
                                color: Tema.tintaSuave
                                elide: Text.ElideLeft
                                Layout.maximumWidth: lista.width * 0.45
                            }
                        }
                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: raiz.lancar(linha.modelData)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: lista.count === 0
                        text: raiz.modo === "arquivos" && raiz.consulta.trim().length < 2
                              ? "Digite ao menos duas letras"
                              : raiz.modo === "clipboard" && raiz.linhasClip.length <= 1 && raiz.consulta === ""
                              ? "Histórico vazio — copie algo"
                              : raiz.modo === "calc" ? (raiz.consulta.trim() === "" ? "Digite uma conta" : "Conta incompleta")
                              : "Nada encontrado"
                        font.family: Tema.ui
                        font.pixelSize: Tema.px(15)
                        color: Tema.tintaSuave
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: raiz.modo === "emoji" || raiz.modo === "calc" ? "Enter copia" : "Enter abre"; font.family: Tema.ui; font.pixelSize: Tema.px(13); color: Tema.tintaSuave }
                    Item { Layout.fillWidth: true }
                    Text { text: "Tab troca o modo"; font.family: Tema.ui; font.pixelSize: Tema.px(13); color: Tema.tintaSuave }
                }

                // friso com o nome do modo
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: Tema.px(96)
                    radius: Tema.px(8)
                    color: "transparent"
                    border.color: Tema.borda
                    border.width: 1.4 * Tema.k
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1.4 * Tema.k
                        source: "file://" + raiz.home + "/.config/rice/assets/cartela-launcher.png"
                        // no tema escuro a gravura sépia some no fundo em vez de acender
                        layer.enabled: Tema.escuro
                        layer.effect: MultiEffect { brightness: -0.42; saturation: -0.15 }
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: rotuloModo.implicitWidth + Tema.px(20)
                        height: rotuloModo.implicitHeight + Tema.px(2)
                        radius: Tema.px(6)
                        color: Qt.alpha(Tema.pergaminho, 0.94)
                        Text {
                            id: rotuloModo
                            anchors.centerIn: parent
                            text: raiz.modo
                            font.family: Tema.display
                            font.pixelSize: Tema.px(16)
                            color: Tema.tinta
                        }
                    }
                }
            }
        }
    }
}
