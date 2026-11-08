pragma Singleton

import QtQuick
import Quickshell

// Paleta e tipografia do rice "Mucha" (mesmos valores de hypr/mucha.lua)
Singleton {
    // mockup (1440 px de largura) -> px lógicos (1280 @1.5)
    readonly property real k: 1280 / 1440
    function px(v) { return Math.round(v * k * 10) / 10 }

    readonly property color pergaminho: "#EFE6D2"
    readonly property color creme: "#F7F1E3"
    readonly property color tinta: "#3A3328"
    readonly property color tintaSuave: "#6E6553"
    readonly property color salvia: "#8A9A7B"
    readonly property color salviaClara: "#DCE3D2"
    readonly property color salviaEscura: "#4F5E45"
    readonly property color cobre: "#B0683A"
    readonly property color cobreEscuro: "#8A4B26"
    readonly property color ouro: "#B8955A"
    readonly property color borda: "#6E3C1E"
    readonly property color trilho: "#E2D7BF"
    readonly property color sombra: Qt.rgba(74 / 255, 52 / 255, 30 / 255, 0.22)

    readonly property string display: "Federant"
    readonly property string ui: "Alegreya Sans"
    readonly property string mono: "Maple Mono NF"
}
