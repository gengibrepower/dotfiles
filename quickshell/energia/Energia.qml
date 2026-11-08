import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Perfil de energia automático: performance na tomada, economia na bateria.
// Age ao subir o shell e a cada vez que o carregador entra/sai; uma troca
// manual (painel) vale até o próximo evento de tomada.
// Usa powerprofilesctl: o PowerProfiles do Quickshell recusa "performance"
// se for chamado antes de carregar a lista de perfis do daemon.
Scope {
    id: raiz

    function aplicar() {
        const alvo = UPower.onBattery ? "power-saver" : "performance"
        Quickshell.execDetached(["powerprofilesctl", "set", alvo])
        console.info("energia: " + (UPower.onBattery ? "bateria" : "tomada") + " → " + alvo)
    }

    // qs ipc call energia aplicar
    IpcHandler {
        target: "energia"
        function aplicar(): void { raiz.aplicar() }
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() { raiz.aplicar() }
    }

    // espera o UPower responder antes da primeira decisão
    Timer { interval: 2000; running: true; onTriggered: raiz.aplicar() }
}
