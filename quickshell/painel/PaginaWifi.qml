import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../comum"

// Wi-Fi pelo nmcli: liga/desliga, lista redes, conecta (pede senha se precisar).
Subpagina {
    id: raiz

    property bool ativa: false            // página visível: lê e reescaneia
    property bool ligado: true
    property var redes: []                // [{ ssid, sinal, segura, emUso, salva }]
    property var salvas: []
    property string abertaSenha: ""       // SSID com o campo de senha aberto
    property string conectando: ""
    property string erro: ""
    signal mudou()                        // avisa o painel para reler o bloco "Rede"

    titulo: "Wi-Fi"
    subtitulo: !ligado ? "desligado"
             : conectando !== "" ? "conectando a " + conectando + "…"
             : erro !== "" ? erro
             : varredura.running ? "procurando redes…" : redes.length + " redes por perto"

    onAtivaChanged: if (ativa) { abertaSenha = ""; erro = ""; reler(true) }

    function reler(escanear) {
        estado.running = true
        salvasProc.running = true
        lista.running = true                          // cache: aparece na hora
        if (escanear && !varredura.running) varredura.running = true
    }
    // reescaneia em segundo plano e relê quando terminar
    Process { id: varredura; command: ["nmcli", "device", "wifi", "rescan"]; onExited: lista.running = true }

    // nmcli -t escapa ":" como "\:" dentro dos campos
    function campos(l) {
        const out = []; let atual = ""
        for (let i = 0; i < l.length; i++) {
            if (l[i] === "\\" && i + 1 < l.length) { atual += l[++i]; continue }
            if (l[i] === ":") { out.push(atual); atual = ""; continue }
            atual += l[i]
        }
        out.push(atual)
        return out
    }

    Process {
        id: estado
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: raiz.ligado = text.trim() === "enabled" }
    }
    Process {
        id: salvasProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: raiz.salvas = text.split("\n").map(l => raiz.campos(l))
                                  .filter(c => c[1] === "802-11-wireless").map(c => c[0])
        }
    }
    Process {
        id: lista
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const porNome = {}
                for (const l of text.split("\n")) {
                    const c = raiz.campos(l)
                    if (c.length < 4 || c[1] === "") continue
                    const r = { ssid: c[1], sinal: parseInt(c[2]) || 0, segura: c[3] !== "" && c[3] !== "--", emUso: c[0] === "*" }
                    const ant = porNome[r.ssid]
                    if (!ant) porNome[r.ssid] = r
                    else { ant.sinal = Math.max(ant.sinal, r.sinal); ant.emUso = ant.emUso || r.emUso }
                }
                raiz.redes = Object.values(porNome).sort((a, b) => b.emUso - a.emUso || b.sinal - a.sinal)
            }
        }
    }
    Process {
        id: acao
        property string alvo
        stdout: StdioCollector {}
        stderr: StdioCollector { id: errAcao }
        onExited: code => {
            raiz.conectando = ""
            if (code !== 0) {
                const m = errAcao.text.trim().split("\n").pop() || "falhou"
                raiz.erro = /secrets|password|802-1x|Senha/i.test(m) ? "senha errada?" : m.replace(/^Error: /, "").slice(0, 60)
            } else { raiz.erro = ""; raiz.abertaSenha = "" }
            raiz.reler(false)
            raiz.mudou()
        }
    }
    function rodar(cmd, ssid) {
        if (acao.running) return
        erro = ""; conectando = ssid || ""
        acao.command = cmd
        acao.running = true
    }

    function clicar(r) {
        if (r.emUso) rodar(["nmcli", "connection", "down", "id", r.ssid], "")
        else if (salvas.indexOf(r.ssid) >= 0) rodar(["nmcli", "connection", "up", "id", r.ssid], r.ssid)
        else if (!r.segura) rodar(["nmcli", "device", "wifi", "connect", r.ssid], r.ssid)
        else abertaSenha = abertaSenha === r.ssid ? "" : r.ssid
    }
    function conectarComSenha(ssid, senha) {
        if (senha === "") return
        rodar(["nmcli", "device", "wifi", "connect", ssid, "password", senha], ssid)
    }
    function alternarRadio() {
        Quickshell.execDetached(["nmcli", "radio", "wifi", ligado ? "off" : "on"])
        ligado = !ligado
        if (ligado) atrasoReler.restart(); else redes = []
        mudou()
    }
    Timer { id: atrasoReler; interval: 2500; onTriggered: raiz.reler(true) }

    direita: Row {
        spacing: Tema.px(6)
        BotaoRedondo { glifo: "󰑐"; dica: "Procurar de novo"; visible: raiz.ligado; onClicado: raiz.reler(true) }
        Interruptor { ligado: raiz.ligado; onAlternado: raiz.alternarRadio() }
    }

    Column {
        width: parent.width
        spacing: Tema.px(4)

        Repeater {
            model: raiz.redes
            delegate: Rectangle {
                id: linha
                required property var modelData
                readonly property bool comSenha: raiz.abertaSenha === modelData.ssid
                width: parent.width
                height: Tema.px(44) + (comSenha ? Tema.px(44) : 0)
                radius: Tema.px(10)
                color: modelData.emUso ? Tema.salviaClara : (ma.containsMouse || comSenha ? Tema.pergaminho : "transparent")
                border.color: modelData.emUso ? Tema.salvia : (comSenha ? "#D5C7A8" : "transparent")
                border.width: Tema.k

                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: raiz.clicar(linha.modelData) }

                RowLayout {
                    x: Tema.px(12); width: parent.width - Tema.px(24); height: Tema.px(44)
                    spacing: Tema.px(10)
                    Text {
                        text: { const s = linha.modelData.sinal; return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟" }
                        font.family: Tema.mono; font.pixelSize: Tema.px(16); color: Tema.salviaEscura
                    }
                    Text {
                        Layout.fillWidth: true
                        text: linha.modelData.ssid
                        elide: Text.ElideRight
                        font.family: Tema.ui; font.pixelSize: Tema.px(14)
                        font.weight: linha.modelData.emUso ? Font.DemiBold : Font.Normal
                        color: Tema.tinta
                    }
                    Text {
                        text: linha.modelData.emUso ? (ma.containsMouse ? "desconectar" : "conectada")
                            : raiz.conectando === linha.modelData.ssid ? "…"
                            : raiz.salvas.indexOf(linha.modelData.ssid) >= 0 ? "salva" : ""
                        font.family: Tema.ui; font.pixelSize: Tema.px(12); color: Tema.tintaSuave
                    }
                    Text {
                        visible: linha.modelData.segura
                        text: "\uf023"   // cadeado
                        font.family: Tema.mono; font.pixelSize: Tema.px(12); color: Tema.tintaSuave
                    }
                }

                // campo de senha (só para rede nova protegida)
                Rectangle {
                    visible: linha.comSenha
                    x: Tema.px(10); y: Tema.px(44)
                    width: parent.width - Tema.px(20); height: Tema.px(34)
                    radius: height / 2
                    color: Tema.creme
                    border.color: Tema.ouro; border.width: Tema.k
                    TextInput {
                        id: senha
                        anchors.fill: parent
                        anchors.leftMargin: Tema.px(14); anchors.rightMargin: Tema.px(14)
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        font.family: Tema.ui; font.pixelSize: Tema.px(14)
                        color: Tema.tinta
                        focus: linha.comSenha
                        onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                        Keys.onReturnPressed: raiz.conectarComSenha(linha.modelData.ssid, text)
                        Keys.onEnterPressed: raiz.conectarComSenha(linha.modelData.ssid, text)
                        Keys.onEscapePressed: raiz.abertaSenha = ""
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: senha.text === ""
                            text: "senha · Enter conecta"
                            font: senha.font; color: Tema.tintaSuave
                        }
                    }
                }
            }
        }

        Text {
            visible: raiz.redes.length === 0
            width: parent.width
            topPadding: Tema.px(30)
            horizontalAlignment: Text.AlignHCenter
            text: raiz.ligado ? "Procurando…" : "Wi-Fi desligado"
            font.family: Tema.ui; font.pixelSize: Tema.px(14); color: Tema.tintaSuave
        }
    }
}
