-- Rice "Mucha": colorscheme próprio em colors/mucha.lua (fundo transparente,
-- contraste >= 4.5:1 sobre o creme do Ghostty). O gruvbox claro segue
-- instalado como alternativa: :colorscheme gruvbox (com background=light).
return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      contrast = "soft",
      transparent_mode = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mucha",
    },
  },
}
