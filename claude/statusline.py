#!/usr/bin/env python3
"""Statusline do Claude Code no rice Mucha + medidor de uso para o Quickshell.

O Claude Code manda um JSON no stdin a cada atualização. Daqui saem:
- a linha do rodapé: modelo · contexto · sessão de 5 h (barra) · semana
- ~/.local/state/rice/claude-uso.json, que o painel (quickshell/painel/
  MedidorClaude.qml) lê para mostrar o medidor e avisar em 80% e 95%.
Cores pela paleta ANSI, então seguem o tema claro/escuro do Ghostty.
"""
import json, os, sys, time
from datetime import datetime

def ler():
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}

def epoch(r):
    """resets_at chega como epoch (s) ou ISO 8601."""
    if r is None:
        return None
    if isinstance(r, (int, float)):
        return float(r)
    try:
        return datetime.fromisoformat(str(r).replace("Z", "+00:00")).timestamp()
    except ValueError:
        return None

def janela(rl, nome):
    j = (rl or {}).get(nome) or {}
    p = j.get("used_percentage")
    return None if p is None else {"pct": float(p), "reset": epoch(j.get("resets_at"))}

d = ler()
rl = d.get("rate_limits")
sessao, semana = janela(rl, "five_hour"), janela(rl, "seven_day")

# ---- estado para o painel (só regrava quando muda) ----
estado_dir = os.path.join(os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"), "rice")
arq = os.path.join(estado_dir, "claude-uso.json")
if sessao or semana:
    novo = {"sessao": sessao, "semana": semana}
    try:
        with open(arq) as f:
            antigo = json.load(f)
        antigo.pop("atualizado", None)
    except Exception:
        antigo = None
    if novo != antigo:
        novo["atualizado"] = time.time()
        os.makedirs(estado_dir, exist_ok=True)
        tmp = arq + ".tmp"
        with open(tmp, "w") as f:
            json.dump(novo, f)
        os.replace(tmp, arq)

# ---- linha do rodapé ----
def cor(n, t): return f"\033[{30 + n if n < 8 else 82 + n}m{t}\033[0m"
APAGADO, OK, ATENCAO, ALTO = 8, 2, 3, 1

def tom(p): return ALTO if p >= 90 else ATENCAO if p >= 70 else OK

def barra(p, n=10):
    cheio = max(0, min(n, round(p / 100 * n)))
    return cor(tom(p), "▰" * cheio) + cor(APAGADO, "▱" * (n - cheio))

partes = []
modelo = (d.get("model") or {}).get("display_name")
if modelo:
    partes.append(cor(APAGADO, modelo))
ctx = (d.get("context_window") or {}).get("used_percentage")
if ctx is not None:
    partes.append(cor(APAGADO, "contexto ") + cor(tom(float(ctx)), f"{float(ctx):.0f}%"))
if sessao:
    txt = f"sessão {barra(sessao['pct'])} {cor(tom(sessao['pct']), f'{sessao['pct']:.0f}%')}"
    if sessao["reset"]:
        txt += cor(APAGADO, " · renova " + datetime.fromtimestamp(sessao["reset"]).strftime("%H:%M"))
    partes.append(txt)
if semana:
    partes.append(cor(APAGADO, "semana ") + cor(tom(semana["pct"]), f"{semana['pct']:.0f}%"))
print(cor(APAGADO, " │ ").join(partes))
