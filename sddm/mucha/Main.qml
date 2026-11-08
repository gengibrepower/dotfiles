import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

// Tema SDDM "Mucha": mesmo cartão em arco do hyprlock.
// Tudo é desenhado nas coordenadas do mockup (1440x810) e escalado para a tela.
Rectangle {
    id: raiz
    width: 1920
    height: 1080
    color: "#EFE6D2"

    // ---- paleta ----
    readonly property color pergaminho: "#EFE6D2"
    readonly property color creme: "#F7F1E3"
    readonly property color tinta: "#3A3328"
    readonly property color tintaSuave: "#6E6553"
    readonly property color cobre: "#B0683A"
    readonly property color cobreEscuro: "#8A4B26"
    readonly property color ouro: "#B8955A"
    readonly property color borda: "#6E3C1E"
    readonly property color trilho: "#E2D7BF"

    FontLoader { id: federant; source: "fonts/Federant-Regular.ttf" }
    FontLoader { id: alegreya; source: "fonts/AlegreyaSans-Regular.ttf" }
    FontLoader { source: "fonts/AlegreyaSans-Medium.ttf" }
    FontLoader { source: "fonts/AlegreyaSans-Bold.ttf" }

    // ---- usuário e sessão (lidos dos modelos do SDDM) ----
    property var usuarios: []
    property var sessoes: []
    property int sessao: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    readonly property string usuario: userModel.lastUser !== "" ? userModel.lastUser : (usuarios[0] ?? "")
    property string erro: ""
    property bool menuEnergia: false

    Repeater {
        model: userModel
        delegate: Item {
            required property string name
            required property int index
            Component.onCompleted: { const u = raiz.usuarios.slice(); u[index] = name; raiz.usuarios = u }
        }
    }
    Repeater {
        model: sessionModel
        delegate: Item {
            required property string name
            required property int index
            Component.onCompleted: { const s = raiz.sessoes.slice(); s[index] = name; raiz.sessoes = s }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            raiz.erro = "Senha incorreta"
            senha.text = ""
            senha.forceActiveFocus()
        }
        function onLoginSucceeded() { raiz.erro = "" }
    }

    function entrar() {
        if (senha.text === "") return
        raiz.erro = ""
        sddm.login(raiz.usuario, senha.text, raiz.sessao)
    }

    // ---- fundo ----
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
    }

    // clique fora fecha o menu de energia
    MouseArea { anchors.fill: parent; onClicked: { raiz.menuEnergia = false; senha.forceActiveFocus() } }

    // ---- palco nas coordenadas do mockup ----
    Item {
        id: palco
        width: 1440; height: 810
        anchors.centerIn: parent
        scale: Math.min(raiz.width / 1440, raiz.height / 810)

        Item {
            id: cartao
            x: 796; y: 168; width: 344; height: 470

            // arco: borda, sombra e filete dourado
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                layer.enabled: true
                layer.samples: 4
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(74 / 255, 52 / 255, 30 / 255, 0.22)
                    shadowVerticalOffset: 14
                    shadowBlur: 1.0
                    blurMax: 40
                }
                ShapePath {
                    fillColor: raiz.creme; strokeColor: raiz.borda; strokeWidth: 2
                    startX: 1; startY: 172
                    PathArc  { x: 343; y: 172; radiusX: 171; radiusY: 171 }
                    PathLine { x: 343; y: 455 }
                    PathArc  { x: 329; y: 469; radiusX: 14; radiusY: 14 }
                    PathLine { x: 15; y: 469 }
                    PathArc  { x: 1; y: 455; radiusX: 14; radiusY: 14 }
                    PathLine { x: 1; y: 172 }
                }
            }
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: "transparent"; strokeColor: raiz.ouro; strokeWidth: 1
                    startX: 6.5; startY: 172
                    PathArc  { x: 337.5; y: 172; radiusX: 165.5; radiusY: 165.5 }
                    PathLine { x: 337.5; y: 455 }
                    PathArc  { x: 329.5; y: 463.5; radiusX: 8.5; radiusY: 8.5 }
                    PathLine { x: 14.5; y: 463.5 }
                    PathArc  { x: 6.5; y: 455; radiusX: 8.5; radiusY: 8.5 }
                    PathLine { x: 6.5; y: 172 }
                }
            }

            Column {
                x: 30; y: 30; width: 284
                spacing: 8

                // avatar no medalhão
                Item {
                    width: 114; height: 114
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle {
                        anchors.fill: parent; radius: width / 2
                        color: "transparent"; border.color: raiz.ouro; border.width: 1
                    }
                    Image {
                        id: avatar
                        anchors.centerIn: parent
                        width: 104; height: 104
                        source: "assets/avatar.png"
                        smooth: true; mipmap: true
                        visible: false
                    }
                    Rectangle { id: mascara; anchors.fill: avatar; radius: width / 2; visible: false; layer.enabled: true }
                    MultiEffect {
                        anchors.fill: avatar
                        source: avatar
                        maskEnabled: true
                        maskSource: mascara
                    }
                    Rectangle {
                        anchors.fill: avatar; radius: width / 2
                        color: "transparent"; border.color: raiz.borda; border.width: 1.6
                    }
                }

                Text {
                    id: hora
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: federant.name
                    font.pixelSize: 72
                    color: raiz.tinta
                    text: Qt.formatTime(new Date(), "HH:mm")
                    topPadding: 2
                }
                Text {
                    id: data
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: alegreya.name
                    font.pixelSize: 16
                    color: raiz.tintaSuave
                    readonly property var dias: ["domingo", "segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado"]
                    readonly property var meses: ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"]
                    function atualizar() {
                        const d = new Date()
                        text = `${dias[d.getDay()]}, ${d.getDate()} de ${meses[d.getMonth()]}`
                        hora.text = Qt.formatTime(d, "HH:mm")
                    }
                    Component.onCompleted: atualizar()
                    Timer { interval: 1000; running: true; repeat: true; onTriggered: data.atualizar() }
                }

                // cartela com o nome do usuário
                Item {
                    width: 200; height: 34
                    anchors.horizontalCenter: parent.horizontalCenter
                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            fillColor: raiz.creme; strokeColor: raiz.borda; strokeWidth: 1.4
                            startX: 8.97; startY: 0.7
                            PathLine { x: 191.03; y: 0.7 }
                            PathArc  { x: 199.3; y: 8.97; radiusX: 9; radiusY: 9; direction: PathArc.Counterclockwise }
                            PathLine { x: 199.3; y: 25.03 }
                            PathArc  { x: 191.03; y: 33.3; radiusX: 9; radiusY: 9; direction: PathArc.Counterclockwise }
                            PathLine { x: 8.97; y: 33.3 }
                            PathArc  { x: 0.7; y: 25.03; radiusX: 9; radiusY: 9; direction: PathArc.Counterclockwise }
                            PathLine { x: 0.7; y: 8.97 }
                            PathArc  { x: 8.97; y: 0.7; radiusX: 9; radiusY: 9; direction: PathArc.Counterclockwise }
                        }
                        ShapePath {
                            fillColor: "transparent"; strokeColor: raiz.ouro; strokeWidth: 1
                            startX: 13.75; startY: 6
                            PathLine { x: 186.25; y: 6 }
                            PathArc  { x: 194; y: 13.75; radiusX: 15; radiusY: 15; direction: PathArc.Counterclockwise }
                            PathLine { x: 194; y: 20.25 }
                            PathArc  { x: 186.25; y: 28; radiusX: 15; radiusY: 15; direction: PathArc.Counterclockwise }
                            PathLine { x: 13.75; y: 28 }
                            PathArc  { x: 6; y: 20.25; radiusX: 15; radiusY: 15; direction: PathArc.Counterclockwise }
                            PathLine { x: 6; y: 13.75 }
                            PathArc  { x: 13.75; y: 6; radiusX: 15; radiusY: 15; direction: PathArc.Counterclockwise }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: raiz.usuario
                        font.family: alegreya.name
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: raiz.tinta
                    }
                }

                // senha
                Rectangle {
                    width: parent.width; height: 44
                    radius: 22
                    color: raiz.pergaminho
                    border.color: raiz.erro !== "" ? raiz.cobreEscuro : raiz.cobre
                    border.width: 1.4

                    TextInput {
                        id: senha
                        anchors.fill: parent
                        anchors.leftMargin: 18; anchors.rightMargin: 18
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        font.family: alegreya.name
                        font.pixelSize: 15
                        font.letterSpacing: 2
                        color: raiz.tinta
                        focus: true
                        Component.onCompleted: forceActiveFocus()
                        onTextEdited: raiz.erro = ""
                        Keys.onReturnPressed: raiz.entrar()
                        Keys.onEnterPressed: raiz.entrar()
                        Keys.onEscapePressed: { text = ""; raiz.menuEnergia = false }

                        Text {
                            anchors.centerIn: parent
                            visible: senha.text === ""
                            text: raiz.erro !== "" ? raiz.erro
                                  : (keyboard.capsLock ? "Caps Lock ligado" : "Digite a senha")
                            font.family: alegreya.name
                            font.pixelSize: 15
                            color: raiz.erro !== "" ? raiz.cobreEscuro : raiz.tintaSuave
                        }
                    }
                }

                // sessão (clique troca)
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: raiz.sessoes.length > 0
                    text: (raiz.sessoes[raiz.sessao] ?? "") + (raiz.sessoes.length > 1 ? "  ·  trocar" : "")
                    font.family: alegreya.name
                    font.pixelSize: 13
                    color: sessaoArea.containsMouse ? raiz.cobreEscuro : raiz.tintaSuave
                    topPadding: 2
                    MouseArea {
                        id: sessaoArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { raiz.sessao = (raiz.sessao + 1) % raiz.sessoes.length; senha.forceActiveFocus() }
                    }
                }
            }

            // energia
            Rectangle {
                id: botaoEnergia
                width: 40; height: 40; radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
                y: 470 - 22 - 40
                color: raiz.pergaminho
                border.color: raiz.borda; border.width: 1.6
                Image {
                    anchors.fill: parent; anchors.margins: 1.6
                    source: "assets/energia.png"
                    smooth: true; mipmap: true
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: raiz.menuEnergia = !raiz.menuEnergia
                }
            }

            Row {
                visible: raiz.menuEnergia
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: botaoEnergia.top
                anchors.bottomMargin: 10
                Repeater {
                    model: [
                        { rotulo: "Suspender", pode: sddm.canSuspend,  acao: () => sddm.suspend() },
                        { rotulo: "Reiniciar", pode: sddm.canReboot,   acao: () => sddm.reboot() },
                        { rotulo: "Desligar",  pode: sddm.canPowerOff, acao: () => sddm.powerOff() },
                    ]
                    delegate: Rectangle {
                        id: be
                        required property var modelData
                        visible: modelData.pode
                        height: 32; width: rotuloBe.implicitWidth + 24
                        radius: 16
                        color: beArea.containsMouse ? raiz.trilho : raiz.pergaminho
                        border.color: raiz.ouro; border.width: 1.2
                        Text {
                            id: rotuloBe
                            anchors.centerIn: parent
                            text: be.modelData.rotulo
                            font.family: alegreya.name
                            font.pixelSize: 14
                            color: raiz.tinta
                        }
                        MouseArea {
                            id: beArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: be.modelData.acao()
                        }
                    }
                }
            }
        }
    }
}
