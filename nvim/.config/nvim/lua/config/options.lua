-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false
vim.opt.showtabline = 0

-- Limite de linha: com Ghostty em fonte 14 numa janela de tela cheia sobram
-- exatamente 100 colunas de código (109 - 9 da margem). A guia marca a 101.
vim.opt.colorcolumn = "101"
