import QtQuick
import Quickshell
import Quickshell.Io

// Uso do Claude Code (janela de 5 h e semana), escrito pela statusline
// (claude/statusline.py) em ~/.local/state/rice/claude-uso.json.
// Avisa uma vez por janela ao passar de 80% e de 95%.
Scope {
    id: raiz

    property var dados: null
    property real agora: Date.now() / 1000
    Timer { interval: 30000; running: true; repeat: true; onTriggered: raiz.agora = Date.now() / 1000 }

    readonly property bool temDados: dados !== null && (dados.sessao || dados.semana)
    // janela passou do horário de renovação = zerou (até o Claude mandar número novo)
    function vigente(j) { return j && (!j.reset || j.reset > agora) ? j.pct : 0 }
    readonly property real sessao: temDados ? vigente(dados.sessao) : 0
    readonly property real semana: temDados ? vigente(dados.semana) : 0
    readonly property bool sessaoRenovou: temDados && !!dados.sessao && !!dados.sessao.reset && dados.sessao.reset <= agora
    readonly property string renova: {
        if (!temDados || !dados.sessao || !dados.sessao.reset || sessaoRenovou) return ""
        return Qt.formatTime(new Date(dados.sessao.reset * 1000), "HH:mm")
    }

    FileView {
        id: arquivo
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/rice/claude-uso.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { raiz.dados = JSON.parse(text()) } catch (e) { return }
            raiz.agora = Date.now() / 1000
            raiz.checarAvisos()
        }
    }

    // avisos: lembra o último nível avisado por janela (pelo horário de renovação)
    property real janelaAvisada: 0
    property int nivelAvisado: 0
    function checarAvisos() {
        const j = dados?.sessao
        if (!j || !j.reset || j.reset <= agora) return
        if (j.reset !== janelaAvisada) { janelaAvisada = j.reset; nivelAvisado = 0 }
        const nivel = j.pct >= 95 ? 95 : j.pct >= 80 ? 80 : 0
        if (nivel <= nivelAvisado) return
        nivelAvisado = nivel
        Quickshell.execDetached(["notify-send", "-a", "Claude Code", "-u", nivel >= 95 ? "critical" : "normal",
            "Sessão do Claude em " + Math.round(j.pct) + "%",
            "Renova às " + Qt.formatTime(new Date(j.reset * 1000), "HH:mm") + "."])
    }
}
