import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

// Moldura de cantos côncavos com filete dourado interno e sombra,
// como as notificações e o launcher do mockup.
Item {
    id: raiz

    property color fundo: Tema.creme
    property color corBorda: Tema.borda
    property real espessura: 2 * Tema.k
    property real corte: 17 * Tema.k        // recuo do canto côncavo
    property real raio: 18 * Tema.k
    property bool filete: true
    property real recuoFilete: 6 * Tema.k
    property real raioFilete: 24 * Tema.k
    property bool sombra: true

    component Contorno: ShapePath {
        id: cp
        property real x0
        property real y0
        property real x1
        property real y1
        property real c
        property real r

        startX: x0 + c; startY: y0
        PathLine { x: cp.x1 - cp.c; y: cp.y0 }
        PathArc  { x: cp.x1; y: cp.y0 + cp.c; radiusX: cp.r; radiusY: cp.r; direction: PathArc.Counterclockwise }
        PathLine { x: cp.x1; y: cp.y1 - cp.c }
        PathArc  { x: cp.x1 - cp.c; y: cp.y1; radiusX: cp.r; radiusY: cp.r; direction: PathArc.Counterclockwise }
        PathLine { x: cp.x0 + cp.c; y: cp.y1 }
        PathArc  { x: cp.x0; y: cp.y1 - cp.c; radiusX: cp.r; radiusY: cp.r; direction: PathArc.Counterclockwise }
        PathLine { x: cp.x0; y: cp.y0 + cp.c }
        PathArc  { x: cp.x0 + cp.c; y: cp.y0; radiusX: cp.r; radiusY: cp.r; direction: PathArc.Counterclockwise }
    }

    Shape {
        id: forma
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        layer.enabled: raiz.sombra
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Tema.sombra
            shadowVerticalOffset: 12 * Tema.k
            shadowBlur: 1.0
            blurMax: 28
        }

        Contorno {
            fillColor: raiz.fundo
            strokeColor: raiz.corBorda
            strokeWidth: raiz.espessura
            x0: raiz.espessura / 2; y0: raiz.espessura / 2
            x1: raiz.width - raiz.espessura / 2; y1: raiz.height - raiz.espessura / 2
            c: raiz.corte; r: raiz.raio
        }
    }

    Shape {
        anchors.fill: parent
        visible: raiz.filete
        preferredRendererType: Shape.CurveRenderer

        Contorno {
            fillColor: "transparent"
            strokeColor: Tema.ouro
            strokeWidth: Tema.k
            x0: raiz.recuoFilete; y0: raiz.recuoFilete
            x1: raiz.width - raiz.recuoFilete; y1: raiz.height - raiz.recuoFilete
            c: raiz.corte + 0.24 * Tema.k; r: raiz.raioFilete
        }
    }
}
