-- gruvbox escuro de fundo opaco sobre o terminal claro translúcido; :colorscheme mucha continua disponível
vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })

require("gruvbox").setup({ contrast = "hard", transparent_mode = false })
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")
