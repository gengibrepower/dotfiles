import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Aviso de bateria baixa: 15% avisa, 8% avisa como crítico, 5% suspende.
// Cada nível avisa uma vez por descarga; ligar na tomada zera.
//   qs ipc call bateria simular <pct>   (teste sem descarregar de verdade)
Scope {
    id: raiz

    readonly property var dispositivo: UPower.displayDevice
    readonly property real pct: dispositivo ? dispositivo.percentage * 100 : 100
    property int ultimoAviso: 101          // menor nível já avisado nesta descarga

    function checar(p) {
        if (!UPower.onBattery) { ultimoAviso = 101; return }
        if (p <= 5 && ultimoAviso > 5) {
            ultimoAviso = 5
            avisar("critical", "Bateria em " + Math.round(p) + "%", "Suspendendo para não perder o trabalho.")
            suspender.restart()
        } else if (p <= 8 && ultimoAviso > 8) {
            ultimoAviso = 8
            avisar("critical", "Bateria em " + Math.round(p) + "%", "Ligue na tomada — suspende sozinho em 5%.")
        } else if (p <= 15 && ultimoAviso > 15) {
            ultimoAviso = 15
            avisar("normal", "Bateria em " + Math.round(p) + "%", "Hora de procurar uma tomada.")
        }
    }

    function avisar(urgencia, titulo, corpo) {
        Quickshell.execDetached(["notify-send", "-a", "Bateria", "-u", urgencia, "-i", "battery-caution-symbolic", titulo, corpo])
    }

    // dá 20 s para ligar na tomada antes de suspender
    Timer {
        id: suspender
        interval: 20000
        onTriggered: if (UPower.onBattery) Quickshell.execDetached(["systemctl", "suspend"])
    }

    onPctChanged: checar(pct)
    Connections {
        target: UPower
        function onOnBatteryChanged() {
            if (!UPower.onBattery) { raiz.ultimoAviso = 101; suspender.stop() }
            else raiz.checar(raiz.pct)
        }
    }

    IpcHandler {
        target: "bateria"
        // força a checagem com um valor fictício (ignora a tomada; não suspende)
        function simular(p: int): void {
            const nivel = p <= 5 ? 5 : p <= 8 ? 8 : p <= 15 ? 15 : 101
            if (nivel === 101) return
            raiz.avisar(nivel <= 8 ? "critical" : "normal", "Bateria em " + p + "% (teste)",
                        nivel === 5 ? "Aqui suspenderia em 20 s." : nivel === 8 ? "Ligue na tomada — suspende sozinho em 5%." : "Hora de procurar uma tomada.")
        }
    }
}
