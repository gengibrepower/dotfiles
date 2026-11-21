import QtQuick
import Quickshell
import Quickshell.Io
import "../comum"

// Tema claro/escuro. Modo "auto" segue o horário (escuro das
// 19:30 às 7:00); "claro"/"escuro" fixam. Guarda o modo entre sessões e
// chama hypr/scripts/tema.sh para trocar o resto (Ghostty, GTK, tmux…).
//   qs ipc call tema alternar | definir auto|claro|escuro | estado
Scope {
    id: raiz

    readonly property var modos: ["auto", "claro", "escuro"]
    readonly property int inicioNoite: 19 * 60 + 30
    readonly property int fimNoite: 7 * 60

    SystemClock { id: relogio; precision: SystemClock.Minutes }
    readonly property int minutos: relogio.date.getHours() * 60 + relogio.date.getMinutes()
    readonly property bool noite: minutos >= inicioNoite || minutos < fimNoite
    readonly property bool escuro: Estado.modoTema === "escuro" || (Estado.modoTema === "auto" && noite)

    FileView {
        id: arquivo
        path: Quickshell.statePath("tema.json")
        atomicWrites: true
        adapter: JsonAdapter { id: salvo; property string modo: "auto" }
        // o modo salvo só está disponível depois do load (sem arquivo = auto)
        onLoaded: raiz.carregar(salvo.modo)
        onLoadFailed: raiz.carregar("auto")
    }
    property bool carregado: false
    function carregar(m) {
        Estado.modoTema = modos.indexOf(m) >= 0 ? m : "auto"
        carregado = true
        aplicar()
    }

    function definir(m) {
        if (modos.indexOf(m) < 0) return
        Estado.modoTema = m
        salvo.modo = m
        arquivo.writeAdapter()
    }
    function aplicar() {
        Tema.escuro = escuro
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/tema.sh", escuro ? "escuro" : "claro"])
    }
    onEscuroChanged: if (carregado) aplicar()

    IpcHandler {
        target: "tema"
        function alternar(): void {
            const m = raiz.modos[(raiz.modos.indexOf(Estado.modoTema) + 1) % 3]
            raiz.definir(m)
            Quickshell.execDetached(["notify-send", "-a", "Tema", "-t", "2500", "Tema: " +
                ({ auto: "automático (escuro das 19:30 às 7:00)", claro: "claro", escuro: "escuro" })[m]])
        }
        function definir(m: string): void { raiz.definir(m) }
        function estado(): string { return Estado.modoTema + (raiz.escuro ? " · escuro" : " · claro") }
    }
}
