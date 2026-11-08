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

local function rgba(hex, a) return "rgba(" .. hex .. (a or "ff") .. ")" end
M.rgba = rgba

hl.config({
    general = {
        gaps_in     = 3,
        -- topo um pouco maior: é onde fica o puxador do painel
        gaps_out    = { top = 14, right = 6, bottom = 6, left = 6 },
        border_size = 2,
        col = {
            active_border   = rgba(M.cor.cobre),
            inactive_border = rgba(M.cor.salvia_clara),
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

        -- blur só age em superfícies translúcidas (o Ghostty a 90%):
        -- forte o bastante para as gravuras virarem textura, não ruído
        blur = {
            enabled           = true,
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
