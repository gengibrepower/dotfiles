import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

// Moldura em arco (topo semicircular), com filete dourado interno e sombra:
// silhueta do painel de status e do bloqueio.
Item {
    id: raiz

    property color fundo: Tema.creme
    property color corBorda: Tema.borda
    property real espessura: 2 * Tema.k
    property real raioBase: 14 * Tema.k
    property real recuoFilete: 6.5 * Tema.k
    property bool sombra: true

    component Contorno: ShapePath {
        id: cp
        property real x0
        property real y0
        property real w
        property real h
        property real rb
        readonly property real r: w / 2

        startX: x0; startY: y0 + r
        PathArc  { x: cp.x0 + cp.w; y: cp.y0 + cp.r; radiusX: cp.r; radiusY: cp.r; direction: PathArc.Clockwise }
        PathLine { x: cp.x0 + cp.w; y: cp.y0 + cp.h - cp.rb }
        PathArc  { x: cp.x0 + cp.w - cp.rb; y: cp.y0 + cp.h; radiusX: cp.rb; radiusY: cp.rb; direction: PathArc.Clockwise }
        PathLine { x: cp.x0 + cp.rb; y: cp.y0 + cp.h }
        PathArc  { x: cp.x0; y: cp.y0 + cp.h - cp.rb; radiusX: cp.rb; radiusY: cp.rb; direction: PathArc.Clockwise }
        PathLine { x: cp.x0; y: cp.y0 + cp.r }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: raiz.sombra
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Tema.sombra
            shadowVerticalOffset: 14 * Tema.k
            shadowBlur: 1.0
            blurMax: 40
        }
        Contorno {
            fillColor: raiz.fundo
            strokeColor: raiz.corBorda
            strokeWidth: raiz.espessura
            x0: raiz.espessura / 2; y0: raiz.espessura / 2
            w: raiz.width - raiz.espessura; h: raiz.height - raiz.espessura
            rb: raiz.raioBase
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        Contorno {
            fillColor: "transparent"
            strokeColor: Tema.ouro
            strokeWidth: Tema.k
            x0: raiz.recuoFilete; y0: raiz.recuoFilete
            w: raiz.width - 2 * raiz.recuoFilete; h: raiz.height - 2 * raiz.recuoFilete
            rb: Math.max(raiz.raioBase - raiz.recuoFilete, 2)
        }
    }
}
