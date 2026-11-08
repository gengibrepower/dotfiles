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
