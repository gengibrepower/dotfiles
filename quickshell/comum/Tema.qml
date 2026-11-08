pragma Singleton

import QtQuick
import Quickshell

// Paleta e tipografia do rice "Mucha" (mesmos valores de hypr/mucha.lua)
Singleton {
    // mockup (1440 px de largura) -> px lógicos (1280 @1.5)
    readonly property real k: 1280 / 1440
    function px(v) { return Math.round(v * k * 10) / 10 }

    // claro/escuro: quem decide é tema/Noturno.qml (horário ou modo manual)
    property bool escuro: false
    function c(dia, noite) { return escuro ? noite : dia }

    readonly property color pergaminho: c("#EFE6D2", "#26211A")
    readonly property color creme: c("#F7F1E3", "#1E1A15")
    readonly property color tinta: c("#3A3328", "#E6DAC2")
    readonly property color tintaSuave: c("#6E6553", "#ADA087")
    readonly property color salvia: c("#8A9A7B", "#7F9070")
    readonly property color salviaClara: c("#DCE3D2", "#34402F")
    readonly property color salviaEscura: c("#4F5E45", "#AFC29C")
    readonly property color cobre: c("#B0683A", "#CC8550")
    readonly property color cobreEscuro: c("#8A4B26", "#E0A070")
    readonly property color ouro: c("#B8955A", "#B39459")
    readonly property color borda: c("#6E3C1E", "#9A6A44")
    readonly property color trilho: c("#E2D7BF", "#3A3328")
    readonly property color linha: c("#D5C7A8", "#4A4034")      // contornos discretos
    readonly property color filete: c("#D5C29A", "#5A4C36")     // separadores
    readonly property color vermelho: c("#A0331F", "#E06A50")   // gravação
    readonly property color sombra: Qt.rgba(74 / 255, 52 / 255, 30 / 255, escuro ? 0.5 : 0.22)
    readonly property color veu: Qt.rgba(58 / 255, 51 / 255, 40 / 255, escuro ? 0.35 : 0.16)   // fundo atrás de overlays
    readonly property color fileteOuro: Qt.rgba(184 / 255, 149 / 255, 90 / 255, 0.45)
    // texto sobre cor forte (botão cobre, pílula ativa)
    readonly property color sobreForte: c("#F7F1E3", "#1E1A15")

    readonly property string display: "Federant"
    readonly property string ui: "Alegreya Sans"
    readonly property string mono: "Maple Mono NF"
}
