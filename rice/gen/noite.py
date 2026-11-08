#!/usr/bin/env python3
"""Gera as versões noturnas dos configs do rice Mucha a partir das de dia.

Uma tabela só (DIA_NOITE) troca cada cor clara pela escura correspondente.
Rode depois de mexer em qualquer arquivo *-dia: python3 rice/gen/noite.py
Cor nova sem par na tabela = erro (para não sair tema pela metade).
"""
import re, sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]

DIA_NOITE = {
    # superfícies
    "EFE6D2": "26211A",  # pergaminho
    "F7F1E3": "1E1A15",  # creme
    "FBF7EE": "191612",  # fundo de lista (GTK view)
    "F2EBDA": "221E18",
    "E2D7BF": "3A3328",  # trilho
    "D5C7A8": "4A4034",  # linha
    "D5C29A": "5A4C36",  # filete
    # texto
    "3A3328": "E6DAC2",  # tinta
    "6E6553": "ADA087",  # tinta suave
    # sálvia
    "8A9A7B": "7F9070",
    "A9B39C": "4A4436",
    "DCE3D2": "34402F",
    "4F5E45": "AFC29C",
    "6B7D5E": "9DB08A",
    # cobre, ouro, borda
    "B0683A": "CC8550",
    "8A4B26": "E0A070",
    "B8955A": "B39459",
    "8F6A2C": "D4AE60",
    "6E3C1E": "9A6A44",
    # cores de apoio (paleta ANSI do Ghostty)
    "4E6470": "8FA9B5", "6A8290": "A5BCC8",
    "7A4E5E": "C08FA0", "9A6A7A": "D0A5B5",
    "4D6B62": "8DB0A5", "6A8A80": "A0C2B8",
    "A0331F": "E06A50",
    # btop: texto inativo e início dos gradientes
    "A39883": "7A705C", "D9A27E": "8A5A36",
}

HEX = re.compile(r"#([0-9A-Fa-f]{6})\b")

def converter(texto, origem):
    faltam = set()
    def troca(m):
        h = m.group(1).upper()
        if h not in DIA_NOITE:
            faltam.add(h); return m.group(0)
        return "#" + DIA_NOITE[h]
    out = HEX.sub(troca, texto)
    # rgba(r, g, b, a) em CSS
    def troca_rgba(m):
        h = "%02X%02X%02X" % tuple(int(x) for x in m.group(1, 2, 3))
        if h not in DIA_NOITE:
            faltam.add(h); return m.group(0)
        n = DIA_NOITE[h]
        return "rgba(%d, %d, %d, %s)" % (int(n[0:2], 16), int(n[2:4], 16), int(n[4:6], 16), m.group(4))
    out = re.sub(r"rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)", troca_rgba, out)
    if faltam:
        sys.exit(f"{origem}: cores sem par noturno: {', '.join(sorted(faltam))}")
    return out

# (dia, noite)
PARES = [
    ("tmux/cores-dia.conf", "tmux/cores-noite.conf"),
    ("lazygit/config-dia.yml", "lazygit/config-noite.yml"),
    ("lazydocker/config-dia.yml", "lazydocker/config-noite.yml"),
    ("yazi/theme-dia.toml", "yazi/theme-noite.toml"),
    ("btop/themes/mucha-dia.theme", "btop/themes/mucha-noite.theme"),
    ("gtk/gtk-3.0/gtk-dia.css", "gtk/gtk-3.0/gtk-noite.css"),
    ("gtk/gtk-4.0/gtk-dia.css", "gtk/gtk-4.0/gtk-noite.css"),
]

def firefox():
    """userChrome.css: bloco @media (prefers-color-scheme: dark) entre marcadores."""
    p = RAIZ / "firefox/chrome/userChrome.css"
    s = p.read_text()
    ini, fim = "/* >>> noite (gerado por rice/gen/noite.py) */", "/* <<< noite */"
    if ini in s:
        s = s[:s.index(ini)].rstrip() + "\n"
    raiz = s[s.index(":root {"):]
    raiz = raiz[:raiz.index("}") + 1]
    linhas = [l for l in raiz.splitlines() if re.match(r"\s*--[\w-]+:.*(#|rgba)", l)]
    bloco = "\n".join(converter(l, "userChrome.css") for l in linhas)
    s += f"\n{ini}\n@media (prefers-color-scheme: dark) {{\n  :root {{\n{bloco}\n  }}\n}}\n{fim}\n"
    p.write_text(s)

for dia, noite in PARES:
    texto = (RAIZ / dia).read_text()
    cab = f"(gerado de {Path(dia).name} por rice/gen/noite.py — não edite à mão)"
    saida = converter(texto, dia)
    com = "/*" if dia.endswith(".css") else "#"
    saida = (f"{com} {cab} */\n" if com == "/*" else f"# {cab}\n") + saida
    (RAIZ / noite).write_text(saida)
    print("ok", noite)
firefox()
print("ok firefox/chrome/userChrome.css (bloco noite)")

# papel de parede noturno (não roda sozinho; refaça com o comando abaixo se trocar o de dia):
# ffmpeg -i rice/assets/wallpaper.webp -vf "format=gray,format=rgb24,lutrgb=r='16+pow(val/255\,1.6)*(80-16)':g='13+pow(val/255\,1.6)*(66-13)':b='10+pow(val/255\,1.6)*(48-10)'" -frames:v 1 -c:v libwebp -quality 90 rice/assets/wallpaper-noite.webp
