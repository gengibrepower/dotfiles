#!/usr/bin/env python3
"""Gera rice/assets/cartao-bloqueio.png: cartão em arco do mockup (Bloqueio),
com sombra, filete dourado, halo do avatar e cartela do usuário.
Medidas em px lógicos (tela 1280x720 @1.5); o PNG sai em 1.5x."""
import subprocess, pathlib

K = 1280 / 1440                 # mockup (1440 de largura) -> lógico
W, H = 344 * K, 470 * K         # cartão
P = 48                          # margem p/ sombra (igual nos 4 lados)
R = W / 2                       # arco completo
RB = 14 * K                     # raio de baixo
TINTA_BORDA, OURO, CREME, SOMBRA = "#6E3C1E", "#B8955A", "#F7F1E3", "#4A341E"

def arco(x, y, w, h, r, rb):
    return (f"M {x} {y+r} A {r} {r} 0 0 1 {x+w} {y+r} "
            f"L {x+w} {y+h-rb} A {rb} {rb} 0 0 1 {x+w-rb} {y+h} "
            f"L {x+rb} {y+h} A {rb} {rb} 0 0 1 {x} {y+h-rb} Z")

def cartela(cx, cy, w, h, c, r):
    """retângulo com cantos côncavos: recuo c, raio r"""
    x0, x1, y0, y1 = cx - w/2, cx + w/2, cy - h/2, cy + h/2
    return (f"M {x0+c} {y0} H {x1-c} A {r} {r} 0 0 0 {x1} {y0+c} "
            f"V {y1-c} A {r} {r} 0 0 0 {x1-c} {y1} H {x0+c} "
            f"A {r} {r} 0 0 0 {x0} {y1-c} V {y0+c} A {r} {r} 0 0 0 {x0+c} {y0} Z")

i = 5 * K                       # recuo do filete interno
cx = P + W / 2
av_cy = P + (30 + 6 + 52) * K   # centro do avatar
us_cy = P + (268 + 17) * K      # centro da cartela do usuário

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W+2*P:.2f}" height="{H+2*P:.2f}">
<defs><filter id="s" x="-50%" y="-50%" width="200%" height="200%">
<feDropShadow dx="0" dy="{14*K:.2f}" stdDeviation="{20*K:.2f}" flood-color="{SOMBRA}" flood-opacity="0.22"/>
</filter></defs>
<path d="{arco(P, P, W, H, R, RB)}" fill="{CREME}" stroke="{TINTA_BORDA}" stroke-width="{2*K:.2f}" filter="url(#s)"/>
<path d="{arco(P+i, P+i, W-2*i, H-2*i, R-i, max(RB-i, 2))}" fill="none" stroke="{OURO}" stroke-width="{1*K:.2f}"/>
<circle cx="{cx}" cy="{av_cy}" r="{(52+5)*K:.2f}" fill="none" stroke="{OURO}" stroke-width="{1*K:.2f}"/>
<path d="{cartela(cx, us_cy, 200*K, 34*K, 8.3*K, 9*K)}" fill="{CREME}" stroke="{TINTA_BORDA}" stroke-width="{1.4*K:.2f}"/>
<path d="{cartela(cx, us_cy, 188*K, 22*K, 7.75*K, 15*K)}" fill="none" stroke="{OURO}" stroke-width="{1*K:.2f}"/>
</svg>'''

raiz = pathlib.Path(__file__).resolve().parent.parent
svg_path = raiz / "gen" / "cartao-bloqueio.svg"
svg_path.write_text(svg)
subprocess.run(["rsvg-convert", "-z", "1.5", str(svg_path), "-o",
                str(raiz / "assets" / "cartao-bloqueio.png")], check=True)
print(f"cartão {W:.1f}x{H:.1f} lógico, imagem {W+2*P:.1f}x{H+2*P:.1f}")
