pragma Singleton

import QtQuick
import Quickshell

// Estado compartilhado entre painel e notificações.
Singleton {
    property bool naoPerturbe: false
    property bool painelAberto: false
    property string modoTema: "auto"      // auto | claro | escuro (tema/Noturno.qml)

    // histórico das notificações (mais nova primeiro), só na memória da sessão
    property var historico: []
    function registrar(n) {
        const item = {
            app: n.appName || "Sistema",
            resumo: n.summary || "",
            corpo: (n.body || "").replace(/<[^>]*>/g, ""),
            critica: n.urgency === 2,
            hora: new Date()
        }
        historico = [item].concat(historico).slice(0, 50)
        naoLidas = Math.min(naoLidas + 1, 50)
    }
    function limparHistorico() { historico = []; naoLidas = 0 }
    property int naoLidas: 0
}
