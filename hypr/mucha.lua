-- Rice Art Nouveau "Mucha" — paleta e aparência
-- Mockup: https://claude.ai/artifact/2sKjw44zbKy6GU3d6EwtRE

local M = {}

M.cor = {
    pergaminho   = "EFE6D2", -- fundo / wallpaper
    creme        = "F7F1E3", -- superfície das janelas
    tinta        = "3A3328", -- texto principal
    salvia       = "8A9A7B", -- caules, bordas inativas
    salvia_clara = "A9B39C",
    salvia_escura= "4F5E45", -- tipos, diretórios, ok
    cobre        = "B0683A", -- borda ativa, ornamento
    cobre_escuro = "8A4B26", -- keywords, seleção forte
    ouro         = "B8955A", -- filetes, halos
    sombra       = "4A341E",
}

-- tema claro/escuro: hypr/scripts/tema.sh grava o modo; lido também no reload
local estado = io.open((os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/rice/tema")
M.escuro = estado ~= nil and estado:read("l") == "escuro"
if estado then estado:close() end
M.borda_ativa   = M.escuro and "CC8550" or M.cor.cobre
M.borda_inativa = M.escuro and "4A4436" or M.cor.salvia_clara

local function rgba(hex, a) return "rgba(" .. hex .. (a or "ff") .. ")" end
M.rgba = rgba

hl.config({
    general = {
        -- tela pequena (14"): gaps mínimos; o puxador do painel é um filete de 4 px
        gaps_in     = 2,
        gaps_out    = 4,
        border_size = 2,
        col = {
            active_border   = rgba(M.borda_ativa),
            inactive_border = rgba(M.borda_inativa),
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- box-shadow: 0 10px 30px rgba(74,52,30,.18) do mockup
        shadow = {
            enabled        = true,
            range          = 30,
            render_power   = 2,
            offset         = { 0, 10 },
            color          = rgba(M.cor.sombra, "2e"),
            color_inactive = rgba(M.cor.sombra, "1a"),
        },

        -- blur desligado: o usuário prefere ver o wallpaper nítido atrás do
        -- Ghostty translúcido (a 80%). Para religar: enabled = true aqui e
        -- background-blur = true no Ghostty.
        blur = {
            enabled           = false,
            size              = 5,
            passes            = 2,
            noise             = 0.012,
            contrast          = 0.9,
            brightness        = 1.0,
            vibrancy          = 0.12,
            new_optimizations = true,
            xray              = false,
        },
    },

    group = {
        col = {
            border_active   = rgba(M.cor.cobre),
            border_inactive = rgba(M.cor.salvia_clara),
        },
    },

    misc = {
        background_color = rgba(M.cor.pergaminho),
    },
})

return M
