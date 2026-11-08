.pragma library

// Pontuação simples: prefixo > início de palavra > substring > subsequência.
function pontuar(q, alvo) {
    if (!alvo) return -1
    alvo = alvo.toLowerCase()
    const i = alvo.indexOf(q)
    if (i === 0) return 100
    if (i > 0) return /[\s\-_.\/]/.test(alvo[i - 1]) ? 80 : 60
    let j = 0
    for (const ch of alvo) if (ch === q[j] && ++j === q.length) break
    return j === q.length ? 20 : -1
}

const mapaCategorias = [
    ["WebBrowser", "navegador"], ["TerminalEmulator", "terminal"],
    ["FileManager", "arquivos"], ["TextEditor", "editor"],
    ["IDE", "desenvolvimento"], ["Development", "desenvolvimento"],
    ["Video", "vídeo"], ["Audio", "áudio"], ["AudioVideo", "mídia"],
    ["Graphics", "imagens"], ["Office", "escritório"], ["Game", "jogo"],
    ["Email", "e-mail"], ["Chat", "conversa"], ["Network", "internet"],
    ["Settings", "configurações"], ["System", "sistema"], ["Utility", "utilitário"],
]

function categoria(e) {
    const c = e.categories || []
    for (const [k, v] of mapaCategorias) if (c.indexOf(k) >= 0) return v
    return (e.genericName || "").toLowerCase()
}

// utilitários que vêm de dependências e não interessam no launcher
const ocultos = ["qv4l2", "qvidcap", "org.quickshell", "org.gnupg.pinentry-qt",
                 "xdg-desktop-portal-gtk", "org.freedesktop.Xwayland"]

// apps: lista de DesktopEntry; usos: { id: contagem }
function buscarApps(apps, consulta, usos) {
    const q = consulta.trim().toLowerCase()
    const res = []
    for (const e of apps) {
        if (e.noDisplay || ocultos.indexOf(e.id) >= 0) continue
        const uso = Math.min(usos[e.id] || 0, 30)
        let p
        if (q === "") p = uso
        else {
            p = Math.max(
                pontuar(q, e.name),
                pontuar(q, e.genericName) * 0.6,
                pontuar(q, (e.keywords || []).join(" ")) * 0.5,
                pontuar(q, e.id) * 0.5)
            if (p < 0) continue
            p += uso
        }
        res.push({ p: p, tipo: "app", entrada: e, nome: e.name,
                   detalhe: categoria(e), icone: e.icon })
    }
    res.sort((a, b) => b.p - a.p || a.nome.localeCompare(b.nome))
    return res
}

// linhas do fd (relativas ao $HOME) -> itens
function itensArquivos(linhas, home) {
    return linhas.filter(l => l !== "").map(l => {
        const pasta = l.endsWith("/")
        const limpo = pasta ? l.slice(0, -1) : l
        const corte = limpo.lastIndexOf("/")
        const nome = corte >= 0 ? limpo.slice(corte + 1) : limpo
        const dir = corte >= 0 ? "~/" + limpo.slice(0, corte) : "~"
        return { tipo: pasta ? "pasta" : "arquivo", caminho: home + "/" + limpo,
                 nome: nome + (pasta ? "/" : ""), detalhe: (pasta ? "pasta" : "arquivo") + " · " + dir }
    })
}

// ---- calculadora: parser próprio (sem eval) ----
// + - * / ^ % ( ), vírgula decimal, funções sqrt raiz sin cos tan log ln abs
// round floor ceil, constantes pi e. Devolve número ou null.
const funcoes = {
    sqrt: Math.sqrt, raiz: Math.sqrt, sin: Math.sin, sen: Math.sin, cos: Math.cos,
    tan: Math.tan, log: Math.log10, ln: Math.log, abs: Math.abs,
    round: Math.round, floor: Math.floor, ceil: Math.ceil, exp: Math.exp
}
const constantes = { pi: Math.PI, e: Math.E }

function calcular(texto) {
    const s = texto.replace(/^=/, "").replace(/,/g, ".").replace(/×/g, "*").replace(/÷/g, "/").trim()
    if (s === "") return null
    const toks = s.match(/\d+\.?\d*|\.\d+|[a-z]+|\*\*|[-+*\/^%()]|\S/gi)
    let i = 0
    const ver = () => toks[i], tomar = () => toks[i++]
    function primario() {
        const t = tomar()
        if (t === undefined) throw 0
        if (/^[\d.]/.test(t)) return parseFloat(t)
        if (t === "(") { const v = soma(); if (tomar() !== ")") throw 0; return v }
        if (t === "-") return -potencia()
        if (t === "+") return potencia()
        const nome = t.toLowerCase()
        if (nome in constantes) return constantes[nome]
        if (nome in funcoes) {
            if (ver() === "(") { tomar(); const v = soma(); if (tomar() !== ")") throw 0; return funcoes[nome](v) }
            return funcoes[nome](potencia())
        }
        throw 0
    }
    function potencia() {
        const b = primario()
        if (ver() === "^" || ver() === "**") { tomar(); return Math.pow(b, potencia()) }
        return b
    }
    function produto() {
        let v = potencia()
        for (;;) {
            const t = ver()
            if (t === "*") { tomar(); v *= potencia() }
            else if (t === "/") { tomar(); v /= potencia() }
            else if (t === "%") { tomar(); v %= potencia() }
            else if (t === "(" || (t && /^[a-z\d.]/i.test(t))) v *= potencia()   // 2pi, 3(4)
            else return v
        }
    }
    function soma() {
        let v = produto()
        for (;;) {
            const t = ver()
            if (t === "+") { tomar(); v += produto() }
            else if (t === "-") { tomar(); v -= produto() }
            else return v
        }
    }
    try {
        const v = soma()
        if (i !== toks.length || !isFinite(v)) return null
        return v
    } catch (e) { return null }
}

// parece conta? (tem dígito e operador, ou começa com =)
function pareceConta(q) {
    q = q.trim()
    return q.startsWith("=") || (/\d/.test(q) && /[-+*\/^%×÷(]/.test(q.replace(/^-/, "")) && /^[\d\s.,+\-*\/^%()×÷a-z]+$/i.test(q))
}

function formatarNumero(v) {
    if (Number.isInteger(v)) return v.toLocaleString("pt-BR", { useGrouping: false })
    return String(parseFloat(v.toPrecision(12))).replace(".", ",")
}

function itemConta(consulta) {
    const v = calcular(consulta)
    if (v === null) return null
    const r = formatarNumero(v)
    return { tipo: "conta", valor: r, nome: "= " + r, detalhe: "Enter copia" }
}

// ---- emojis: linhas "emoji\tnome" ----
function buscarEmojis(linhas, consulta) {
    const q = consulta.trim().toLowerCase()
    const res = []
    for (const l of linhas) {
        const t = l.indexOf("\t")
        if (t < 0) continue
        const nome = l.slice(t + 1)
        const p = q === "" ? 0 : pontuar(q, nome)
        if (p < 0) continue
        res.push({ p: p, tipo: "emoji", emoji: l.slice(0, t), nome: l.slice(0, t) + "   " + nome, detalhe: "" })
    }
    if (q !== "") res.sort((a, b) => b.p - a.p)
    return res.slice(0, 120)
}
