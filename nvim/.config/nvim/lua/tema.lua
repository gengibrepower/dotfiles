-- gruvbox escuro de fundo opaco sobre o terminal claro translúcido; :colorscheme mucha continua disponível
vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })

local sem_fundo = { bg = "NONE" }
-- o gruvbox pinta a coluna de sinais com bg1, mais claro que o editor
require("gruvbox").setup({
  contrast = "hard",
  transparent_mode = false,
  overrides = {
    Cursor = { fg = "#1d2021", bg = "#ffffff", reverse = false }, -- branco: o guicursor usa este grupo
    SignColumn = sem_fundo,
    GruvboxRedSign = sem_fundo,
    GruvboxGreenSign = sem_fundo,
    GruvboxYellowSign = sem_fundo,
    GruvboxBlueSign = sem_fundo,
    GruvboxPurpleSign = sem_fundo,
    GruvboxAquaSign = sem_fundo,
    GruvboxOrangeSign = sem_fundo,
  },
})
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")
